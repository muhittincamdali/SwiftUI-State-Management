import Foundation
import XCTest

// MARK: - Test Store

/// A specialized store for unit testing reducers and effects.
/// Provides assertions for state changes and effect tracking.
///
/// ## Basic Usage
///
/// ```swift
/// func testIncrement() async {
///     let store = TestStore(
///         initialState: Counter.State(count: 0),
///         reducer: Counter.reducer
///     )
///
///     await store.send(.increment) {
///         $0.count = 1
///     }
/// }
/// ```
///
/// ## Testing Effects
///
/// ```swift
/// func testFetchUsers() async {
///     let store = TestStore(
///         initialState: Users.State(),
///         reducer: Users.reducer
///     ) {
///         $0.apiClient = .mock(users: [.alice, .bob])
///     }
///
///     await store.send(.fetchUsers)
///     await store.receive(.usersLoaded([.alice, .bob])) {
///         $0.users = [.alice, .bob]
///     }
/// }
/// ```
@MainActor
public final class TestStore<State: Equatable, Action: Equatable> {
    
    // MARK: - Properties
    
    /// The current state of the test store.
    public private(set) var state: State
    
    /// The reducer being tested.
    private let reducer: Reducer<State, Action>
    
    /// Pending effects that need to be drained.
    private var pendingEffects: [Effect<Action>] = []
    
    /// Actions received from effects.
    private var receivedActions: [Action] = []
    
    /// Configuration for test behavior.
    private let configuration: TestConfiguration
    
    /// File and line for better test failure messages.
    private var file: StaticString = #file
    private var line: UInt = #line
    
    // MARK: - Test Configuration
    
    /// Configuration options for test behavior.
    public struct TestConfiguration {
        /// Whether to exhaustively verify all state changes.
        public var exhaustivity: Exhaustivity = .full
        
        /// Timeout for async operations.
        public var timeout: TimeInterval = 5.0
        
        /// Whether to fail on unhandled effects.
        public var failOnUnhandledEffects: Bool = true
        
        public static let `default` = TestConfiguration()
        
        /// Exhaustivity level for state verification.
        public enum Exhaustivity {
            /// All state changes must be explicitly verified.
            case full
            
            /// Allow skipping some state verifications.
            case partial
            
            /// No verification required.
            case off
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a test store with the given initial state and reducer.
    ///
    /// - Parameters:
    ///   - initialState: The starting state for testing.
    ///   - reducer: The reducer to test.
    ///   - configuration: Test configuration options.
    ///   - prepareDependencies: Optional closure to prepare test dependencies.
    public init(
        initialState: State,
        reducer: Reducer<State, Action>,
        configuration: TestConfiguration = .default,
        prepareDependencies: ((inout Dependencies) -> Void)? = nil
    ) {
        self.state = initialState
        self.reducer = reducer
        self.configuration = configuration
        
        if var deps = Dependencies.current {
            prepareDependencies?(&deps)
            Dependencies.current = deps
        }
    }
    
    /// Creates a test store from a feature type.
    public convenience init<F: Feature>(
        _ feature: F.Type,
        initialState: State,
        configuration: TestConfiguration = .default
    ) where F.State == State, F.Action == Action {
        self.init(
            initialState: initialState,
            reducer: Reducer { state, action in
                F.reduce(state: &state, action: action)
            },
            configuration: configuration
        )
    }
    
    // MARK: - Send Action
    
    /// Sends an action and asserts the resulting state change.
    ///
    /// - Parameters:
    ///   - action: The action to send.
    ///   - updateState: Closure that modifies expected state.
    ///   - file: Source file for assertion failures.
    ///   - line: Source line for assertion failures.
    public func send(
        _ action: Action,
        assert updateState: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        self.file = file
        self.line = line
        
        var expectedState = state
        updateState?(&expectedState)
        
        let effect = reducer.reduce(&state, action)
        
        if configuration.exhaustivity == .full, let _ = updateState {
            if state != expectedState {
                XCTFail(
                    """
                    State change did not match expectation.
                    
                    Expected:
                    \(String(describing: expectedState))
                    
                    Actual:
                    \(String(describing: state))
                    """,
                    file: file,
                    line: line
                )
            }
        }
        
        // Queue the effect for processing
        if case .none = effect.kind {
            // No effect
        } else {
            pendingEffects.append(effect)
        }
        
        // Process effects and collect actions
        await processEffects()
    }
    
