import SwiftUI
import Combine

// MARK: - ViewStore

/// A wrapper around `Store` that provides convenient SwiftUI binding
/// creation for two-way data flow between views and state.
///
/// ViewStore is designed to make form-heavy views cleaner by generating
/// `Binding<Value>` instances directly from state key paths.
///
/// Usage:
/// ```swift
/// struct FormView: View {
///     @ObservedObject var viewStore: ViewStore<FormState, FormAction>
///
///     var body: some View {
///         TextField("Name", text: viewStore.binding(
///             get: \.name,
///             send: { .updateName($0) }
///         ))
///     }
/// }
/// ```
public final class ViewStore<State, Action>: ObservableObject {

    // MARK: - Properties

    /// The current state, published for SwiftUI.
    @Published public private(set) var state: State

    /// Closure to dispatch actions to the underlying store.
    private let _send: (Action) -> Void

    /// Subscription to the parent store's state.
    private var cancellable: AnyCancellable?

    // MARK: - Initialization

    /// Creates a ViewStore backed by a Store.
    ///
    /// - Parameter store: The backing store instance.
    public init(_ store: Store<State, Action>) {
        self.state = store.state
        self._send = { store.send($0) }

        self.cancellable = store.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
    }

    /// Creates a ViewStore backed by a ScopedStore.
    public init(_ scopedStore: ScopedStore<State, Action>) {
        self.state = scopedStore.state
        self._send = { scopedStore.send($0) }

        self.cancellable = scopedStore.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newState in
                self?.state = newState
            }
    }

    // MARK: - Dispatching

    /// Sends an action to the underlying store.
    public func send(_ action: Action) {
        _send(action)
    }

    // MARK: - Bindings

    /// Creates a SwiftUI binding from a state key path and an action closure.
    ///
    /// - Parameters:
    ///   - get: Key path to read the value from state.
    ///   - send: Closure that creates an action from the new value.
    /// - Returns: A `Binding<Value>` for SwiftUI views.
    public func binding<Value>(
        get keyPath: KeyPath<State, Value>,
        send actionCreator: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self._send(actionCreator($0)) }
        )
    }

    /// Creates a binding that sends a fixed action on value change.
    ///
    /// - Parameters:
    ///   - get: Key path to read the value.
    ///   - send: A fixed action to send when the value changes.
    /// - Returns: A `Binding<Value>` for SwiftUI views.
    public func binding<Value>(
        get keyPath: KeyPath<State, Value>,
        send action: Action
    ) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { _ in self._send(action) }
        )
    }

    // MARK: - Derived State

    /// Returns a publisher for a specific state property.
    public func publisher<Value>(
        for keyPath: KeyPath<State, Value>
    ) -> AnyPublisher<Value, Never> where Value: Equatable {
        $state
            .map(keyPath)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
