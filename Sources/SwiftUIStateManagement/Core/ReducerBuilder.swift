// ReducerBuilder.swift
// SwiftUI-State-Management
//
// A powerful result builder for composing reducers in a declarative way.
// Supports conditional logic, loops, and reducer composition.

import Foundation

// MARK: - ReducerBuilder

/// A result builder that enables declarative composition of reducers.
///
/// `ReducerBuilder` allows you to compose multiple reducers using Swift's
/// result builder syntax, making it easy to build complex state management
/// logic from smaller, reusable pieces.
///
/// Example usage:
/// ```swift
/// @ReducerBuilder<AppState, AppAction>
/// var appReducer: some Reducer<AppState, AppAction> {
///     UserReducer()
///     SettingsReducer()
///     if featureFlags.analyticsEnabled {
///         AnalyticsReducer()
///     }
/// }
/// ```
@resultBuilder
public struct ReducerBuilder<State, Action> {
    
    // MARK: - Basic Building Blocks
    
    /// Builds an empty reducer that performs no state changes.
    @inlinable
    public static func buildBlock() -> EmptyReducer<State, Action> {
        EmptyReducer()
    }
    
    /// Builds a single reducer expression.
    @inlinable
    public static func buildBlock<R: Reducer>(
        _ reducer: R
    ) -> R where R.State == State, R.Action == Action {
        reducer
    }
    
    /// Combines two reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer>(
        _ r0: R0,
        _ r1: R1
    ) -> CombinedReducer2<R0, R1>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action {
        CombinedReducer2(r0, r1)
    }
    
    /// Combines three reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2
    ) -> CombinedReducer3<R0, R1, R2>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action {
        CombinedReducer3(r0, r1, r2)
    }
    
    /// Combines four reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2,
        _ r3: R3
    ) -> CombinedReducer4<R0, R1, R2, R3>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action,
          R3.State == State, R3.Action == Action {
        CombinedReducer4(r0, r1, r2, r3)
    }
    
    /// Combines five reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2,
        _ r3: R3,
        _ r4: R4
    ) -> CombinedReducer5<R0, R1, R2, R3, R4>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action,
          R3.State == State, R3.Action == Action,
          R4.State == State, R4.Action == Action {
        CombinedReducer5(r0, r1, r2, r3, r4)
    }
    
    /// Combines six reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2,
        _ r3: R3,
        _ r4: R4,
        _ r5: R5
    ) -> CombinedReducer6<R0, R1, R2, R3, R4, R5>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action,
          R3.State == State, R3.Action == Action,
          R4.State == State, R4.Action == Action,
          R5.State == State, R5.Action == Action {
        CombinedReducer6(r0, r1, r2, r3, r4, r5)
    }
    
    /// Combines seven reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer, R6: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2,
        _ r3: R3,
        _ r4: R4,
        _ r5: R5,
        _ r6: R6
    ) -> CombinedReducer7<R0, R1, R2, R3, R4, R5, R6>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action,
          R3.State == State, R3.Action == Action,
          R4.State == State, R4.Action == Action,
          R5.State == State, R5.Action == Action,
          R6.State == State, R6.Action == Action {
        CombinedReducer7(r0, r1, r2, r3, r4, r5, r6)
    }
    
    /// Combines eight reducers into a single composed reducer.
    @inlinable
    public static func buildBlock<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer, R6: Reducer, R7: Reducer>(
        _ r0: R0,
        _ r1: R1,
        _ r2: R2,
        _ r3: R3,
        _ r4: R4,
        _ r5: R5,
        _ r6: R6,
        _ r7: R7
    ) -> CombinedReducer8<R0, R1, R2, R3, R4, R5, R6, R7>
    where R0.State == State, R0.Action == Action,
          R1.State == State, R1.Action == Action,
          R2.State == State, R2.Action == Action,
          R3.State == State, R3.Action == Action,
          R4.State == State, R4.Action == Action,
          R5.State == State, R5.Action == Action,
          R6.State == State, R6.Action == Action,
          R7.State == State, R7.Action == Action {
        CombinedReducer8(r0, r1, r2, r3, r4, r5, r6, r7)
    }
    
    // MARK: - Conditional Building
    
    /// Builds a reducer from an optional component.
    @inlinable
    public static func buildOptional<R: Reducer>(
        _ component: R?
    ) -> OptionalReducer<R> where R.State == State, R.Action == Action {
        OptionalReducer(component)
    }
    
    /// Builds a reducer from the first branch of an if-else.
    @inlinable
    public static func buildEither<First: Reducer, Second: Reducer>(
        first: First
    ) -> ConditionalReducer<First, Second>
    where First.State == State, First.Action == Action,
          Second.State == State, Second.Action == Action {
        .first(first)
    }
    
    /// Builds a reducer from the second branch of an if-else.
    @inlinable
    public static func buildEither<First: Reducer, Second: Reducer>(
        second: Second
    ) -> ConditionalReducer<First, Second>
    where First.State == State, First.Action == Action,
          Second.State == State, Second.Action == Action {
        .second(second)
    }
    
    /// Builds a reducer from an array of components.
    @inlinable
    public static func buildArray<R: Reducer>(
        _ components: [R]
    ) -> ReducerArray<R> where R.State == State, R.Action == Action {
        ReducerArray(components)
    }
    
    /// Enables availability checks within the builder.
    @inlinable
    public static func buildLimitedAvailability<R: Reducer>(
        _ component: R
    ) -> R where R.State == State, R.Action == Action {
        component
    }
    
    /// Transforms an expression into a reducer.
    @inlinable
    public static func buildExpression<R: Reducer>(
        _ expression: R
    ) -> R where R.State == State, R.Action == Action {
        expression
    }
    
    /// Builds the final result from a component.
    @inlinable
    public static func buildFinalResult<R: Reducer>(
        _ component: R
    ) -> R where R.State == State, R.Action == Action {
        component
    }
}

