import os
import SwiftUIStateManagement

/// A store for tests that checks every state change and every action an effect sends.
///
/// Send an action and describe how the state should change; the test fails, with a line-by-line
/// difference, when the reducer changes it in another way. Actions that effects send back must
/// be checked in order with ``receive(_:timeout:assert:fileID:filePath:line:column:)``:
///
/// ```swift
/// @Test @MainActor
/// func loadsAFact() async {
///     let store = TestStore(
///         initialState: Counter.State(),
///         reducer: Counter(facts: FactClient { "\($0) is a number." })
///     )
///     await store.send(.incrementTapped) { $0.count = 1 }
///     await store.send(.factTapped) { $0.isLoadingFact = true }
///     await store.receive(.factLoaded("1 is a number.")) {
///         $0.isLoadingFact = false
///         $0.fact = "1 is a number."
///     }
/// }
/// ```
///
/// The test also fails when the store is deallocated while effects are still running or while
/// received actions have not been checked, and when an effect throws an error that it does not
/// handle. Failures are recorded in Swift Testing, or with `XCTFail` in an XCTest test case.
@MainActor
public final class TestStore<State: Equatable, Action> {
    private struct Received {
        let action: Action
        let stateBefore: State
        let stateAfter: State
    }

    /// The current state, after every action sent and received so far.
    public private(set) var state: State
    /// How long ``receive(_:timeout:assert:fileID:filePath:line:column:)`` and ``finish(timeout:fileID:filePath:line:column:)``
    /// wait by default, in real time.
    public var timeout: Duration

    private let reduce: @MainActor (inout State, Action) -> Effect<Action>
    private let runner = EffectRunner<Action>()
    private let exitCheck: ExitCheck
    private var received: [Received] = []
    private var pending: [Action] = []
    private var isProcessing = false
    private var receiveWaiter: Waiter?
    private var idleWaiter: Waiter?
    private var nextWaiterID: UInt64 = 0

    /// Creates a test store.
    ///
    /// - Parameters:
    ///   - initialState: The state to start with.
    ///   - reducer: The reducer under test, with fake dependencies.
    ///   - timeout: The default time to wait for actions and effects; one second unless set.
    public init<R: Reducer>(
        initialState: State,
        reducer: R,
        timeout: Duration = .seconds(1),
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) where R.State == State, R.Action == Action {
        self.state = initialState
        self.timeout = timeout
        self.reduce = { state, action in reducer.reduce(into: &state, action: action) }
        let location = FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        self.exitCheck = ExitCheck(location: location)
        runner.deliver = { [weak self] action in
            self?.deliver(action)
        }
        runner.reportUnhandledError = { error in
            recordFailure(
                "An effect threw an error it does not handle:\n\(error)\n\n"
                    + "Pass catch: to Effect.run to turn the error into an action.",
                at: location
            )
        }
        runner.taskFinished = { [weak self] in
            self?.effectFinished()
        }
    }

    deinit {
        exitCheck.report()
        runner.cancelAll()
    }

