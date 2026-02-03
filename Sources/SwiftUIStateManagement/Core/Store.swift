import SwiftUI
import Combine
import os.log

// MARK: - Store Configuration

/// Configuration options for Store behavior.
public struct StoreConfiguration {
    
    /// Whether to enable automatic state persistence.
    public var persistenceEnabled: Bool
    
    /// Whether to enable time-travel debugging.
    public var timeTravelEnabled: Bool
    
    /// Maximum number of state history entries to keep.
    public var maxHistorySize: Int
    
    /// Whether to log all dispatched actions.
    public var loggingEnabled: Bool
    
    /// Thread safety mode for state access.
    public var threadSafetyMode: ThreadSafetyMode
    
    /// Default configuration with reasonable defaults.
    public static let `default` = StoreConfiguration(
        persistenceEnabled: false,
        timeTravelEnabled: false,
        maxHistorySize: 100,
        loggingEnabled: false,
        threadSafetyMode: .mainActor
    )
    
    /// Debug configuration with all features enabled.
    public static let debug = StoreConfiguration(
        persistenceEnabled: true,
        timeTravelEnabled: true,
        maxHistorySize: 500,
        loggingEnabled: true,
        threadSafetyMode: .serialQueue
    )
    
    /// Production configuration optimized for performance.
    public static let production = StoreConfiguration(
        persistenceEnabled: false,
        timeTravelEnabled: false,
        maxHistorySize: 0,
        loggingEnabled: false,
        threadSafetyMode: .mainActor
    )
    
    public init(
        persistenceEnabled: Bool = false,
        timeTravelEnabled: Bool = false,
        maxHistorySize: Int = 100,
        loggingEnabled: Bool = false,
        threadSafetyMode: ThreadSafetyMode = .mainActor
    ) {
        self.persistenceEnabled = persistenceEnabled
        self.timeTravelEnabled = timeTravelEnabled
        self.maxHistorySize = maxHistorySize
        self.loggingEnabled = loggingEnabled
        self.threadSafetyMode = threadSafetyMode
    }
}

// MARK: - Thread Safety Mode

/// Defines how the store handles thread safety.
public enum ThreadSafetyMode: Sendable {
    /// All state access must occur on the main actor.
    case mainActor
    
    /// State access is protected by a serial dispatch queue.
    case serialQueue
    
    /// No thread safety guarantees (use with caution).
    case none
}

// MARK: - Store Event

/// Events emitted by the store for observation.
public enum StoreEvent<State, Action> {
    case willDispatch(Action)
    case didDispatch(Action, State)
    case willReduce(Action)
    case didReduce(Action, previousState: State, newState: State)
    case effectStarted(id: String?)
    case effectCompleted(id: String?, result: EffectResult)
    case effectCancelled(id: String)
    case stateRestored(State)
    case middlewareIntercepted(Action, by: String)
}

/// Result of an effect execution.
public enum EffectResult {
    case success
    case failure(Error)
    case cancelled
}

// MARK: - Store Subscriber

/// Protocol for subscribing to store changes.
public protocol StoreSubscriber: AnyObject {
    associatedtype State
    associatedtype Action
    
    func storeDidChange(_ state: State, action: Action)
}

/// Type-erased store subscriber.
public final class AnyStoreSubscriber<State, Action> {
    private let _storeDidChange: (State, Action) -> Void
    
    public init<S: StoreSubscriber>(_ subscriber: S) where S.State == State, S.Action == Action {
        _storeDidChange = { [weak subscriber] state, action in
            subscriber?.storeDidChange(state, action: action)
        }
    }
    
    public init(_ handler: @escaping (State, Action) -> Void) {
        _storeDidChange = handler
    }
    
    public func storeDidChange(_ state: State, action: Action) {
        _storeDidChange(state, action)
    }
}

// MARK: - Store Snapshot

