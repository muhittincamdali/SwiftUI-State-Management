import SwiftUI

// MARK: - View + Store Extensions

extension View {

    /// Injects a store into the SwiftUI environment as an environment object.
    ///
    /// - Parameter store: The store to inject.
    /// - Returns: A view with the store available as an environment object.
    public func withStore<State, Action>(
        _ store: Store<State, Action>
    ) -> some View {
        self.environmentObject(store)
    }

    /// Observes a specific state property and triggers an action when it changes.
    ///
    /// - Parameters:
    ///   - store: The store to observe.
    ///   - keyPath: The property to watch.
    ///   - perform: Closure called with the new value when it changes.
    /// - Returns: A modified view that responds to state changes.
    public func onStateChange<State, Action, Value: Equatable>(
        in store: Store<State, Action>,
        of keyPath: KeyPath<State, Value>,
        perform: @escaping (Value) -> Void
    ) -> some View {
        self.onReceive(
            store.$state
                .map(keyPath)
                .removeDuplicates()
        ) { newValue in
            perform(newValue)
        }
    }

    /// Conditionally applies a view modifier based on a store's state.
    ///
    /// - Parameters:
    ///   - store: The store to read state from.
    ///   - keyPath: The boolean property to check.
    ///   - transform: The view transformation to apply when true.
    /// - Returns: A conditionally modified view.
    public func storeConditional<State, Action>(
        _ store: Store<State, Action>,
        when keyPath: KeyPath<State, Bool>,
        @ViewBuilder transform: @escaping (Self) -> some View
    ) -> some View {
        Group {
            if store.state[keyPath: keyPath] {
                transform(self)
            } else {
                self
            }
        }
    }
}
