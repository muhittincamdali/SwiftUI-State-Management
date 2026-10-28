/// The logic of a feature: how an action changes the state, and which work it starts.
///
/// A reducer is the one place where a feature's state changes. It receives the current state as
/// `inout`, changes it synchronously, and returns an ``Effect`` that describes the asynchronous
/// work to start, such as a network request whose response comes back as another action.
///
/// ```swift
/// struct Counter: Reducer {
///     struct State: Equatable {
///         var count = 0
///     }
///
///     enum Action {
///         case incrementTapped
///         case decrementTapped
///     }
///
///     func reduce(into state: inout State, action: Action) -> Effect<Action> {
///         switch action {
///         case .incrementTapped:
///             state.count += 1
///             return .none
///         case .decrementTapped:
///             state.count -= 1
///             return .none
///         }
///     }
/// }
/// ```
///
/// Dependencies such as an API client or a clock are ordinary stored properties of the reducer,
/// passed in by whoever creates it. Tests pass fakes the same way.
public protocol Reducer<State, Action> {
    /// The state the reducer changes.
    associatedtype State
    /// The events the reducer handles: user input, and the results of effects.
    associatedtype Action

    /// Changes `state` for `action` and returns the work to start next.
    ///
    /// Keep this method free of side effects: read and write only `state` and the reducer's own
    /// properties, and put anything asynchronous or observable from outside into the returned
    /// ``Effect``.
    @MainActor
    func reduce(into state: inout State, action: Action) -> Effect<Action>
}

/// A reducer made from a closure.
///
/// Use it for small features, or to combine a few lines of logic with other reducers without
/// declaring a type:
///
/// ```swift
/// let counter = Reduce<Int, CounterAction> { count, action in
///     switch action {
///     case .increment: count += 1
///     case .decrement: count -= 1
///     }
///     return .none
/// }
/// ```
public struct Reduce<State, Action>: Reducer {
    private let body: @MainActor (inout State, Action) -> Effect<Action>

    /// Creates a reducer that runs `body` for every action.
    public init(_ body: @escaping @MainActor (_ state: inout State, _ action: Action) -> Effect<Action>) {
        self.body = body
    }

    @MainActor
    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        body(&state, action)
    }
}

extension Reducer {
    /// Returns a reducer that runs this reducer and then `other` for every action, and merges
    /// their effects.
    ///
    /// Use it to run a child feature's reducer (``Scope``) next to the parent's own logic:
    ///
    /// ```swift
    /// let app = AppLogic().combined(with: Scope(
    ///     state: \.settings,
    ///     action: { if case .settings(let action) = $0 { action } else { nil } },
    ///     embed: AppAction.settings,
    ///     child: SettingsLogic()
    /// ))
    /// ```
    public func combined<Other: Reducer>(with other: Other) -> CombinedReducer<Self, Other>
    where Other.State == State, Other.Action == Action {
        CombinedReducer(first: self, second: other)
    }
}

/// Two reducers that run one after the other for every action. Made by
/// ``Reducer/combined(with:)``.
public struct CombinedReducer<First: Reducer, Second: Reducer>: Reducer
where First.State == Second.State, First.Action == Second.Action {
    let first: First
    let second: Second

    @MainActor
    public func reduce(into state: inout First.State, action: First.Action) -> Effect<First.Action> {
        let firstEffect = first.reduce(into: &state, action: action)
        let secondEffect = second.reduce(into: &state, action: action)
        return firstEffect.merge(with: secondEffect)
    }
}

/// Runs a child feature's reducer on part of a parent's state.
///
/// For each parent action that `action` turns into a child action, `Scope` runs `child` on the
/// state at `state` and turns the child's effects back into parent actions with `embed`. Other
/// actions pass through unchanged.
public struct Scope<ParentState, ParentAction, Child: Reducer>: Reducer {
    let toChildState: WritableKeyPath<ParentState, Child.State>
    let toChildAction: (ParentAction) -> Child.Action?
    let embed: @MainActor @Sendable (Child.Action) -> ParentAction
    let child: Child

    /// Creates a reducer that runs `child` on `state`.
    ///
    /// - Parameters:
    ///   - state: The path from the parent state to the child state.
    ///   - action: Returns the child action inside a parent action, or `nil` for other actions.
    ///   - embed: Wraps a child action in a parent action, usually an enum case such as
    ///     `AppAction.settings`.
    ///   - child: The child feature's reducer.
    public init(
        state: WritableKeyPath<ParentState, Child.State>,
        action: @escaping (ParentAction) -> Child.Action?,
        embed: @escaping @MainActor @Sendable (Child.Action) -> ParentAction,
        child: Child
    ) {
        self.toChildState = state
        self.toChildAction = action
        self.embed = embed
        self.child = child
    }

    @MainActor
    public func reduce(into state: inout ParentState, action: ParentAction) -> Effect<ParentAction> {
        guard let childAction = toChildAction(action) else { return .none }
        return child.reduce(into: &state[keyPath: toChildState], action: childAction).map(embed)
    }
}