/// A snapshot of the store's state at a specific point in time.
public struct StoreSnapshot<State, Action>: Identifiable {
    public let id: UUID
    public let state: State
    public let action: Action?
    public let timestamp: Date
    public let dispatchIndex: Int
    
    public init(
        id: UUID = UUID(),
        state: State,
        action: Action? = nil,
        timestamp: Date = Date(),
        dispatchIndex: Int = 0
    ) {
        self.id = id
        self.state = state
        self.action = action
        self.timestamp = timestamp
        self.dispatchIndex = dispatchIndex
    }
}

// MARK: - Store

/// The central observable store that holds application state and dispatches actions
/// through a reducer pipeline with middleware support.
///
/// The Store is the single source of truth for your application state. It:
/// - Holds the current state
/// - Allows state updates only through actions
/// - Supports middleware for cross-cutting concerns
/// - Handles side effects through the Effect system
/// - Provides time-travel debugging capabilities
///
/// ## Usage
///
/// ```swift
/// // Define your state
/// struct AppState: Equatable {
///     var count: Int = 0
///     var isLoading: Bool = false
/// }
///
/// // Define your actions
/// enum AppAction {
///     case increment
///     case decrement
///     case setLoading(Bool)
/// }
///
/// // Create a reducer
/// let appReducer = Reducer<AppState, AppAction> { state, action in
///     switch action {
///     case .increment:
///         state.count += 1
///         return .none
///     case .decrement:
///         state.count -= 1
///         return .none
///     case .setLoading(let loading):
///         state.isLoading = loading
///         return .none
///     }
/// }
///
/// // Create the store
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     middleware: [LoggingMiddleware()]
/// )
///
/// // Use in SwiftUI
/// struct ContentView: View {
///     @ObservedObject var store: Store<AppState, AppAction>
///
///     var body: some View {
///         VStack {
///             Text("Count: \(store.state.count)")
///             Button("Increment") { store.send(.increment) }
///         }
///     }
/// }
/// ```
@MainActor
public final class Store<State, Action>: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current state of the store, published for SwiftUI observation.
    @Published public private(set) var state: State
    
    /// Whether the store is currently processing one or more effects.
    @Published public private(set) var isProcessingEffects: Bool = false
    
    /// Number of effects currently in flight.
    @Published public private(set) var activeEffectCount: Int = 0
    
    // MARK: - Configuration
    
    /// The store's configuration.
    public let configuration: StoreConfiguration
    
    /// The reducer responsible for state transitions.
    private let reducer: Reducer<State, Action>
    
    /// Middleware pipeline applied before the reducer processes an action.
    private var middlewares: [AnyMiddleware<State, Action>]
    
    // MARK: - Effect Management
    
    /// Active effect cancellables.
    private var effectCancellables: Set<AnyCancellable> = []
    
    /// Tracks cancellable effects by identifier.
    private var cancellableEffects: [String: Task<Void, Never>] = [:]
    
    /// Lock for thread-safe effect management.
    private let effectLock = NSLock()
    
    // MARK: - Thread Safety
    
    /// Serial queue for state mutations to guarantee thread safety.
    private let stateQueue = DispatchQueue(
        label: "com.swiftuistatemanagement.store",
        qos: .userInteractive
    )
    
    // MARK: - Observation
    
    /// Subscribers to state changes.
    private var subscribers: [UUID: AnyStoreSubscriber<State, Action>] = [:]
    
    /// Event handler for store events.
    public var eventHandler: ((StoreEvent<State, Action>) -> Void)?
    
    /// Optional delegate for state change observation.
    public var onStateChange: ((State, Action) -> Void)?
    
    // MARK: - Statistics
    
    /// Count of total dispatched actions (useful for debugging).
    public private(set) var dispatchCount: Int = 0
    
    /// Count of total effects executed.
    public private(set) var effectCount: Int = 0
    
    /// Timestamp of the last dispatched action.
    public private(set) var lastDispatchTime: Date?
    
    // MARK: - Time Travel
    
    /// History of state snapshots for time-travel debugging.
    private var stateHistory: [StoreSnapshot<State, Action>] = []
    
    /// Current position in the history for time-travel.
    private var historyIndex: Int = 0
    
    // MARK: - Logging
    
    /// Logger for store operations.
    private let logger = Logger(subsystem: "SwiftUIStateManagement", category: "Store")
    
    // MARK: - Initialization
    
    /// Creates a new store with the given initial state, reducer, and optional middleware.
    ///
    /// - Parameters:
    ///   - initialState: The starting state for the store.
    ///   - reducer: The reducer that handles state transitions.
    ///   - middleware: An array of middleware to apply in order.
    ///   - configuration: Store configuration options.
    public init(
        initialState: State,
        reducer: Reducer<State, Action>,
        middleware: [AnyMiddleware<State, Action>] = [],
        configuration: StoreConfiguration = .default
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middleware
        self.configuration = configuration
        
        if configuration.timeTravelEnabled {
            recordSnapshot(action: nil)
        }
        
        if configuration.loggingEnabled {
            logger.info("Store initialized with state type: \(String(describing: State.self))")
        }
    }
    
    /// Creates a store with a builder pattern.
    public convenience init(
        initialState: State,
        reducer: Reducer<State, Action>,
        @MiddlewareBuilder<State, Action> middleware: () -> [AnyMiddleware<State, Action>]
    ) {
        self.init(
            initialState: initialState,
            reducer: reducer,
            middleware: middleware()
        )
    }
    
    // MARK: - Dispatching
    
    /// Sends an action through the middleware pipeline and into the reducer.
    ///
    /// - Parameter action: The action to dispatch.
    public func send(_ action: Action) {
        dispatchCount += 1
        lastDispatchTime = Date()
        
        eventHandler?(.willDispatch(action))
        
        if configuration.loggingEnabled {
            logger.debug("Dispatching action #\(self.dispatchCount): \(String(describing: action))")
        }
        
        let middlewareChain = buildMiddlewareChain(action: action)
        middlewareChain(action)
    }
    
    /// Sends multiple actions in sequence.
    ///
    /// - Parameter actions: The actions to dispatch.
    public func send(_ actions: Action...) {
        for action in actions {
            send(action)
        }
    }
    
    /// Sends multiple actions from an array.
    ///
    /// - Parameter actions: The actions to dispatch.
    public func send(contentsOf actions: [Action]) {
        for action in actions {
            send(action)
        }
    }
    
    /// Sends an action and returns after any resulting effects have completed.
    ///
    /// - Parameter action: The action to dispatch.
    /// - Returns: The state after all effects have completed.
    @discardableResult
    public func sendAsync(_ action: Action) async -> State {
        send(action)
        
        // Wait for all effects to complete
        while activeEffectCount > 0 {
            await Task.yield()
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        }
        
        return state
    }
    
    /// Sends an action with a completion handler.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - completion: Called when all resulting effects have completed.
    public func send(_ action: Action, completion: @escaping (State) -> Void) {
        Task {
            let finalState = await sendAsync(action)
            completion(finalState)
        }
    }
    
    /// Sends an action after a delay.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - delay: The delay before dispatching.
    public func send(_ action: Action, after delay: TimeInterval) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            send(action)
        }
    }
    
    /// Sends an action conditionally.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - condition: A closure that determines whether to dispatch.
    public func send(_ action: Action, if condition: (State) -> Bool) {
        if condition(state) {
            send(action)
        }
    }
    
    /// Sends an action unless a condition is met.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - condition: A closure that determines whether to skip dispatching.
    public func send(_ action: Action, unless condition: (State) -> Bool) {
        if !condition(state) {
            send(action)
        }
    }
    
    // MARK: - Middleware Chain
    
    /// Builds the middleware chain, terminating with the reducer.
    private func buildMiddlewareChain(action: Action) -> (Action) -> Void {
        var chain: (Action) -> Void = { [weak self] finalAction in
            self?.reduce(finalAction)
        }
        
        for middleware in middlewares.reversed() {
            let next = chain
            chain = { [weak self] interceptedAction in
                guard let self = self else { return }
                
                self.eventHandler?(.middlewareIntercepted(interceptedAction, by: middleware.name))
                
                middleware.handle(
                    action: interceptedAction,
                    state: self.state,
                    next: next
                )
            }
        }
        
        return chain
    }
    
    // MARK: - Reducing
    
    /// Applies the reducer to produce a new state and handles any resulting effects.
    private func reduce(_ action: Action) {
        eventHandler?(.willReduce(action))
        
        let previousState = state
        let effect = reducer.reduce(&state, action)
        
        eventHandler?(.didReduce(action, previousState: previousState, newState: state))
        
        // Record snapshot for time-travel
        if configuration.timeTravelEnabled {
            recordSnapshot(action: action)
        }
        
        // Notify subscribers
        notifySubscribers(action: action)
        onStateChange?(state, action)
        
        eventHandler?(.didDispatch(action, state))
        
        // Handle effects
        handleEffect(effect)
    }
    
    // MARK: - Effect Handling
    
    /// Processes an effect by executing its async work and dispatching resulting actions.
    private func handleEffect(_ effect: Effect<Action>) {
        switch effect.kind {
        case .none:
            return
            
        case .task(let work):
            executeTask(work, id: effect.id)
            
        case .combine(let effects):
            for childEffect in effects {
                handleEffect(childEffect)
            }
            
        case .cancel(let id):
            cancelEffect(withID: id)
            
        case .debounce(let innerEffect, let duration, let id):
            handleDebounce(innerEffect, duration: duration, id: id)
            
        case .throttle(let innerEffect, let duration, let id):
            handleThrottle(innerEffect, duration: duration, id: id)
        }
    }
    
    /// Executes an async task effect.
    private func executeTask(_ work: @Sendable @escaping () async throws -> Action?, id: String?) {
        effectLock.lock()
        activeEffectCount += 1
        isProcessingEffects = true
        effectCount += 1
        effectLock.unlock()
        
        eventHandler?(.effectStarted(id: id))
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                if let resultAction = try await work() {
                    await MainActor.run {
                        self.send(resultAction)
                    }
                }
                
                await MainActor.run {
                    self.eventHandler?(.effectCompleted(id: id, result: .success))
                }
            } catch is CancellationError {
                await MainActor.run {
                    self.eventHandler?(.effectCompleted(id: id, result: .cancelled))
                }
            } catch {
                if self.configuration.loggingEnabled {
                    self.logger.error("Effect error: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    self.eventHandler?(.effectCompleted(id: id, result: .failure(error)))
                }
            }
            
            await MainActor.run {
                self.effectLock.lock()
                self.activeEffectCount -= 1
                self.isProcessingEffects = self.activeEffectCount > 0
                self.effectLock.unlock()
            }
        }
        
        if let id = id {
            effectLock.lock()
            cancellableEffects[id] = task
            effectLock.unlock()
        }
    }
    
    /// Handles debounce effect.
    private var debounceTimers: [String: Task<Void, Never>] = [:]
    
    private func handleDebounce(_ effect: Effect<Action>, duration: TimeInterval, id: String) {
        debounceTimers[id]?.cancel()
        
        debounceTimers[id] = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self?.handleEffect(effect)
            }
        }
    }
    
    /// Handles throttle effect.
    private var throttleLastExecution: [String: Date] = [:]
    
    private func handleThrottle(_ effect: Effect<Action>, duration: TimeInterval, id: String) {
        let now = Date()
        
        if let lastExecution = throttleLastExecution[id],
           now.timeIntervalSince(lastExecution) < duration {
            return
        }
        
        throttleLastExecution[id] = now
        handleEffect(effect)
    }
    
    // MARK: - Effect Cancellation
    
    /// Cancels an effect with the given identifier.
    public func cancelEffect(withID id: String) {
        effectLock.lock()
        defer { effectLock.unlock() }
        
        if let task = cancellableEffects[id] {
            task.cancel()
            cancellableEffects.removeValue(forKey: id)
            eventHandler?(.effectCancelled(id))
            
            if configuration.loggingEnabled {
                logger.debug("Cancelled effect with ID: \(id)")
            }
        }
    }
    
    /// Cancels all active effects.
    public func cancelAllEffects() {
        effectLock.lock()
        defer { effectLock.unlock() }
        
        for (id, task) in cancellableEffects {
            task.cancel()
            eventHandler?(.effectCancelled(id))
        }
        
        cancellableEffects.removeAll()
        debounceTimers.values.forEach { $0.cancel() }
        debounceTimers.removeAll()
        
        if configuration.loggingEnabled {
            logger.debug("Cancelled all effects")
        }
    }
    
    // MARK: - Middleware Management
    
    /// Appends a middleware to the end of the pipeline.
    public func addMiddleware(_ middleware: AnyMiddleware<State, Action>) {
        middlewares.append(middleware)
    }
    
    /// Inserts a middleware at a specific index.
    public func insertMiddleware(_ middleware: AnyMiddleware<State, Action>, at index: Int) {
        middlewares.insert(middleware, at: index)
    }
    
    /// Removes a middleware by name.
    public func removeMiddleware(named name: String) {
        middlewares.removeAll { $0.name == name }
    }
    
    /// Removes all middleware from the pipeline.
    public func removeAllMiddleware() {
        middlewares.removeAll()
    }
    
    /// Returns the names of all registered middleware.
    public var middlewareNames: [String] {
        middlewares.map(\.name)
    }
    
    // MARK: - Subscription
    
    /// Subscribes to state changes.
    ///
    /// - Parameter subscriber: The subscriber to add.
    /// - Returns: A subscription ID that can be used to unsubscribe.
    @discardableResult
    public func subscribe<S: StoreSubscriber>(
        _ subscriber: S
    ) -> UUID where S.State == State, S.Action == Action {
        let id = UUID()
        subscribers[id] = AnyStoreSubscriber(subscriber)
        return id
    }
    
    /// Subscribes to state changes with a closure.
    ///
    /// - Parameter handler: Called when state changes.
    /// - Returns: A subscription ID that can be used to unsubscribe.
    @discardableResult
    public func subscribe(_ handler: @escaping (State, Action) -> Void) -> UUID {
        let id = UUID()
        subscribers[id] = AnyStoreSubscriber(handler)
        return id
    }
    
    /// Unsubscribes a subscriber.
    ///
    /// - Parameter id: The subscription ID returned from subscribe.
    public func unsubscribe(_ id: UUID) {
        subscribers.removeValue(forKey: id)
    }
    
    /// Notifies all subscribers of a state change.
    private func notifySubscribers(action: Action) {
        for subscriber in subscribers.values {
            subscriber.storeDidChange(state, action: action)
        }
    }
    
    // MARK: - State Access
    
    /// Provides read-only access to a specific property of state.
    ///
    /// - Parameter keyPath: The key path to the desired property.
    /// - Returns: The value at the given key path.
    public func value<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
    
    /// Creates a binding to a state property.
    ///
    /// - Parameters:
    ///   - get: Key path to read the value.
    ///   - action: Action creator for setting the value.
    /// - Returns: A binding that reads from state and dispatches actions.
    public func binding<Value>(
        get keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(action($0)) }
        )
    }
    
    /// Creates a derived binding with custom getter.
    ///
    /// - Parameters:
    ///   - getter: Custom getter closure.
    ///   - action: Action creator for setting the value.
    /// - Returns: A binding using the custom getter.
    public func binding<Value>(
        get getter: @escaping (State) -> Value,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { getter(self.state) },
            set: { self.send(action($0)) }
        )
    }
    
    // MARK: - Time Travel
    
    /// Records a snapshot of the current state.
    private func recordSnapshot(action: Action?) {
        guard configuration.timeTravelEnabled else { return }
        
        let snapshot = StoreSnapshot(
            state: state,
            action: action,
            dispatchIndex: dispatchCount
        )
        
        // Truncate future if we're not at the end
        if historyIndex < stateHistory.count - 1 {
            stateHistory = Array(stateHistory.prefix(historyIndex + 1))
        }
        
        stateHistory.append(snapshot)
        historyIndex = stateHistory.count - 1
        
        // Enforce max history size
        if stateHistory.count > configuration.maxHistorySize {
            stateHistory.removeFirst()
            historyIndex -= 1
        }
    }
    
    /// Travels to a specific point in state history.
    ///
    /// - Parameter index: The history index to travel to.
    public func timeTravel(to index: Int) {
        guard configuration.timeTravelEnabled else {
            if configuration.loggingEnabled {
                logger.warning("Time travel not enabled in configuration")
            }
            return
        }
        
        guard index >= 0 && index < stateHistory.count else { return }
        
        historyIndex = index
        state = stateHistory[index].state
        eventHandler?(.stateRestored(state))
        
        if configuration.loggingEnabled {
            logger.debug("Time traveled to snapshot \(index)")
        }
    }
    
    /// Travels back one step in history.
    public func stepBack() {
        timeTravel(to: historyIndex - 1)
    }
    
    /// Travels forward one step in history.
    public func stepForward() {
        timeTravel(to: historyIndex + 1)
    }
    
    /// Travels to the beginning of history.
    public func goToStart() {
        timeTravel(to: 0)
    }
    
    /// Travels to the end of history (current state).
    public func goToEnd() {
        timeTravel(to: stateHistory.count - 1)
    }
    
    /// Returns the current history index.
    public var currentHistoryIndex: Int {
        historyIndex
    }
    
    /// Returns the total number of history entries.
    public var historyCount: Int {
        stateHistory.count
    }
    
    /// Returns all state snapshots.
    public var snapshots: [StoreSnapshot<State, Action>] {
        stateHistory
    }
    
    /// Clears all history.
    public func clearHistory() {
        stateHistory = []
        historyIndex = 0
        
        if configuration.timeTravelEnabled {
            recordSnapshot(action: nil)
        }
    }
    
    // MARK: - State Reset
    
    /// Resets the store to a new state.
    ///
    /// - Parameter newState: The new state to set.
    public func reset(to newState: State) {
        cancelAllEffects()
        state = newState
        
        if configuration.timeTravelEnabled {
            clearHistory()
            recordSnapshot(action: nil)
        }
        
        if configuration.loggingEnabled {
            logger.info("Store reset to new state")
        }
    }
    
    // MARK: - Scoping
    
    /// Creates a derived store scoped to a subset of state and actions.
    ///
    /// - Parameters:
    ///   - state: Key path to child state.
    ///   - action: Function to extract child action from parent action.
    ///   - embed: Function to embed child action into parent action.
    /// - Returns: A scoped store view.
    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action fromLocalAction: @escaping (LocalAction) -> Action
    ) -> ScopedStore<State, Action, LocalState, LocalAction> {
        ScopedStore(
            parent: self,
            toLocalState: toLocalState,
            fromLocalAction: fromLocalAction
        )
    }
    
    /// Creates a scoped store using key paths.
    public func scope<LocalState>(
        state keyPath: KeyPath<State, LocalState>
    ) -> StateOnlyScope<State, Action, LocalState> {
        StateOnlyScope(parent: self, keyPath: keyPath)
    }
}