// MARK: - EmptyReducer

/// A reducer that performs no state changes and produces no effects.
public struct EmptyReducer<State, Action>: Reducer {
    
    /// Creates an empty reducer.
    @inlinable
    public init() {}
    
    /// Performs no reduction, returning the state unchanged.
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        .none
    }
}

// MARK: - Combined Reducers

/// A reducer that combines two reducers.
public struct CombinedReducer2<R0: Reducer, R1: Reducer>: Reducer
where R0.State == R1.State, R0.Action == R1.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    
    @inlinable
    public init(_ r0: R0, _ r1: R1) {
        self.r0 = r0
        self.r1 = r1
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        return .merge([effect0, effect1])
    }
}

/// A reducer that combines three reducers.
public struct CombinedReducer3<R0: Reducer, R1: Reducer, R2: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State,
      R0.Action == R1.Action, R1.Action == R2.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2])
    }
}

/// A reducer that combines four reducers.
public struct CombinedReducer4<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State, R2.State == R3.State,
      R0.Action == R1.Action, R1.Action == R2.Action, R2.Action == R3.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    @usableFromInline let r3: R3
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        let effect3 = r3.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2, effect3])
    }
}

/// A reducer that combines five reducers.
public struct CombinedReducer5<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State, R2.State == R3.State, R3.State == R4.State,
      R0.Action == R1.Action, R1.Action == R2.Action, R2.Action == R3.Action, R3.Action == R4.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    @usableFromInline let r3: R3
    @usableFromInline let r4: R4
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
        self.r4 = r4
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        let effect3 = r3.reduce(into: &state, action: action)
        let effect4 = r4.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2, effect3, effect4])
    }
}

/// A reducer that combines six reducers.
public struct CombinedReducer6<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State, R2.State == R3.State, R3.State == R4.State, R4.State == R5.State,
      R0.Action == R1.Action, R1.Action == R2.Action, R2.Action == R3.Action, R3.Action == R4.Action, R4.Action == R5.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    @usableFromInline let r3: R3
    @usableFromInline let r4: R4
    @usableFromInline let r5: R5
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
        self.r4 = r4
        self.r5 = r5
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        let effect3 = r3.reduce(into: &state, action: action)
        let effect4 = r4.reduce(into: &state, action: action)
        let effect5 = r5.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2, effect3, effect4, effect5])
    }
}

/// A reducer that combines seven reducers.
public struct CombinedReducer7<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer, R6: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State, R2.State == R3.State, R3.State == R4.State, R4.State == R5.State, R5.State == R6.State,
      R0.Action == R1.Action, R1.Action == R2.Action, R2.Action == R3.Action, R3.Action == R4.Action, R4.Action == R5.Action, R5.Action == R6.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    @usableFromInline let r3: R3
    @usableFromInline let r4: R4
    @usableFromInline let r5: R5
    @usableFromInline let r6: R6
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
        self.r4 = r4
        self.r5 = r5
        self.r6 = r6
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        let effect3 = r3.reduce(into: &state, action: action)
        let effect4 = r4.reduce(into: &state, action: action)
        let effect5 = r5.reduce(into: &state, action: action)
        let effect6 = r6.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2, effect3, effect4, effect5, effect6])
    }
}

