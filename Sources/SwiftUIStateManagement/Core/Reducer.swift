import Foundation

// MARK: - Reducer

/// A pure function that takes the current state and an action, then returns
/// a new state along with any side effects to execute.
///
/// Reducers are the only place where state mutations should occur.
/// They must be deterministic — given the same state and action,
/// they must always produce the same result.
///
/// Usage:
/// ```swift
/// let reducer = Reducer<AppState, AppAction> { state, action in
///     switch action {
///     case .increment:
///         state.count += 1
///         return .none
///     case .decrement:
///         state.count -= 1
///         return .none
///     }
/// }
/// ```
public struct Reducer<State, Action> {

    // MARK: - Properties

    /// The underlying reduce function.
    private let _reduce: (inout State, Action) -> Effect<Action>

    // MARK: - Initialization

    /// Creates a reducer with the given reduce closure.
    ///
    /// - Parameter reduce: A closure `(inout State, Action) -> Effect<Action>`.
    public init(_ reduce: @escaping (inout State, Action) -> Effect<Action>) {
        self._reduce = reduce
    }

    // MARK: - Reducing

    /// Applies this reducer to produce a new state and optional effects.
    ///
    /// - Parameters:
    ///   - state: The current state (mutated in place).
    ///   - action: The action to process.
    /// - Returns: An effect to execute after the state transition.
    public func reduce(_ state: inout State, _ action: Action) -> Effect<Action> {
        _reduce(&state, action)
    }

    // MARK: - Composition

    /// Combines this reducer with another, running both in sequence.
    ///
    /// - Parameter other: The reducer to combine with.
    /// - Returns: A new reducer that runs both reducers.
    public func combined(with other: Reducer<State, Action>) -> Reducer<State, Action> {
        Reducer { state, action in
            let effect1 = self.reduce(&state, action)
            let effect2 = other.reduce(&state, action)
            return .merge([effect1, effect2])
        }
    }

    /// Pulls back a child reducer to work on parent state.
    ///
    /// - Parameters:
    ///   - stateKeyPath: Writable key path from parent to child state.
    ///   - actionTransform: Extracts child action from parent action.
    ///   - actionEmbed: Embeds child action into parent action.
    /// - Returns: A reducer that operates on the parent state.
    public static func pullback<ParentState, ParentAction>(
        _ childReducer: Reducer<State, Action>,
        state stateKeyPath: WritableKeyPath<ParentState, State>,
        action actionTransform: @escaping (ParentAction) -> Action?,
        embed actionEmbed: @escaping (Action) -> ParentAction
    ) -> Reducer<ParentState, ParentAction> {
        Reducer<ParentState, ParentAction> { parentState, parentAction in
            guard let childAction = actionTransform(parentAction) else {
                return .none
            }
            let effect = childReducer.reduce(&parentState[keyPath: stateKeyPath], childAction)
            return effect.map(actionEmbed)
        }
    }
}
