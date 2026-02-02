import SwiftUI
import Combine

// MARK: - ScopedStore

/// A derived store that focuses on a subset of the parent store's state
/// and action space. Useful for modular architectures where each feature
/// manages its own slice of state.
///
/// Usage:
/// ```swift
/// let childStore = parentStore.scope(
///     state: \.profile,
///     action: AppAction.profile
/// )
/// ```
public final class ScopedStore<ChildState, ChildAction>: ObservableObject {

    // MARK: - Properties

    @Published public private(set) var state: ChildState

    private let sendAction: (ChildAction) -> Void
    private var cancellable: AnyCancellable?

    // MARK: - Initialization

    /// Creates a scoped store derived from a parent store.
    ///
    /// - Parameters:
    ///   - parent: The parent store to derive from.
    ///   - stateTransform: Extracts child state from parent state.
    ///   - actionTransform: Embeds child action into parent action.
    init<ParentState, ParentAction>(
        parent: Store<ParentState, ParentAction>,
        state stateTransform: @escaping (ParentState) -> ChildState,
        action actionTransform: @escaping (ChildAction) -> ParentAction
    ) {
        self.state = stateTransform(parent.state)
        self.sendAction = { parent.send(actionTransform($0)) }

        self.cancellable = parent.$state
            .map(stateTransform)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
    }

    // MARK: - Dispatching

    /// Sends a child action that gets embedded into the parent action space.
    public func send(_ action: ChildAction) {
        sendAction(action)
    }
}

// MARK: - Store Extension

extension Store {

    /// Creates a scoped store that focuses on a child state and action.
    ///
    /// - Parameters:
    ///   - stateKeyPath: Key path to the child state.
    ///   - actionTransform: Closure that wraps child action in parent action.
    /// - Returns: A scoped store observing the child state slice.
    public func scope<ChildState, ChildAction>(
        state stateKeyPath: KeyPath<State, ChildState>,
        action actionTransform: @escaping (ChildAction) -> Action
    ) -> ScopedStore<ChildState, ChildAction> {
        ScopedStore(
            parent: self,
            state: { $0[keyPath: stateKeyPath] },
            action: actionTransform
        )
    }

    /// Creates a scoped store using transform closures.
    public func scope<ChildState, ChildAction>(
        state stateTransform: @escaping (State) -> ChildState,
        action actionTransform: @escaping (ChildAction) -> Action
    ) -> ScopedStore<ChildState, ChildAction> {
        ScopedStore(
            parent: self,
            state: stateTransform,
            action: actionTransform
        )
    }
}

// MARK: - ScopedStore Nesting

extension ScopedStore {

    /// Further scopes this store into an even more specific child.
    public func scope<GrandchildState, GrandchildAction>(
        state stateTransform: @escaping (ChildState) -> GrandchildState,
        action actionTransform: @escaping (GrandchildAction) -> ChildAction
    ) -> ScopedStore<GrandchildState, GrandchildAction> {
        let parentSend = self.sendAction
        let parentState = self.$state

        let scoped = ScopedStore<GrandchildState, GrandchildAction>(
            initialState: stateTransform(self.state),
            sendAction: { parentSend(actionTransform($0)) },
            statePublisher: parentState.map(stateTransform).eraseToAnyPublisher()
        )
        return scoped
    }
}

extension ScopedStore {

    /// Internal initializer for nested scoping.
    convenience init(
        initialState: ChildState,
        sendAction: @escaping (ChildAction) -> Void,
        statePublisher: AnyPublisher<ChildState, Never>
    ) {
        self.init(initialState: initialState, sendAction: sendAction)
        self.cancellable = statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
    }

    private convenience init(initialState: ChildState, sendAction: @escaping (ChildAction) -> Void) {
        // Use a dummy parent — state is overridden by publisher
        self.init(
            _state: initialState,
            _sendAction: sendAction
        )
    }

    private convenience init(_state: ChildState, _sendAction: @escaping (ChildAction) -> Void) {
        // Workaround: cannot call designated init from convenience init with different generics
        // We use a stored closure pattern instead
        self.init(bypass: _state, send: _sendAction)
    }
}

// swiftlint:disable unused_parameter
extension ScopedStore {
    fileprivate convenience init(bypass state: ChildState, send: @escaping (ChildAction) -> Void) {
        fatalError("Use scope() from Store or ScopedStore to create instances")
    }
}
// swiftlint:enable unused_parameter