/// A reducer that combines eight reducers.
public struct CombinedReducer8<R0: Reducer, R1: Reducer, R2: Reducer, R3: Reducer, R4: Reducer, R5: Reducer, R6: Reducer, R7: Reducer>: Reducer
where R0.State == R1.State, R1.State == R2.State, R2.State == R3.State, R3.State == R4.State, R4.State == R5.State, R5.State == R6.State, R6.State == R7.State,
      R0.Action == R1.Action, R1.Action == R2.Action, R2.Action == R3.Action, R3.Action == R4.Action, R4.Action == R5.Action, R5.Action == R6.Action, R6.Action == R7.Action {
    
    public typealias State = R0.State
    public typealias Action = R0.Action
    
    @usableFromInline let r0: R0
    @usableFromInline let r1: R1
    @usableFromInline let r2: R2
    @usableFromInline let r3: R3
    @usableFromInline let r4: R4
    @usableFromInline let r5: R5
    @usableFromInline let r6: R6
    @usableFromInline let r7: R7
    
    @inlinable
    public init(_ r0: R0, _ r1: R1, _ r2: R2, _ r3: R3, _ r4: R4, _ r5: R5, _ r6: R6, _ r7: R7) {
        self.r0 = r0
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
        self.r4 = r4
        self.r5 = r5
        self.r6 = r6
        self.r7 = r7
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effect0 = r0.reduce(into: &state, action: action)
        let effect1 = r1.reduce(into: &state, action: action)
        let effect2 = r2.reduce(into: &state, action: action)
        let effect3 = r3.reduce(into: &state, action: action)
        let effect4 = r4.reduce(into: &state, action: action)
        let effect5 = r5.reduce(into: &state, action: action)
        let effect6 = r6.reduce(into: &state, action: action)
        let effect7 = r7.reduce(into: &state, action: action)
        return .merge([effect0, effect1, effect2, effect3, effect4, effect5, effect6, effect7])
    }
}

// MARK: - OptionalReducer

/// A reducer that wraps an optional reducer.
public struct OptionalReducer<Wrapped: Reducer>: Reducer {
    
    public typealias State = Wrapped.State
    public typealias Action = Wrapped.Action
    
    @usableFromInline let wrapped: Wrapped?
    
    @inlinable
    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        wrapped?.reduce(into: &state, action: action) ?? .none
    }
}

// MARK: - ConditionalReducer

/// A reducer that represents a conditional choice between two reducers.
public enum ConditionalReducer<First: Reducer, Second: Reducer>: Reducer
where First.State == Second.State, First.Action == Second.Action {
    
    public typealias State = First.State
    public typealias Action = First.Action
    
    case first(First)
    case second(Second)
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        switch self {
        case let .first(reducer):
            return reducer.reduce(into: &state, action: action)
        case let .second(reducer):
            return reducer.reduce(into: &state, action: action)
        }
    }
}

// MARK: - ReducerArray

/// A reducer that combines an array of homogeneous reducers.
public struct ReducerArray<Element: Reducer>: Reducer {
    
    public typealias State = Element.State
    public typealias Action = Element.Action
    
    @usableFromInline let reducers: [Element]
    
    @inlinable
    public init(_ reducers: [Element]) {
        self.reducers = reducers
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let effects = reducers.map { $0.reduce(into: &state, action: action) }
        return .merge(effects)
    }
}

// MARK: - AnyReducer

/// A type-erased reducer that can wrap any reducer with matching state and action types.
public struct AnyReducer<State, Action>: Reducer {
    
    @usableFromInline
    let _reduce: (inout State, Action) -> Effect<Action>
    
    /// Creates a type-erased reducer from any reducer.
    @inlinable
    public init<R: Reducer>(_ reducer: R) where R.State == State, R.Action == Action {
        self._reduce = reducer.reduce
    }
    
    /// Creates a type-erased reducer from a closure.
    @inlinable
    public init(_ reduce: @escaping (inout State, Action) -> Effect<Action>) {
        self._reduce = reduce
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        _reduce(&state, action)
    }
}

// MARK: - Reducer Extensions

extension Reducer {
    
    /// Combines this reducer with another reducer.
    @inlinable
    public func combined<R: Reducer>(
        with other: R
    ) -> CombinedReducer2<Self, R> where R.State == State, R.Action == Action {
        CombinedReducer2(self, other)
    }
    