    /// Sends an action without state assertion (for fire-and-forget actions).
    public func send(
        _ action: Action,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        await send(action, assert: nil, file: file, line: line)
    }
    
    // MARK: - Receive Action
    
    /// Asserts that an action was received from an effect.
    ///
    /// - Parameters:
    ///   - expectedAction: The expected action.
    ///   - updateState: Closure that modifies expected state.
    ///   - file: Source file for assertion failures.
    ///   - line: Source line for assertion failures.
    public func receive(
        _ expectedAction: Action,
        assert updateState: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        self.file = file
        self.line = line
        
        // Wait for effects to produce actions
        let deadline = Date().addingTimeInterval(configuration.timeout)
        while receivedActions.isEmpty && Date() < deadline {
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
            await processEffects()
        }
        
        guard !receivedActions.isEmpty else {
            XCTFail(
                "Expected to receive action \(expectedAction), but no actions were received.",
                file: file,
                line: line
            )
            return
        }
        
        let receivedAction = receivedActions.removeFirst()
        
        if receivedAction != expectedAction {
            XCTFail(
                """
                Received unexpected action.
                
                Expected:
                \(expectedAction)
                
                Received:
                \(receivedAction)
                """,
                file: file,
                line: line
            )
            return
        }
        
        // Process the received action through the reducer
        var expectedState = state
        updateState?(&expectedState)
        
        let effect = reducer.reduce(&state, receivedAction)
        
        if configuration.exhaustivity == .full, let _ = updateState {
            if state != expectedState {
                XCTFail(
                    """
                    State change did not match expectation after receiving \(receivedAction).
                    
                    Expected:
                    \(String(describing: expectedState))
                    
                    Actual:
                    \(String(describing: state))
                    """,
                    file: file,
                    line: line
                )
            }
        }
        
        if case .none = effect.kind {
            // No effect
        } else {
            pendingEffects.append(effect)
        }
        
        await processEffects()
    }
    
    /// Asserts that a matching action was received.
    public func receive(
        matching predicate: (Action) -> Bool,
        assert updateState: ((inout State) -> Void)? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        self.file = file
        self.line = line
        
        let deadline = Date().addingTimeInterval(configuration.timeout)
        while receivedActions.isEmpty && Date() < deadline {
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
            await processEffects()
        }
        
        guard !receivedActions.isEmpty else {
            XCTFail(
                "Expected to receive a matching action, but no actions were received.",
                file: file,
                line: line
            )
            return
        }
        
        let receivedAction = receivedActions.removeFirst()
        
        guard predicate(receivedAction) else {
            XCTFail(
                "Received action \(receivedAction) did not match predicate.",
                file: file,
                line: line
            )
            return
        }
        
        var expectedState = state
        updateState?(&expectedState)
        
        let effect = reducer.reduce(&state, receivedAction)
        
        if case .none = effect.kind {
            // No effect
        } else {
            pendingEffects.append(effect)
        }
        
        await processEffects()
    }
    
    // MARK: - Effect Processing
    
    private func processEffects() async {
        let effects = pendingEffects
        pendingEffects = []
        
        for effect in effects {
            await processEffect(effect)
        }
    }
    
    private func processEffect(_ effect: Effect<Action>) async {
        switch effect.kind {
        case .none:
            break
            
        case .task(let work):
            do {
                if let action = try await work() {
                    receivedActions.append(action)
                }
            } catch {
                // Effect threw an error - this is expected in some tests
            }
            
        case .combine(let effects):
            for childEffect in effects {
                await processEffect(childEffect)
            }
            
        case .cancel:
            break
            
        case .debounce(let innerEffect, _, _):
            await processEffect(innerEffect)
            
        case .throttle(let innerEffect, _, _):
            await processEffect(innerEffect)
        }
    }
    