// MARK: - Store Extensions

extension Store where State: Equatable {
    /// Waits until state matches a predicate.
    ///
    /// - Parameters:
    ///   - predicate: The condition to wait for.
    ///   - timeout: Maximum time to wait.
    /// - Returns: True if condition was met, false if timed out.
    public func waitUntil(
        _ predicate: @escaping (State) -> Bool,
        timeout: TimeInterval = 10
    ) async -> Bool {
        if predicate(state) { return true }
        
        let deadline = Date().addingTimeInterval(timeout)
        
        while Date() < deadline {
            if predicate(state) { return true }
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
        
        return predicate(state)
    }
}

extension Store where State: Codable {
    /// Exports the current state as JSON data.
    public func exportState() throws -> Data {
        try JSONEncoder().encode(state)
    }
    
    /// Imports state from JSON data.
    public func importState(from data: Data) throws {
        let newState = try JSONDecoder().decode(State.self, from: data)
        reset(to: newState)
    }
}

// MARK: - ScopedStore

/// A store scoped to a subset of parent state and actions.
@MainActor
public final class ScopedStore<ParentState, ParentAction, LocalState, LocalAction>: ObservableObject {
    
    private let parent: Store<ParentState, ParentAction>
    private let toLocalState: (ParentState) -> LocalState
    private let fromLocalAction: (LocalAction) -> ParentAction
    private var cancellable: AnyCancellable?
    
