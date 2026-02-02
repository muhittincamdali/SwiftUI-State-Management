import Foundation
import XCTest

// MARK: - TestStore

/// A testing-oriented store wrapper that makes it easy to assert
/// state transitions in unit tests.
///
/// Usage:
/// ```swift
/// func testIncrement() async {
///     let store = TestStore(
///         initialState: CounterState(),
///         reducer: counterReducer
///     )
///     await store.send(.increment) {
///         $0.count = 1
///     }
/// }
/// ```
public final class TestStore<State: Equatable, Action> {

    // MARK: - Properties

    /// The underlying store.
    private let store: Store<State, Action>

    /// Tracks expected state for assertions.
    private var expectedState: State

    /// Records all dispatched actions.
    public private(set) var receivedActions: [Action] = []

    /// Records all intermediate states.
    public private(set) var stateHistory: [State] = []

    // MARK: - Initialization

    /// Creates a test store with initial state and reducer.
    ///
    /// - Parameters:
    ///   - initialState: The starting state.
    ///   - reducer: The reducer under test.
    public init(
        initialState: State,
        reducer: Reducer<State, Action>
    ) {
        self.store = Store(initialState: initialState, reducer: reducer)
        self.expectedState = initialState
        self.stateHistory.append(initialState)

        store.onStateChange = { [weak self] state, _ in
            self?.stateHistory.append(state)
        }
    }

    // MARK: - Sending Actions

    /// Sends an action and asserts the resulting state matches expectations.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - mutation: A closure that mutates `expectedState` to what the new state should be.
    ///   - file: The calling file (for assertion reporting).
    ///   - line: The calling line (for assertion reporting).
    @MainActor
    public func send(
        _ action: Action,
        _ mutation: (inout State) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        receivedActions.append(action)

        // Apply expected mutation
        mutation(&expectedState)

        // Send action to actual store
        await store.sendAsync(action)

        // Assert state matches
        if store.state != expectedState {
            XCTFail(
                """
                State mismatch after action: \(action)
                Expected: \(expectedState)
                Actual: \(store.state)
                """,
                file: file,
                line: line
            )
            // Sync expected state to actual to continue testing
            expectedState = store.state
        }
    }

    // MARK: - State Access

    /// The current actual state of the store.
    public var state: State {
        store.state
    }

    /// Asserts that the current state matches an expected value.
    public func assert(
        _ expected: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(store.state, expected, file: file, line: line)
    }

    /// Verifies a specific property of the state.
    public func assertValue<Value: Equatable>(
        _ keyPath: KeyPath<State, Value>,
        equals expected: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(store.state[keyPath: keyPath], expected, file: file, line: line)
    }

    // MARK: - History

    /// Returns the number of actions that have been dispatched.
    public var actionCount: Int {
        receivedActions.count
    }

    /// Resets the test store to its initial state.
    public func reset(to state: State) {
        expectedState = state
        receivedActions.removeAll()
        stateHistory.removeAll()
        stateHistory.append(state)
    }
}