    // MARK: - Assertions
    
    /// Asserts that all effects have been handled.
    public func finish(
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if configuration.failOnUnhandledEffects && !pendingEffects.isEmpty {
            XCTFail(
                "Test finished with \(pendingEffects.count) unhandled effect(s).",
                file: file,
                line: line
            )
        }
        
        if !receivedActions.isEmpty {
            XCTFail(
                """
                Test finished with \(receivedActions.count) unhandled action(s):
                \(receivedActions.map { "  - \($0)" }.joined(separator: "\n"))
                """,
                file: file,
                line: line
            )
        }
    }
    
    /// Asserts current state matches expected state.
    public func assert(
        state expectedState: State,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if state != expectedState {
            XCTFail(
                """
                State assertion failed.
                
                Expected:
                \(String(describing: expectedState))
                
                Actual:
                \(String(describing: state))
                """,
                file: file,
                line: line
            )
        }
    }
    
    /// Asserts a specific property of state.
    public func assert<Value: Equatable>(
        _ keyPath: KeyPath<State, Value>,
        equals expectedValue: Value,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actualValue = state[keyPath: keyPath]
        if actualValue != expectedValue {
            XCTFail(
                """
                State property assertion failed.
                
                KeyPath: \(keyPath)
                Expected: \(expectedValue)
                Actual: \(actualValue)
                """,
                file: file,
                line: line
            )
        }
    }
    
    // MARK: - Utilities
    
    /// Skips the next N received actions without assertion.
    public func skip(_ count: Int = 1) async {
        for _ in 0..<count {
            let deadline = Date().addingTimeInterval(configuration.timeout)
            while receivedActions.isEmpty && Date() < deadline {
                await Task.yield()
                try? await Task.sleep(nanoseconds: 10_000_000)
                await processEffects()
            }
            
            if !receivedActions.isEmpty {
                let action = receivedActions.removeFirst()
                let effect = reducer.reduce(&state, action)
                
                if case .none = effect.kind {
                    // No effect
                } else {
                    pendingEffects.append(effect)
                }
            }
        }
    }
    
    /// Waits for all pending effects to complete.
    public func drainEffects() async {
        let deadline = Date().addingTimeInterval(configuration.timeout)
        
        while (!pendingEffects.isEmpty || !receivedActions.isEmpty) && Date() < deadline {
            await processEffects()
            
            // Process any received actions
            while !receivedActions.isEmpty {
                let action = receivedActions.removeFirst()
                let effect = reducer.reduce(&state, action)
                
                if case .none = effect.kind {
                    // No effect
                } else {
                    pendingEffects.append(effect)
                }
            }
            
            await Task.yield()
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}

// MARK: - Dependencies

/// Simple dependency injection container for testing.
public struct Dependencies {
    public static var current: Dependencies? = Dependencies()
    
    public init() {}
}

// MARK: - Feature Protocol

/// Protocol for defining a feature with state, action, and reducer.
public protocol Feature {
    associatedtype State: Equatable
    associatedtype Action: Equatable
    
    static func reduce(state: inout State, action: Action) -> Effect<Action>
}

// MARK: - Test Helpers

extension TestStore {
    /// Creates a test store with mock dependencies.
    public static func withMocks(
        initialState: State,
        reducer: Reducer<State, Action>,
        mocks: (inout Dependencies) -> Void
    ) -> TestStore {
        TestStore(
            initialState: initialState,
            reducer: reducer,
            prepareDependencies: mocks
        )
    }
}

// MARK: - Snapshot Testing Support

extension TestStore {
    /// Captures the current state for snapshot testing.
    public var snapshot: State {
        state
    }
    
    /// Exports state as JSON for snapshot comparison.
    public func exportStateJSON() throws -> Data where State: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(state)
    }
}