    /// Erases the type of this reducer.
    @inlinable
    public func eraseToAnyReducer() -> AnyReducer<State, Action> {
        AnyReducer(self)
    }
    
    /// Transforms actions before they reach this reducer.
    @inlinable
    public func pullback<GlobalAction>(
        action toLocalAction: @escaping (GlobalAction) -> Action?
    ) -> PullbackActionReducer<Self, GlobalAction> {
        PullbackActionReducer(self, toLocalAction: toLocalAction)
    }
    
    /// Transforms state before it reaches this reducer.
    @inlinable
    public func pullback<GlobalState>(
        state toLocalState: WritableKeyPath<GlobalState, State>
    ) -> PullbackStateReducer<Self, GlobalState> {
        PullbackStateReducer(self, toLocalState: toLocalState)
    }
    
    /// Filters actions before they reach this reducer.
    @inlinable
    public func filter(
        _ predicate: @escaping (Action) -> Bool
    ) -> FilteredReducer<Self> {
        FilteredReducer(self, predicate: predicate)
    }
    
    /// Logs actions and state changes for debugging.
    @inlinable
    public func debug(
        _ prefix: String = "",
        actionFormat: ActionFormat = .prettyPrint,
        stateFormat: StateFormat = .prettyPrint
    ) -> DebugReducer<Self> {
        DebugReducer(self, prefix: prefix, actionFormat: actionFormat, stateFormat: stateFormat)
    }
}

// MARK: - PullbackActionReducer

/// A reducer that transforms actions before processing.
public struct PullbackActionReducer<Base: Reducer, GlobalAction>: Reducer {
    
    public typealias State = Base.State
    public typealias Action = GlobalAction
    
    @usableFromInline let base: Base
    @usableFromInline let toLocalAction: (GlobalAction) -> Base.Action?
    
    @inlinable
    public init(_ base: Base, toLocalAction: @escaping (GlobalAction) -> Base.Action?) {
        self.base = base
        self.toLocalAction = toLocalAction
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: GlobalAction
    ) -> Effect<GlobalAction> {
        guard let localAction = toLocalAction(action) else {
            return .none
        }
        return base.reduce(into: &state, action: localAction)
            .map { _ in action }
    }
}

// MARK: - PullbackStateReducer

/// A reducer that transforms state before processing.
public struct PullbackStateReducer<Base: Reducer, GlobalState>: Reducer {
    
    public typealias State = GlobalState
    public typealias Action = Base.Action
    
    @usableFromInline let base: Base
    @usableFromInline let toLocalState: WritableKeyPath<GlobalState, Base.State>
    
    @inlinable
    public init(_ base: Base, toLocalState: WritableKeyPath<GlobalState, Base.State>) {
        self.base = base
        self.toLocalState = toLocalState
    }
    
    @inlinable
    public func reduce(
        into state: inout GlobalState,
        action: Action
    ) -> Effect<Action> {
        base.reduce(into: &state[keyPath: toLocalState], action: action)
    }
}

// MARK: - FilteredReducer

/// A reducer that filters actions based on a predicate.
public struct FilteredReducer<Base: Reducer>: Reducer {
    
    public typealias State = Base.State
    public typealias Action = Base.Action
    
    @usableFromInline let base: Base
    @usableFromInline let predicate: (Action) -> Bool
    
    @inlinable
    public init(_ base: Base, predicate: @escaping (Action) -> Bool) {
        self.base = base
        self.predicate = predicate
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        guard predicate(action) else {
            return .none
        }
        return base.reduce(into: &state, action: action)
    }
}

// MARK: - Debug Formatting

/// Format for printing actions in debug output.
public enum ActionFormat {
    case prettyPrint
    case compact
    case custom((Any) -> String)
}

/// Format for printing state in debug output.
public enum StateFormat {
    case prettyPrint
    case compact
    case diff
    case custom((Any) -> String)
}

// MARK: - DebugReducer

/// A reducer that logs actions and state changes for debugging.
public struct DebugReducer<Base: Reducer>: Reducer {
    
    public typealias State = Base.State
    public typealias Action = Base.Action
    
    @usableFromInline let base: Base
    @usableFromInline let prefix: String
    @usableFromInline let actionFormat: ActionFormat
    @usableFromInline let stateFormat: StateFormat
    