    /// Sends `action` and checks the state change.
    ///
    /// - Parameters:
    ///   - action: The action to send.
    ///   - update: Changes a copy of the state before the action into the state you expect
    ///     after it. Leave it out when the action must not change the state.
    /// - Returns: The effects the action started; cancel it to stop them, or await
    ///   ``StoreTask/finish()``.
    @discardableResult
    public func send(
        _ action: Action,
        assert update: ((inout State) throws -> Void)? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async -> StoreTask {
        let location = FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        if !received.isEmpty {
            recordFailure(
                "\(received.count) received action(s) must be checked with receive before sending another action:\n"
                    + received.map { "  \($0.action)" }.joined(separator: "\n"),
                at: location
            )
            received.removeAll()
            updateExitCheck()
        }
        let stateBefore = state
        let tasks = process(action)
        let stateAfter = received.first?.stateBefore ?? state
        expect(stateBefore, update: update, toBecome: stateAfter, after: "sending \(action)", at: location)
        return StoreTask(tasks: tasks)
    }

    /// Waits for the next action an effect sends, checks that it is `expectedAction`, and checks
    /// the state change it made.
    ///
    /// - Parameters:
    ///   - expectedAction: The action you expect next.
    ///   - timeout: How long to wait in real time; ``timeout`` when `nil`.
    ///   - update: Changes a copy of the state before the action into the state you expect
    ///     after it.
    public func receive(
        _ expectedAction: Action,
        timeout: Duration? = nil,
        assert update: ((inout State) throws -> Void)? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async where Action: Equatable {
        let location = FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        guard let next = await nextReceived(timeout: timeout ?? self.timeout, expecting: "\(expectedAction)", at: location) else {
            return
        }
        if next.action != expectedAction {
            recordFailure(
                "Received an action other than the expected one:\n"
                    + Difference.lines(expected: expectedAction, actual: next.action),
                at: location
            )
        }
        expect(next.stateBefore, update: update, toBecome: next.stateAfter, after: "receiving \(next.action)", at: location)
    }

    /// Waits for the next action an effect sends, checks that `isExpected` returns `true` for
    /// it, and checks the state change it made. Use it when `Action` is not `Equatable`.
    public func receive(
        matching isExpected: (Action) -> Bool,
        timeout: Duration? = nil,
        assert update: ((inout State) throws -> Void)? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async {
        let location = FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        guard let next = await nextReceived(timeout: timeout ?? self.timeout, expecting: "a matching action", at: location) else {
            return
        }
        if !isExpected(next.action) {
            recordFailure("Received an action that does not match:\n  \(next.action)", at: location)
        }
        expect(next.stateBefore, update: update, toBecome: next.stateAfter, after: "receiving \(next.action)", at: location)
    }

    /// Waits until every effect has finished; the test fails when some are still running after
    /// `timeout`.
    public func finish(
        timeout: Duration? = nil,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async {
        let location = FailureLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        if runner.runningCount > 0 {
            await wait(for: \.idleWaiter, timeout: timeout ?? self.timeout)
        }
        let running = runner.runningCount
        if running > 0 {
            recordFailure(
                "\(running) effect(s) still running after \(timeout ?? self.timeout). "
                    + "Cancel long-living effects in the test, or call cancelInFlightEffects().",
                at: location
            )
        }
    }

    /// Discards the received actions that have not been checked yet.
    public func skipReceivedActions() {
        received.removeAll()
        updateExitCheck()
    }

    /// Cancels every running effect, for tests that do not care how a long-living effect ends.
    public func cancelInFlightEffects() {
        runner.cancelAll()
    }

    // MARK: - Processing

    /// Processes `action` and the actions it sends with `Effect.send`; returns the tasks started.
    private func process(_ action: Action) -> [Task<Void, Never>] {
        reduceAndRun(action, record: false)
    }

    /// Called for every action an effect sends.
    private func deliver(_ action: Action) {
        guard !isProcessing else {
            pending.append(action)
            return
        }
        _ = reduceAndRun(action, record: true)
    }

    private func reduceAndRun(_ first: Action, record: Bool) -> [Task<Void, Never>] {
        isProcessing = true
        defer { isProcessing = false }
        var started: [Task<Void, Never>] = []
        var next: (action: Action, record: Bool)? = (first, record)
        var processed = 0
        while let (action, record) = next {
            processed += 1
            if processed > Self.synchronousActionLimit {
                recordFailure(
                    "One action led to more than \(Self.synchronousActionLimit) actions sent with Effect.send; "
                        + "the rest were dropped. Check for actions that send each other.",
                    at: exitCheck.location
                )
                pending.removeAll()
                break
            }
            let stateBefore = state
            let effect = reduce(&state, action)
            if record {
                received.append(Received(action: action, stateBefore: stateBefore, stateAfter: state))
            }
            started += runner.run(effect)
            next = pending.isEmpty ? nil : (pending.removeFirst(), true)
        }
        updateExitCheck()
        if !received.isEmpty { resume(\.receiveWaiter) }
        return started
    }

    private static var synchronousActionLimit: Int { 10_000 }

    private func effectFinished() {
        updateExitCheck()
        if runner.runningCount == 0 { resume(\.idleWaiter) }
    }

    // MARK: - Waiting

    private func nextReceived(timeout: Duration, expecting description: String, at location: FailureLocation) async -> Received? {
        if received.isEmpty, runner.runningCount > 0 {
            await wait(for: \.receiveWaiter, timeout: timeout)
        }
        guard !received.isEmpty else {
            let running = runner.runningCount
            recordFailure(
                "Expected to receive \(description), but "
                    + (running > 0
                        ? "no action arrived within \(timeout) while \(running) effect(s) were running."
                        : "no effect is running that could send it."),
                at: location
            )
            return nil
        }
        let next = received.removeFirst()
        updateExitCheck()
        return next
    }

    /// Suspends until `waiter` is resumed or `timeout` passes.
    private func wait(for waiter: ReferenceWritableKeyPath<TestStore, Waiter?>, timeout: Duration) async {
        nextWaiterID &+= 1
        let id = nextWaiterID
        let timer = Task { @MainActor [weak self] in
            try? await Task.sleep(for: timeout)
            guard let self, self[keyPath: waiter]?.id == id else { return }
            self.resume(waiter)
        }
        await withCheckedContinuation { continuation in
            self[keyPath: waiter] = Waiter(id: id, continuation: continuation)
        }
        timer.cancel()
    }

    private func resume(_ waiter: ReferenceWritableKeyPath<TestStore, Waiter?>) {
        let current = self[keyPath: waiter]
        self[keyPath: waiter] = nil
        current?.continuation.resume()
    }

    // MARK: - Checks

    private func expect(
        _ stateBefore: State,
        update: ((inout State) throws -> Void)?,
        toBecome actual: State,
        after event: String,
        at location: FailureLocation
    ) {
        var expected = stateBefore
        do {
            try update?(&expected)
        } catch {
            recordFailure("The assert closure threw an error: \(error)", at: location)
            return
        }
        guard expected != actual else { return }
        recordFailure(
            "The state after \(event) is not the expected one:\n"
                + Difference.lines(expected: expected, actual: actual),
            at: location
        )
    }

    private func updateExitCheck() {
        exitCheck.update(
            unreceived: received.map { "\($0.action)" },
            runningEffects: runner.runningCount
        )
    }
}

private struct Waiter {
    let id: UInt64
    let continuation: CheckedContinuation<Void, Never>
}

/// What the test store still owes at the end of the test, readable from `deinit`.
private final class ExitCheck: Sendable {
    private struct Snapshot {
        var unreceived: [String] = []
        var runningEffects = 0
    }

    let location: FailureLocation
    private let snapshot = OSAllocatedUnfairLock(initialState: Snapshot())

    init(location: FailureLocation) {
        self.location = location
    }

    func update(unreceived: [String], runningEffects: Int) {
        snapshot.withLock { $0 = Snapshot(unreceived: unreceived, runningEffects: runningEffects) }
    }

    func report() {
        let current = snapshot.withLock { $0 }
        if !current.unreceived.isEmpty {
            recordFailure(
                "The store received \(current.unreceived.count) action(s) that the test did not check:\n"
                    + current.unreceived.map { "  \($0)" }.joined(separator: "\n"),
                at: location
            )
        }
        if current.runningEffects > 0 {
            recordFailure(
                "\(current.runningEffects) effect(s) were still running when the test store was deallocated. "
                    + "Await finish(), receive their actions, or cancel them.",
                at: location
            )
        }
    }
}
