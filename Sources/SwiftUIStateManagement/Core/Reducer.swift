import Foundation

// MARK: - Reducer

/// A pure function that takes the current state and an action, then returns
/// a new state along with any side effects to execute.
///
/// Reducers are the only place where state mutations should occur.
/// They must be deterministic — given the same state and action,
/// they must always produce the same result.
///
/// ## Basic Usage
///
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
///
/// ## Composition
///
/// ```swift
/// let appReducer = Reducer<AppState, AppAction>.combine(
///     counterReducer.pullback(state: \.counter, action: /AppAction.counter),
///     userReducer.pullback(state: \.user, action: /AppAction.user)
/// )
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
    
    /// Creates an empty reducer that does nothing.
    public static var empty: Reducer {
        Reducer { _, _ in .none }
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
    
    /// Convenience operator for reduce.
    public func callAsFunction(_ state: inout State, _ action: Action) -> Effect<Action> {
        reduce(&state, action)
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
            return .merge(effect1, effect2)
        }
    }
    
    /// Combines multiple reducers into one.
    ///
    /// - Parameter reducers: The reducers to combine.
    /// - Returns: A single reducer that runs all reducers in sequence.
    public static func combine(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
        combine(reducers)
    }
    
    /// Combines an array of reducers into one.
    ///
    /// - Parameter reducers: The reducers to combine.
    /// - Returns: A single reducer that runs all reducers in sequence.
    public static func combine(_ reducers: [Reducer<State, Action>]) -> Reducer<State, Action> {
        guard !reducers.isEmpty else { return .empty }
        
        return Reducer { state, action in
            var effects: [Effect<Action>] = []
            for reducer in reducers {
                let effect = reducer.reduce(&state, action)
                effects.append(effect)
            }
            return .merge(effects)
        }
    }
    
    /// Combines this reducer with another using the + operator.
    public static func + (lhs: Reducer, rhs: Reducer) -> Reducer {
        lhs.combined(with: rhs)
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
    
    /// Pulls back this reducer to work on parent state using key paths.
    ///
    /// - Parameters:
    ///   - state: Writable key path from parent to child state.
    ///   - action: Case path from parent action to child action.
    /// - Returns: A reducer that operates on the parent state.
    public func pullback<ParentState, ParentAction>(
        state: WritableKeyPath<ParentState, State>,
        action extract: @escaping (ParentAction) -> Action?,
        embed: @escaping (Action) -> ParentAction
    ) -> Reducer<ParentState, ParentAction> {
        Reducer<ParentState, ParentAction>.pullback(
            self,
            state: state,
            action: extract,
            embed: embed
        )
    }
    
    /// Pulls back this reducer for optional child state.
    ///
    /// - Parameters:
    ///   - state: Writable key path to optional child state.
    ///   - action: Extracts child action from parent action.
    ///   - embed: Embeds child action into parent action.
    /// - Returns: A reducer that operates on optional child state.
    public func optional<ParentState, ParentAction>(
        state: WritableKeyPath<ParentState, State?>,
        action extract: @escaping (ParentAction) -> Action?,
        embed: @escaping (Action) -> ParentAction
    ) -> Reducer<ParentState, ParentAction> {
        Reducer<ParentState, ParentAction> { parentState, parentAction in
            guard let childAction = extract(parentAction),
                  parentState[keyPath: state] != nil else {
                return .none
            }
            
            var childState = parentState[keyPath: state]!
            let effect = self.reduce(&childState, childAction)
            parentState[keyPath: state] = childState
            
            return effect.map(embed)
        }
    }
    
    /// Creates a reducer for a collection of child states.
    ///
    /// - Parameters:
    ///   - state: Key path to the collection of child states.
    ///   - action: Extracts (index, child action) from parent action.
    ///   - embed: Embeds (index, child action) into parent action.
    /// - Returns: A reducer that operates on each element.
    public func forEach<ParentState, ParentAction, ID: Hashable>(
        state: WritableKeyPath<ParentState, IdentifiedArray<ID, State>>,
        action extract: @escaping (ParentAction) -> (ID, Action)?,
        embed: @escaping (ID, Action) -> ParentAction
    ) -> Reducer<ParentState, ParentAction> {
        Reducer<ParentState, ParentAction> { parentState, parentAction in
            guard let (id, childAction) = extract(parentAction),
                  let index = parentState[keyPath: state].index(id: id) else {
                return .none
            }
            
            let effect = self.reduce(&parentState[keyPath: state][index], childAction)
            return effect.map { embed(id, $0) }
        }
    }
    
    // MARK: - Filtering
    
    /// Creates a reducer that only processes actions matching a predicate.
    ///
    /// - Parameter predicate: Returns true if the action should be processed.
    /// - Returns: A filtered reducer.
    public func filter(_ predicate: @escaping (Action) -> Bool) -> Reducer {
        Reducer { state, action in
            guard predicate(action) else { return .none }
            return self.reduce(&state, action)
        }
    }
    
    /// Creates a reducer that only processes actions when state matches a predicate.
    ///
    /// - Parameter predicate: Returns true if the reducer should process.
    /// - Returns: A filtered reducer.
    public func when(_ predicate: @escaping (State) -> Bool) -> Reducer {
        Reducer { state, action in
            guard predicate(state) else { return .none }
            return self.reduce(&state, action)
        }
    }
    
    // MARK: - Debugging
    
    /// Adds logging to this reducer.
    ///
    /// - Parameter prefix: Optional prefix for log messages.
    /// - Returns: A reducer that logs actions and state changes.
    public func debug(prefix: String = "") -> Reducer {
        Reducer { state, action in
            let actionPrefix = prefix.isEmpty ? "" : "[\(prefix)] "
            print("\(actionPrefix)Action: \(action)")
            
            let previousState = state
            let effect = self.reduce(&state, action)
            
            if let prev = previousState as? any Equatable,
               let curr = state as? any Equatable,
               !areEqual(prev, curr) {
                print("\(actionPrefix)State changed")
            }
            
            return effect
        }
    }
    
    // MARK: - Transformations
    
    /// Maps the effect actions produced by this reducer.
    ///
    /// - Parameter transform: Transforms the effect action.
    /// - Returns: A reducer with transformed effect actions.
    public func mapEffects(_ transform: @escaping (Action) -> Action) -> Reducer {
        Reducer { state, action in
            let effect = self.reduce(&state, action)
            return effect.map(transform)
        }
    }
    
    /// Wraps this reducer with before/after hooks.
    ///
    /// - Parameters:
    ///   - before: Called before the reducer runs.
    ///   - after: Called after the reducer runs.
    /// - Returns: A wrapped reducer.
    public func hook(
        before: ((State, Action) -> Void)? = nil,
        after: ((State, Action) -> Void)? = nil
    ) -> Reducer {
        Reducer { state, action in
            before?(state, action)
            let effect = self.reduce(&state, action)
            after?(state, action)
            return effect
        }
    }
}

