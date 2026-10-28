import Observation

/// What a `Store` reads its state from and sends its actions to: the root core that owns the
/// state, or a scoped core that looks into a parent.
@MainActor
protocol StoreCore<State, Action>: AnyObject {
    associatedtype State
    associatedtype Action

    /// The state, without registering an observation.
    var currentState: State { get }
    /// Registers an observation of the whole state.
    func trackWholeState()
    /// Registers an observation of the value at `keyPath` only, when the core can tell that
    /// value's changes apart; otherwise of the whole state.
    func track<Value: Equatable>(_ keyPath: KeyPath<State, Value>)
    func send(_ action: Action) -> StoreTask
}

/// Owns the state of a root store, runs the reducer and notifies observers.
///
/// Observation is tracked per stored property: reading `store.count` registers the key path
/// `\RootCore.observedState.count`, and after each action the core calls `willSet`/`didSet`
/// only for the registered key paths whose values changed. Key paths that are not a chain of
/// stored properties (computed properties, subscripts, optional chaining) cannot be compared
/// safely on an old state, so they fall back to observing the whole state.
@MainActor
final class RootCore<R: Reducer>: StoreCore, Observable {
    typealias State = R.State
    typealias Action = R.Action

    /// A key path a view has read, with what is needed to notify it.
    private struct Member {
        let hasChanged: (State, State) -> Bool
        let willSet: (RootCore) -> Void
        let didSet: (RootCore) -> Void
    }

    private let registrar = ObservationRegistrar()
    private var storage: State
    private let reducer: R
    private let runner = EffectRunner<Action>()
    private let onIssue: @MainActor (StoreIssue) -> Void
    /// Only chains of stored properties are added, so the dictionary is bounded by the shape of
    /// `State`, not by how often or with which indices views read it.
    private var members: [AnyKeyPath: Member] = [:]
    private var pending: [Action] = []
    private var isProcessing = false

    init(initialState: State, reducer: R, onIssue: @escaping @MainActor (StoreIssue) -> Void) {
        self.storage = initialState
        self.reducer = reducer
        self.onIssue = onIssue
        runner.deliver = { [weak self] action in
            self?.enqueue(action)
        }
        runner.reportUnhandledError = { [weak self] error in
            self?.onIssue(StoreIssue(
                kind: .unhandledEffectError(errorType: StoreIssue.typeName(of: error)),
                actionType: String(reflecting: Action.self)
            ))
        }
    }

    var currentState: State { storage }

    /// The state, as an observable property. Its key path is the root of every member key path.
    var observedState: State {
        registrar.access(self, keyPath: \.observedState)
        return storage
    }

    var runningEffectCount: Int { runner.runningCount }

    var observedMemberCount: Int { members.count }

    func trackWholeState() {
        registrar.access(self, keyPath: \.observedState)
    }

    func track<Value: Equatable>(_ keyPath: KeyPath<State, Value>) {
        guard MemoryLayout<State>.offset(of: keyPath) != nil else {
            trackWholeState()
            return
        }
        let memberPath = (\RootCore.observedState).appending(path: keyPath)
        if members[memberPath] == nil {
            members[memberPath] = Member(
                hasChanged: { $0[keyPath: keyPath] != $1[keyPath: keyPath] },
                willSet: { $0.registrar.willSet($0, keyPath: memberPath) },
                didSet: { $0.registrar.didSet($0, keyPath: memberPath) }
            )
        }
        registrar.access(self, keyPath: memberPath)
    }

    func send(_ action: Action) -> StoreTask {
        enqueue(action)
    }

    /// Processes `action` and every action it sends with `Effect.send`, in order. An action that
    /// arrives while another is being processed (from `Effect.send`, or from an observer that
    /// sends during a state change) is queued and processed by the outer call.
    @discardableResult
    private func enqueue(_ action: Action) -> StoreTask {
        pending.append(action)
        guard !isProcessing else { return StoreTask(tasks: []) }
        isProcessing = true
        defer { isProcessing = false }

        var started: [Task<Void, Never>] = []
        var processed = 0
        var index = 0
        while index < pending.count {
            let next = pending[index]
            index += 1
            processed += 1
            if processed > StoreLimits.synchronousActions {
                onIssue(StoreIssue(
                    kind: .synchronousActionLimitExceeded(limit: StoreLimits.synchronousActions),
                    actionType: String(reflecting: Action.self)
                ))
                break
            }
            var newState = storage
            let effect = reducer.reduce(into: &newState, action: next)
            apply(newState)
            started += runner.run(effect)
        }
        pending.removeAll(keepingCapacity: true)
        return StoreTask(tasks: started)
    }

    /// Stores the reducer's state and notifies the observers whose values changed.
    ///
    /// `==` only decides who is notified, never whether the state is kept: a type whose `==`
    /// compares part of its value (an id, say), or `0.0 == -0.0`, would otherwise lose the
    /// reducer's change.
    private func apply(_ newState: State) {
        let oldState = storage
        let changedMembers = members.values.filter { $0.hasChanged(oldState, newState) }
        let wholeStateChanged = !(areEqual(oldState, newState) ?? false)
        guard wholeStateChanged || !changedMembers.isEmpty else {
            storage = newState
            return
        }

        for member in changedMembers { member.willSet(self) }
        if wholeStateChanged { registrar.willSet(self, keyPath: \.observedState) }
        storage = newState
        for member in changedMembers { member.didSet(self) }
        if wholeStateChanged { registrar.didSet(self, keyPath: \.observedState) }
    }
}

/// A core that reads and sends through a parent core. Made by `Store.scope`.
@MainActor
final class ScopedCore<ParentState, ParentAction, State, Action>: StoreCore {
    private let parent: any StoreCore<ParentState, ParentAction>
    private let toState: KeyPath<ParentState, State>
    private let embed: (Action) -> ParentAction
    private let trackScope: () -> Void

    init(
        parent: any StoreCore<ParentState, ParentAction>,
        toState: KeyPath<ParentState, State>,
        embed: @escaping (Action) -> ParentAction,
        trackScope: @escaping () -> Void
    ) {
        self.parent = parent
        self.toState = toState
        self.embed = embed
        self.trackScope = trackScope
    }

    var currentState: State { parent.currentState[keyPath: toState] }

    func trackWholeState() {
        trackScope()
    }

    func track<Value: Equatable>(_ keyPath: KeyPath<State, Value>) {
        parent.track(toState.appending(path: keyPath))
    }

    func send(_ action: Action) -> StoreTask {
        parent.send(embed(action))
    }
}

enum StoreLimits {
    /// The most actions one `send` processes through `Effect.send` before the store reports a
    /// loop and drops the rest.
    static let synchronousActions = 10_000
}

/// Compares two values when their type is `Equatable`; returns `nil` otherwise.
func areEqual<Value>(_ lhs: Value, _ rhs: Value) -> Bool? {
    guard let lhs = lhs as? any Equatable else { return nil }
    return lhs.isEqual(to: rhs)
}

extension Equatable {
    fileprivate func isEqual(to other: Any) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
