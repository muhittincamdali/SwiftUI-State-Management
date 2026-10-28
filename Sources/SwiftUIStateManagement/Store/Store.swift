import Observation

/// Holds a feature's state, runs its reducer for each action, and lets SwiftUI observe the
/// result.
///
/// Create one store per feature and give it to the view. The view reads state through the store
/// and changes it only by sending actions:
///
/// ```swift
/// struct CounterView: View {
///     let store: Store<Counter.State, Counter.Action>
///
///     var body: some View {
///         Stepper("\(store.count)") {
///             store.send(.incrementTapped)
///         } onDecrement: {
///             store.send(.decrementTapped)
///         }
///     }
/// }
/// ```
///
/// ## Observation
///
/// The store works with the Observation framework, like an `@Observable` class: a view that
/// reads `store.count` in its body updates when `count` changes. A read through the store
/// (`store.count`) of a stored property whose type is `Equatable` is tracked for that property
/// alone, so the view does not update when only `store.title` changes. `store.profile.name`
/// is tracked as a read of `profile`; give a child view `store.scope(state: \.profile, ...)`
/// and its read of `name` is tracked on its own. Reading ``state`` (`store.state.count`), a
/// computed property, a subscript, or a value that is not `Equatable` is tracked as a read of
/// the whole state. A send that leaves an `Equatable` state unchanged notifies no one.
///
/// ## Effects
///
/// Effects run as tasks on the main actor. They are cancelled when the store is deallocated, with
/// ``Effect/cancel(id:)``, or when the ``StoreTask`` returned by ``send(_:)`` is cancelled.
@MainActor
@dynamicMemberLookup
public final class Store<State, Action>: Observable {
    let core: any StoreCore<State, Action>

    /// Creates a store.
    ///
    /// - Parameters:
    ///   - initialState: The state to start with.
    ///   - reducer: The feature's logic.
    ///   - onIssue: Called when the store notices a programming mistake, such as an effect
    ///     error without a `catch` handler. The default writes the issue to the unified log as a
    ///     fault. See ``StoreIssue``.
    public convenience init<R: Reducer>(
        initialState: State,
        reducer: R,
        onIssue: @escaping @MainActor (StoreIssue) -> Void = StoreIssue.logToUnifiedLog
    ) where R.State == State, R.Action == Action {
        self.init(core: RootCore(initialState: initialState, reducer: reducer, onIssue: onIssue))
    }

    init(core: any StoreCore<State, Action>) {
        self.core = core
    }

    /// The current state.
    ///
    /// A view that reads `state` is updated on every change to the state. Read single properties
    /// through the store instead (`store.count`) so the view updates only when they change.
    public var state: State {
        core.trackWholeState()
        return core.currentState
    }

    /// Reads a property of the state. Observed as a read of the whole state, because the value is
    /// not `Equatable`.
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        core.trackWholeState()
        return core.currentState[keyPath: keyPath]
    }

    /// Reads a property of the state. Observed on its own when `keyPath` is a chain of stored
    /// properties, so a view that reads it updates only when it changes.
    public subscript<Value: Equatable>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        core.track(keyPath)
        return core.currentState[keyPath: keyPath]
    }

    /// Sends an action: runs the reducer, updates the state and starts the returned effects.
    ///
    /// The state has changed by the time `send` returns. Actions that the reducer sends with
    /// ``Effect/send(_:)`` are processed before `send` returns as well.
    ///
    /// - Returns: The effects started by this action. Await ``StoreTask/finish()`` to wait for
    ///   them, or ignore the result.
    @discardableResult
    public func send(_ action: Action) -> StoreTask {
        core.send(action)
    }

    /// Returns a store for part of this store's state and actions, to give to a child view.
    ///
    /// The child store reads `state` from this store and wraps each action it is sent with
    /// `action` before sending it here. It does not run a reducer of its own: the parent's
    /// reducer handles the child's actions, usually with ``Scope``.
    ///
    /// ```swift
    /// SettingsView(store: store.scope(state: \.settings, action: AppAction.settings))
    /// ```
    public func scope<ChildState, ChildAction>(
        state toChildState: KeyPath<State, ChildState>,
        action embed: @escaping (ChildAction) -> Action
    ) -> Store<ChildState, ChildAction> {
        let core = self.core
        return Store<ChildState, ChildAction>(core: ScopedCore(
            parent: core,
            toState: toChildState,
            embed: embed,
            trackScope: { core.trackWholeState() }
        ))
    }

    /// Returns a store for part of this store's state and actions; see
    /// ``scope(state:action:)-(KeyPath<State,ChildState>,_)``. Because the child state is
    /// `Equatable`, a view of the child store updates only when the child state changes.
    public func scope<ChildState: Equatable, ChildAction>(
        state toChildState: KeyPath<State, ChildState>,
        action embed: @escaping (ChildAction) -> Action
    ) -> Store<ChildState, ChildAction> {
        let core = self.core
        return Store<ChildState, ChildAction>(core: ScopedCore(
            parent: core,
            toState: toChildState,
            embed: embed,
            trackScope: { core.track(toChildState) }
        ))
    }
}