    @inlinable
    public init(
        _ base: Base,
        prefix: String,
        actionFormat: ActionFormat,
        stateFormat: StateFormat
    ) {
        self.base = base
        self.prefix = prefix
        self.actionFormat = actionFormat
        self.stateFormat = stateFormat
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        #if DEBUG
        let previousState = state
        let effect = base.reduce(into: &state, action: action)
        
        let actionString = formatAction(action)
        let stateString = formatStateDiff(from: previousState, to: state)
        
        let prefixString = prefix.isEmpty ? "" : "[\(prefix)] "
        print("\(prefixString)Action: \(actionString)")
        print("\(prefixString)State: \(stateString)")
        
        return effect
        #else
        return base.reduce(into: &state, action: action)
        #endif
    }
    
    @usableFromInline
    func formatAction(_ action: Action) -> String {
        switch actionFormat {
        case .prettyPrint:
            return String(describing: action)
        case .compact:
            return String(reflecting: action)
        case let .custom(formatter):
            return formatter(action)
        }
    }
    
    @usableFromInline
    func formatStateDiff(from previous: State, to current: State) -> String {
        switch stateFormat {
        case .prettyPrint:
            return String(describing: current)
        case .compact:
            return String(reflecting: current)
        case .diff:
            return "Previous: \(previous)\nCurrent: \(current)"
        case let .custom(formatter):
            return formatter(current)
        }
    }
}

// MARK: - ForEachReducer

/// A reducer that applies a child reducer to each element in a collection.
public struct ForEachReducer<Parent: Reducer, Child: Reducer, ID: Hashable>: Reducer
where Parent.State: MutableCollection,
      Parent.State.Element == Child.State,
      Parent.Action == (ID, Child.Action) {
    
    public typealias State = Parent.State
    public typealias Action = (ID, Child.Action)
    
    @usableFromInline let child: Child
    @usableFromInline let id: KeyPath<Child.State, ID>
    
    @inlinable
    public init(
        _ child: Child,
        id: KeyPath<Child.State, ID>
    ) {
        self.child = child
        self.id = id
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let (targetID, childAction) = action
        
        guard let index = state.firstIndex(where: { $0[keyPath: id] == targetID }) else {
            return .none
        }
        
        let effect = child.reduce(into: &state[index], action: childAction)
        return effect.map { (targetID, $0) }
    }
}

// MARK: - IdentifiedReducer

/// A reducer that works with identified collections.
public struct IdentifiedReducer<Element: Reducer, ID: Hashable>: Reducer {
    
    public typealias State = [ID: Element.State]
    public typealias Action = (ID, Element.Action)
    
    @usableFromInline let element: Element
    
    @inlinable
    public init(_ element: Element) {
        self.element = element
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        let (id, elementAction) = action
        
        guard state[id] != nil else {
            return .none
        }
        
        let effect = element.reduce(into: &state[id]!, action: elementAction)
        return effect.map { (id, $0) }
    }
}

// MARK: - Scope Support

/// A scoped reducer that operates on a subset of the parent state.
public struct ScopedReducer<Parent: Reducer, Child: Reducer>: Reducer {
    
    public typealias State = Parent.State
    public typealias Action = Parent.Action
    
    @usableFromInline let parent: Parent
    @usableFromInline let child: Child
    @usableFromInline let toChildState: WritableKeyPath<Parent.State, Child.State>
    @usableFromInline let toChildAction: (Parent.Action) -> Child.Action?
    @usableFromInline let fromChildAction: (Child.Action) -> Parent.Action
    
    @inlinable
    public init(
        _ parent: Parent,
        child: Child,
        state toChildState: WritableKeyPath<Parent.State, Child.State>,
        action toChildAction: @escaping (Parent.Action) -> Child.Action?,
        fromChild fromChildAction: @escaping (Child.Action) -> Parent.Action
    ) {
        self.parent = parent
        self.child = child
        self.toChildState = toChildState
        self.toChildAction = toChildAction
        self.fromChildAction = fromChildAction
    }
    
    @inlinable
    public func reduce(
        into state: inout State,
        action: Action
    ) -> Effect<Action> {
        var effects: [Effect<Action>] = []
        
        // Run parent reducer first
        effects.append(parent.reduce(into: &state, action: action))
        
        // Run child reducer if action matches
        if let childAction = toChildAction(action) {
            let childEffect = child.reduce(into: &state[keyPath: toChildState], action: childAction)
            effects.append(childEffect.map(fromChildAction))
        }
        
        return .merge(effects)
    }
}
