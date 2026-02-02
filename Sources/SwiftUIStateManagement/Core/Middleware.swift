import Foundation

// MARK: - AnyMiddleware

/// A type-erased middleware that can intercept actions before they reach
/// the reducer, enabling cross-cutting concerns like logging, analytics,
/// and authentication checks.
///
/// Usage:
/// ```swift
/// struct LoggingMiddleware<S, A>: MiddlewareProtocol {
///     func handle(action: A, state: S, next: @escaping (A) -> Void) {
///         print("Action: \(action)")
///         next(action)
///     }
/// }
/// ```
public struct AnyMiddleware<State, Action> {

    // MARK: - Properties

    private let _handle: (Action, State, @escaping (Action) -> Void) -> Void

    // MARK: - Initialization

    /// Creates a type-erased middleware from a closure.
    ///
    /// - Parameter handler: The middleware handler closure.
    public init(_ handler: @escaping (Action, State, @escaping (Action) -> Void) -> Void) {
        self._handle = handler
    }

    /// Creates a type-erased middleware from a `MiddlewareProtocol` conformant.
    public init<M: MiddlewareProtocol>(_ middleware: M) where M.State == State, M.Action == Action {
        self._handle = middleware.handle
    }

    // MARK: - Handling

    /// Processes the action, optionally forwarding it to the next handler.
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        _handle(action, state, next)
    }
}

// MARK: - MiddlewareProtocol

/// Protocol for creating strongly-typed middleware.
public protocol MiddlewareProtocol {
    associatedtype State
    associatedtype Action

    /// Handles an incoming action with access to current state.
    ///
    /// - Parameters:
    ///   - action: The dispatched action.
    ///   - state: The current state snapshot.
    ///   - next: Call this to forward the action to the next middleware/reducer.
    func handle(action: Action, state: State, next: @escaping (Action) -> Void)
}

// MARK: - Predefined Middleware

/// A middleware that conditionally blocks actions based on a predicate.
public struct FilterMiddleware<State, Action>: MiddlewareProtocol {

    private let predicate: (Action, State) -> Bool

    /// Creates a filter middleware.
    /// Actions are forwarded only if the predicate returns `true`.
    public init(predicate: @escaping (Action, State) -> Bool) {
        self.predicate = predicate
    }

    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        if predicate(action, state) {
            next(action)
        }
    }
}

/// A middleware that transforms actions before forwarding.
public struct MapMiddleware<State, Action>: MiddlewareProtocol {

    private let transform: (Action, State) -> Action

    public init(transform: @escaping (Action, State) -> Action) {
        self.transform = transform
    }

    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        let transformed = transform(action, state)
        next(transformed)
    }
}
