import os

/// A clock whose time moves only when a test calls ``advance(by:)``.
///
/// Give it to a reducer that sleeps (a debounce, a timeout, a retry delay) and the test decides
/// when each sleep ends, without waiting in real time:
///
/// ```swift
/// let clock = TestClock()
/// let store = TestStore(initialState: Search.State(), reducer: Search(api: api, clock: clock))
///
/// await store.send(.queryChanged("swift")) { $0.query = "swift" }
/// await clock.waitForSleepers()             // the debounce is sleeping
/// clock.advance(by: .milliseconds(300))     // and now it is over
/// await store.receive(.resultsLoaded(["Swift"])) { $0.results = ["Swift"] }
/// ```
///
/// A sleep whose deadline is not after ``now`` returns at once. A cancelled sleep throws
/// `CancellationError`.
public final class TestClock: Clock, Sendable {
    /// A point in the time of a ``TestClock``: the time since the clock started.
    public struct Instant: InstantProtocol, Hashable, Sendable {
        /// The time since the clock started.
        public let offset: Duration

        /// Creates an instant `offset` after the start of the clock.
        public init(offset: Duration = .zero) {
            self.offset = offset
        }

        public func advanced(by duration: Duration) -> Instant {
            Instant(offset: offset + duration)
        }

        public func duration(to other: Instant) -> Duration {
            other.offset - offset
        }

        public static func < (lhs: Instant, rhs: Instant) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    private struct Sleeper {
        let deadline: Instant
        let continuation: CheckedContinuation<Void, any Error>
    }

    private struct Watch {
        let count: Int
        let continuation: CheckedContinuation<Void, Never>
    }

    private struct State {
        var now = Instant()
        var nextID: UInt64 = 0
        var sleepers: [UInt64: Sleeper] = [:]
        var watches: [UInt64: Watch] = [:]

        mutating func makeID() -> UInt64 {
            defer { nextID &+= 1 }
            return nextID
        }

        /// Removes and returns the watches that the current number of sleepers satisfies.
        mutating func takeSatisfiedWatches() -> [Watch] {
            let satisfied = watches.filter { $0.value.count <= sleepers.count }
            for id in satisfied.keys { watches[id] = nil }
            return Array(satisfied.values)
        }
    }

    private let state = OSAllocatedUnfairLock(uncheckedState: State())

    /// Creates a clock at its start.
    public init() {}

    /// The current time of the clock.
    public var now: Instant {
        state.withLockUnchecked { $0.now }
    }

    /// Zero: the clock represents any duration exactly.
    public var minimumResolution: Duration { .zero }

    /// The number of tasks sleeping on the clock.
    public var sleeperCount: Int {
        state.withLockUnchecked { $0.sleepers.count }
    }

    /// Suspends until the clock reaches `deadline`.
    ///
    /// - Throws: `CancellationError` when the task is cancelled before or during the sleep.
    public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        try Task.checkCancellation()
        let id = state.withLockUnchecked { $0.makeID() }
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                enum Outcome { case wait([Watch]), resume, cancel }
                let outcome: Outcome = state.withLockUnchecked { state in
                    if Task.isCancelled { return .cancel }
                    if deadline <= state.now { return .resume }
                    state.sleepers[id] = Sleeper(deadline: deadline, continuation: continuation)
                    return .wait(state.takeSatisfiedWatches())
                }
                switch outcome {
                case .cancel:
                    continuation.resume(throwing: CancellationError())
                case .resume:
                    continuation.resume()
                case .wait(let watches):
                    for watch in watches { watch.continuation.resume() }
                }
            }
        } onCancel: {
            let sleeper = state.withLockUnchecked { $0.sleepers.removeValue(forKey: id) }
            sleeper?.continuation.resume(throwing: CancellationError())
        }
    }

    /// Moves the clock forward by `duration` and ends every sleep whose deadline it reaches,
    /// earliest deadline first.
    ///
    /// The woken tasks continue after this method returns. A negative `duration` is a mistake in
    /// the test: it is recorded as a test failure and the clock does not move.
    public func advance(
        by duration: Duration,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) {
        guard duration >= .zero else {
            recordFailure(
                "TestClock cannot move backwards: advance(by: \(duration)).",
                at: FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
            )
            return
        }
        let due: [Sleeper] = state.withLockUnchecked { state in
            let target = state.now.advanced(by: duration)
            state.now = target
            let due = state.sleepers.filter { $0.value.deadline <= target }
            for id in due.keys { state.sleepers[id] = nil }
            return Array(due.values)
        }
        for sleeper in due.sorted(by: { $0.deadline < $1.deadline }) {
            sleeper.continuation.resume()
        }
    }

    /// Waits until at least `count` tasks are sleeping on the clock, or until `timeout` has
    /// passed in real time.
    ///
    /// Call it before ``advance(by:)`` when the code under test starts its sleep in another task,
    /// such as an effect: advancing first would move time past a sleep that has not begun.
    ///
    /// - Returns: `true` when `count` sleepers were reached, `false` after the timeout or when
    ///   the waiting task is cancelled.
    @discardableResult
    public func waitForSleepers(count: Int = 1, timeout: Duration = .seconds(1)) async -> Bool {
        let id = state.withLockUnchecked { $0.makeID() }
        let timeoutTask = Task {
            try? await Task.sleep(for: timeout)
            self.endWatch(id)
        }
        defer { timeoutTask.cancel() }
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                let ready = state.withLockUnchecked { state -> Bool in
                    if Task.isCancelled || state.sleepers.count >= count { return true }
                    state.watches[id] = Watch(count: count, continuation: continuation)
                    return false
                }
                if ready { continuation.resume() }
            }
        } onCancel: {
            endWatch(id)
        }
        return sleeperCount >= count
    }

    private func endWatch(_ id: UInt64) {
        let watch = state.withLockUnchecked { $0.watches.removeValue(forKey: id) }
        watch?.continuation.resume()
    }
}
