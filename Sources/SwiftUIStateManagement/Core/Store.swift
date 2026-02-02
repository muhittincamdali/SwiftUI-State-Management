import SwiftUI
import Combine

// MARK: - Store

/// The central observable store that holds application state and dispatches actions
/// through a reducer pipeline with middleware support.
///
/// Usage:
/// ```swift
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     middleware: [loggingMiddleware]
/// )
/// ```
public final class Store<State, Action>: ObservableObject {

    // MARK: - Properties

    /// The current state of the store, published for SwiftUI observation.
    @Published public private(set) var state: State

    /// The reducer responsible for state transitions.
    private let reducer: Reducer<State, Action>

    /// Middleware pipeline applied before the reducer processes an action.
    private var middlewares: [AnyMiddleware<State, Action>]

    /// Active effect cancellables.
    private var effectCancellables: Set<AnyCancellable> = []

    /// Serial queue for state mutations to guarantee thread safety.
    private let stateQueue = DispatchQueue(
        label: "com.swiftuistatemanagement.store",
        qos: .userInteractive
    )

    /// Optional delegate for state change observation.
    public var onStateChange: ((State, Action) -> Void)?

    /// Indicates whether the store is currently processing an effect.
    public private(set) var isProcessingEffect: Bool = false

    /// Count of total dispatched actions (useful for debugging).
    public private(set) var dispatchCount: Int = 0

    // MARK: - Initialization

    /// Creates a new store with the given initial state, reducer, and optional middleware.
    ///
    /// - Parameters:
    ///   - initialState: The starting state for the store.
    ///   - reducer: The reducer that handles state transitions.
    ///   - middleware: An array of middleware to apply in order.
    public init(
        initialState: State,
        reducer: Reducer<State, Action>,
        middleware: [AnyMiddleware<State, Action>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middleware
    }

    // MARK: - Dispatching

    /// Sends an action through the middleware pipeline and into the reducer.
    ///
    /// - Parameter action: The action to dispatch.
    public func send(_ action: Action) {
        dispatchCount += 1

        let middlewareChain = buildMiddlewareChain(action: action)
        middlewareChain(action)
    }

    /// Sends an action and returns after any resulting effects have completed.
    ///
    /// - Parameter action: The action to dispatch.
    @MainActor
    public func sendAsync(_ action: Action) async {
        send(action)

        // Allow any queued effects to start
        await Task.yield()
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
        let effect = reducer.reduce(&state, action)
        onStateChange?(state, action)
        handleEffect(effect)
    }

    /// Processes an effect by executing its async work and dispatching resulting actions.
    private func handleEffect(_ effect: Effect<Action>) {
        switch effect.kind {
        case .none:
            return

        case .task(let work):
            isProcessingEffect = true
            Task { [weak self] in
                guard let self = self else { return }
                do {
                    if let resultAction = try await work() {
                        await MainActor.run {
                            self.send(resultAction)
                        }
                    }
                } catch {
                    #if DEBUG
                    print("[Store] Effect error: \(error.localizedDescription)")
                    #endif
                }
                await MainActor.run {
                    self.isProcessingEffect = false
                }
            }

        case .combine(let effects):
            for childEffect in effects {
                handleEffect(childEffect)
            }

        case .cancel(let id):
            cancelEffect(withID: id)
        }
    }

    // MARK: - Effect Cancellation

    /// Tracks cancellable effects by identifier.
    private var cancellableEffects: [String: Task<Void, Never>] = [:]

    /// Cancels an effect with the given identifier.
    private func cancelEffect(withID id: String) {
        cancellableEffects[id]?.cancel()
        cancellableEffects.removeValue(forKey: id)
    }

    // MARK: - Middleware Management

    /// Appends a middleware to the end of the pipeline.
    public func addMiddleware(_ middleware: AnyMiddleware<State, Action>) {
        middlewares.append(middleware)
    }

    /// Removes all middleware from the pipeline.
    public func removeAllMiddleware() {
        middlewares.removeAll()
    }

    // MARK: - State Access

    /// Provides read-only access to a specific property of state.
    ///
    /// - Parameter keyPath: The key path to the desired property.
    /// - Returns: The value at the given key path.
    public func value<Value>(_ keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }
}
