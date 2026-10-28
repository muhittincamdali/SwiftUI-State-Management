import SwiftUI

extension Store {
    /// Returns a binding that reads `keyPath` and sends `action` when a control writes a new
    /// value.
    ///
    /// The state is never written directly: the reducer decides what the new value means.
    ///
    /// ```swift
    /// TextField("Search", text: store.binding(\.query, send: Search.Action.queryChanged))
    /// Toggle("Notifications", isOn: store.binding(\.notificationsOn, send: { .notificationsToggled($0) }))
    /// ```
    public func binding<Value>(
        _ keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { self[dynamicMember: keyPath] },
            set: { newValue in self.send(action(newValue)) }
        )
    }

    /// Returns a binding that reads `keyPath` and sends `action` when a control writes a new
    /// value; see ``binding(_:send:)-(KeyPath<State,Value>,_)``. A view that uses it updates only
    /// when the value at `keyPath` changes.
    public func binding<Value: Equatable>(
        _ keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { self[dynamicMember: keyPath] },
            set: { newValue in self.send(action(newValue)) }
        )
    }

    /// Returns a binding for presenting optional state, such as a sheet's item, that sends
    /// `dismiss` when SwiftUI dismisses the presentation.
    ///
    /// The reducer presents by setting the optional state and dismisses by setting it to `nil`.
    /// When the user dismisses (swipes a sheet down, taps outside a popover), SwiftUI writes `nil`
    /// to the binding and the store receives `dismiss`. Writes of other values are ignored, and
    /// `dismiss` is not sent when the state is already `nil`.
    ///
    /// ```swift
    /// .sheet(item: store.binding(\.editor, dismiss: .editorDismissed)) { editor in
    ///     EditorView(editor: editor)
    /// }
    /// ```
    ///
    /// To present one case of an enum, read it through an optional computed property:
    /// `store.binding(\.destination?.editor, dismiss: .destinationDismissed)`.
    public func binding<Item>(
        _ keyPath: KeyPath<State, Item?>,
        dismiss: Action
    ) -> Binding<Item?> {
        Binding(
            get: { self[dynamicMember: keyPath] },
            set: { newValue in
                guard newValue == nil, self.core.currentState[keyPath: keyPath] != nil else { return }
                self.send(dismiss)
            }
        )
    }

    /// Returns a `Bool` binding that is `true` while the optional state at `keyPath` holds a
    /// value, and sends `dismiss` when SwiftUI sets it to `false`; for alerts, confirmation
    /// dialogs and `fullScreenCover(isPresented:)`.
    ///
    /// ```swift
    /// .alert("Delete all items?", isPresented: store.isPresented(\.deleteConfirmation, dismiss: .deleteCancelled)) {
    ///     Button("Delete", role: .destructive) { store.send(.deleteConfirmed) }
    /// }
    /// ```
    public func isPresented<Item>(
        _ keyPath: KeyPath<State, Item?>,
        dismiss: Action
    ) -> Binding<Bool> {
        Binding(
            get: {
                self.core.trackWholeState()
                return self.core.currentState[keyPath: keyPath] != nil
            },
            set: { isPresented in
                guard !isPresented, self.core.currentState[keyPath: keyPath] != nil else { return }
                self.send(dismiss)
            }
        )
    }

    /// Sends an action inside `withAnimation(animation)`, so that the views that change because of
    /// the new state animate.
    @discardableResult
    public func send(_ action: Action, animation: Animation?) -> StoreTask {
        withAnimation(animation) {
            send(action)
        }
    }
}
