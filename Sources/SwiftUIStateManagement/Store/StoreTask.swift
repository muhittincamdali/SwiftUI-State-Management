/// The effects started by one call to ``Store/send(_:)``.
///
/// Await ``finish()`` to wait for them, for example to keep a pull-to-refresh spinner visible
/// until the reload is done:
///
/// ```swift
/// List(store.items) { ... }
///     .refreshable { await store.send(.refresh).finish() }
/// ```
///
/// Effects started later, by actions that these effects send back, are not part of the task.
public struct StoreTask: Hashable, Sendable {
    private let tasks: [Task<Void, Never>]

    package init(tasks: [Task<Void, Never>]) {
        self.tasks = tasks
    }

    /// Waits until every effect of this task has finished or been cancelled.
    ///
    /// If the task that awaits `finish()` is cancelled, the effects are cancelled too; this is
    /// what makes `.task { await store.send(.onAppear).finish() }` stop a long-running effect
    /// when the view disappears.
    public func finish() async {
        await withTaskCancellationHandler {
            for task in tasks {
                await task.value
            }
        } onCancel: {
            for task in tasks { task.cancel() }
        }
    }

    /// Cancels every effect of this task.
    public func cancel() {
        for task in tasks { task.cancel() }
    }

    /// Whether the send started effects and all of them were cancelled.
    public var isCancelled: Bool {
        !tasks.isEmpty && tasks.allSatisfy(\.isCancelled)
    }
}