// MARK: - Helpers

private func areEqual(_ lhs: any Equatable, _ rhs: any Equatable) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    
    func isEqual<T: Equatable>(_ a: T, _ b: any Equatable) -> Bool {
        guard let b = b as? T else { return false }
        return a == b
    }
    
    return isEqual(lhs, rhs)
}

// MARK: - IdentifiedArray

/// A collection that maintains stable identities for its elements.
public struct IdentifiedArray<ID: Hashable, Element>: MutableCollection, RandomAccessCollection {
    
    public typealias Index = Int
    
    private var elements: [Element]
    private var ids: [ID]
    private let id: (Element) -> ID
    
    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    
    public init(_ elements: [Element] = [], id: @escaping (Element) -> ID) {
        self.elements = elements
        self.id = id
        self.ids = elements.map(id)
    }
    
    public subscript(position: Int) -> Element {
        get { elements[position] }
        set {
            elements[position] = newValue
            ids[position] = id(newValue)
        }
    }
    
    public func index(after i: Int) -> Int {
        elements.index(after: i)
    }
    
    public func index(id: ID) -> Int? {
        ids.firstIndex(of: id)
    }
    
    public subscript(id id: ID) -> Element? {
        get {
            guard let index = index(id: id) else { return nil }
            return elements[index]
        }
        set {
            guard let index = index(id: id) else { return }
            if let newValue = newValue {
                elements[index] = newValue
            } else {
                elements.remove(at: index)
                ids.remove(at: index)
            }
        }
    }
    
    public mutating func append(_ element: Element) {
        elements.append(element)
        ids.append(id(element))
    }
    
    public mutating func remove(id: ID) {
        guard let index = index(id: id) else { return }
        elements.remove(at: index)
        ids.remove(at: index)
    }
}

extension IdentifiedArray: Equatable where Element: Equatable {}
extension IdentifiedArray: Hashable where Element: Hashable {}
extension IdentifiedArray: Sendable where Element: Sendable, ID: Sendable {}

extension IdentifiedArray where Element: Identifiable, Element.ID == ID {
    public init(_ elements: [Element] = []) {
        self.init(elements, id: \.id)
    }
}

// MARK: - Reducer Builder

/// Result builder for composing reducers declaratively.
@resultBuilder
public struct ReducerBuilder<State, Action> {
    public static func buildBlock(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
        .combine(reducers)
    }
    
    public static func buildOptional(_ reducer: Reducer<State, Action>?) -> Reducer<State, Action> {
        reducer ?? .empty
    }
    
    public static func buildEither(first reducer: Reducer<State, Action>) -> Reducer<State, Action> {
        reducer
    }
    
    public static func buildEither(second reducer: Reducer<State, Action>) -> Reducer<State, Action> {
        reducer
    }
    
    public static func buildArray(_ reducers: [Reducer<State, Action>]) -> Reducer<State, Action> {
        .combine(reducers)
    }
}

extension Reducer {
    /// Creates a combined reducer using a result builder.
    public static func build(
        @ReducerBuilder<State, Action> _ builder: () -> Reducer<State, Action>
    ) -> Reducer<State, Action> {
        builder()
    }
}
