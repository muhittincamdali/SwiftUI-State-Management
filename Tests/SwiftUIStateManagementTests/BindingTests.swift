import SwiftUI
import Testing
@testable import SwiftUIStateManagement

@Suite("Bindings")
@MainActor
struct BindingTests {
    @Test("binding(_:send:) reads the state and sends an action on write")
    func valueBinding() {
        let store = Store(initialState: Contacts.State(), reducer: Contacts())
        let path = store.binding(\.path, send: Contacts.Action.pathChanged)
        path.wrappedValue = [3, 4]
        #expect(store.path == [3, 4])
        #expect(path.wrappedValue == [3, 4])
    }

    @Test("A presentation binding sends dismiss only when SwiftUI writes nil to shown state")
    func presentationBinding() {
        let sent = Collected<String>()
        let store = Store(
            initialState: Contacts.State(),
            reducer: Contacts().combined(with: Reduce { _, action in
                sent.append("\(action)")
                return .none
            })
        )
        let sheet = store.binding(\.newContact, dismiss: .newContactDismissed)

        sheet.wrappedValue = nil
        #expect(sent.values.isEmpty, "Nothing is shown, so there is nothing to dismiss")

        store.send(.addTapped)
        #expect(sheet.wrappedValue?.id == 1)
        sheet.wrappedValue = Contacts.NewContact(id: 99, name: "Ignored")
        #expect(store.newContact?.id == 1, "Writes other than nil are ignored")

        sheet.wrappedValue = nil
        #expect(store.newContact == nil)
        #expect(sent.values == ["addTapped", "newContactDismissed"])
    }

    @Test("isPresented(_:dismiss:) is true while the state holds a value")
    func isPresentedBinding() {
        let store = Store(
            initialState: Todos.State(items: [Todo(id: UUID(), title: "Done", isDone: true)]),
            reducer: Todos(makeID: UUID.init)
        )
        let alert = store.isPresented(\.clearConfirmation, dismiss: .clearCompletedDismissed)
        #expect(!alert.wrappedValue)
        store.send(.clearCompletedTapped)
        #expect(alert.wrappedValue)
        alert.wrappedValue = true
        #expect(store.clearConfirmation?.count == 1)
        alert.wrappedValue = false
        #expect(store.clearConfirmation == nil)
    }

    @Test("A binding to a stored Equatable property is observed on its own")
    func bindingObservation() {
        let store = Store(initialState: Profile.State(), reducer: Profile())
        let title = store.binding(\.title, send: Profile.Action.setTitle)
        let reads = observationCount { _ = title.wrappedValue }
        store.send(.setCount(9))
        #expect(reads.count == 0)
        title.wrappedValue = "Renamed"
        #expect(reads.count == 1)
    }

    @Test("One case of an enum destination is presented through an optional computed property")
    func enumDestination() {
        let store = Store(initialState: Screen.State(), reducer: Screen())
        let editor = store.binding(\.destination?.editor, dismiss: .dismissed)
        let share = store.isPresented(\.destination?.share, dismiss: .dismissed)
        store.send(.editTapped)
        #expect(editor.wrappedValue == Screen.Editor(id: 1))
        #expect(!share.wrappedValue)
        editor.wrappedValue = nil
        #expect(store.destination == nil)
        store.send(.shareTapped)
        #expect(editor.wrappedValue == nil)
        #expect(share.wrappedValue)
    }
}

/// A screen that presents one of two destinations.
private struct Screen: Reducer {
    struct Editor: Identifiable, Equatable {
        var id: Int
    }

    enum Destination: Equatable {
        case editor(Editor)
        case share(String)

        var editor: Editor? {
            if case .editor(let editor) = self { editor } else { nil }
        }

        var share: String? {
            if case .share(let text) = self { text } else { nil }
        }
    }

    struct State: Equatable {
        var destination: Destination?
    }

    enum Action: Equatable {
        case editTapped
        case shareTapped
        case dismissed
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .editTapped: state.destination = .editor(Editor(id: 1))
        case .shareTapped: state.destination = .share("link")
        case .dismissed: state.destination = nil
        }
        return .none
    }
}
