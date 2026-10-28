import os

/// Starts the operations of effects, tracks them by identifier, and cancels them.
///
/// Shared by `Store` and `TestStore`. Every method runs on the main actor; the task table is
/// also kept behind a lock so that the owner's `deinit`, which is not isolated, can cancel
/// everything that is still running.
@MainActor
package final class EffectRunner<Action> {
    package typealias Deliver = @MainActor (Action) -> Void

    private struct Table {
        var tasks: [UInt64: Task<Void, Never>] = [:]
        var idsByTask: [UInt64: AnyHashable] = [:]
        var tasksByID: [AnyHashable: Set<UInt64>] = [:]
        var nextKey: UInt64 = 0
    }

    private let table = OSAllocatedUnfairLock(uncheckedState: Table())
    /// Receives the actions that `.send` effects and `Send` produce. Set by the owner.
    package var deliver: Deliver = { _ in }
    /// Receives errors thrown by operations without a `catch` handler.
    package var reportUnhandledError: @MainActor (any Error) -> Void = { _ in }
    /// Called each time a task finishes, after it was removed from the table.
    package var taskFinished: @MainActor () -> Void = {}

    package init() {}

    deinit {
        cancelAll()
    }

    /// The number of operations that are still running.
    package var runningCount: Int {
        table.withLockUnchecked { $0.tasks.count }
    }

    /// Runs the immediate parts of `effect` and starts its operations. Returns the tasks started.
    package func run(_ effect: Effect<Action>) -> [Task<Void, Never>] {
        var started: [Task<Void, Never>] = []
        for operation in effect.operations {
            switch operation {
            case .send(let action):
                deliver(action)
            case .cancel(let id):
                cancel(id: id)
            case .run(let run):
                if let id = run.id, run.cancelInFlight {
                    cancel(id: id)
                }
                started.append(start(run))
            }
        }
        return started
    }

    /// Cancels every running operation started with `id`.
    package func cancel(id: AnyHashable) {
        let tasks = table.withLockUnchecked { table -> [Task<Void, Never>] in
            guard let keys = table.tasksByID.removeValue(forKey: id) else { return [] }
            return keys.compactMap { key in
                table.idsByTask[key] = nil
                return table.tasks[key]
            }
        }
        for task in tasks { task.cancel() }
    }

    /// Cancels every running operation. Safe to call from any thread, including `deinit`.
    nonisolated package func cancelAll() {
        let tasks = table.withLockUnchecked { table -> [Task<Void, Never>] in
            let tasks = Array(table.tasks.values)
            table.tasksByID.removeAll()
            table.idsByTask.removeAll()
            return tasks
        }
        for task in tasks { task.cancel() }
    }

    private func start(_ run: Effect<Action>.Run) -> Task<Void, Never> {
        let key = table.withLockUnchecked { table -> UInt64 in
            defer { table.nextKey &+= 1 }
            return table.nextKey
        }
        let send = Send<Action> { [weak self] action in
            self?.deliver(action)
        }
        let operation = run.operation
        let onError = run.onError
        // The task starts after this method returns (it is enqueued on the main actor), so it is
        // always in the table before it can finish and remove itself.
        let task = Task(priority: run.priority) { @MainActor [weak self] in
            do {
                try await operation(send)
            } catch is CancellationError {
            } catch {
                if !Task.isCancelled {
                    if let onError {
                        onError(error, send)
                    } else {
                        self?.reportUnhandledError(error)
                    }
                }
            }
            self?.finish(key)
        }
        table.withLockUnchecked { table in
            table.tasks[key] = task
            if let id = run.id {
                table.idsByTask[key] = id
                table.tasksByID[id, default: []].insert(key)
            }
        }
        return task
    }

    private func finish(_ key: UInt64) {
        table.withLockUnchecked { table in
            table.tasks[key] = nil
            if let id = table.idsByTask.removeValue(forKey: key) {
                table.tasksByID[id]?.remove(key)
                if table.tasksByID[id]?.isEmpty == true {
                    table.tasksByID[id] = nil
                }
            }
        }
        taskFinished()
    }
}