    @Published public private(set) var state: LocalState
    
    public init(
        parent: Store<ParentState, ParentAction>,
        toLocalState: @escaping (ParentState) -> LocalState,
        fromLocalAction: @escaping (LocalAction) -> ParentAction
    ) {
        self.parent = parent
        self.toLocalState = toLocalState
        self.fromLocalAction = fromLocalAction
        self.state = toLocalState(parent.state)
        
        cancellable = parent.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.state = self.toLocalState(self.parent.state)
            }
    }
    
    public func send(_ action: LocalAction) {
        parent.send(fromLocalAction(action))
    }
    
    public func binding<Value>(
        get keyPath: KeyPath<LocalState, Value>,
        send action: @escaping (Value) -> LocalAction
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(action($0)) }
        )
    }
}

// MARK: - StateOnlyScope

/// A store scoped to a subset of parent state only.
@MainActor
public final class StateOnlyScope<ParentState, ParentAction, LocalState>: ObservableObject {
    
    private let parent: Store<ParentState, ParentAction>
    private let keyPath: KeyPath<ParentState, LocalState>
    private var cancellable: AnyCancellable?
    
    @Published public private(set) var state: LocalState
    
    public init(
        parent: Store<ParentState, ParentAction>,
        keyPath: KeyPath<ParentState, LocalState>
    ) {
        self.parent = parent
        self.keyPath = keyPath
        self.state = parent.state[keyPath: keyPath]
        
        cancellable = parent.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.state = self.parent.state[keyPath: self.keyPath]
            }
    }
    
    public func send(_ action: ParentAction) {
        parent.send(action)
    }
}

// MARK: - Middleware Builder

/// Result builder for constructing middleware arrays.
@resultBuilder
public struct MiddlewareBuilder<State, Action> {
    public static func buildBlock(_ components: AnyMiddleware<State, Action>...) -> [AnyMiddleware<State, Action>] {
        components
    }
    
    public static func buildOptional(_ component: [AnyMiddleware<State, Action>]?) -> [AnyMiddleware<State, Action>] {
        component ?? []
    }
    
    public static func buildEither(first component: [AnyMiddleware<State, Action>]) -> [AnyMiddleware<State, Action>] {
        component
    }
    
    public static func buildEither(second component: [AnyMiddleware<State, Action>]) -> [AnyMiddleware<State, Action>] {
        component
    }
    
    public static func buildArray(_ components: [[AnyMiddleware<State, Action>]]) -> [AnyMiddleware<State, Action>] {
        components.flatMap { $0 }
    }
}
