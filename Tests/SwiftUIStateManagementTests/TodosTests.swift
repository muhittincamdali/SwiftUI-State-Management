import Foundation
import Testing
import SwiftUIStateManagement
import SwiftUIStateManagementTesting

/// Ids 00000000-0000-0000-0000-000000000001, …0002, … in order.
final class SequentialIDs: Sendable {
    private let next = CallCounter()

    func make() -> UUID {
        next.increment()
        return UUID(number: next.count)
    }
}

extension UUID {
    init(number: Int) {
        self.init(uuidString: String(format: "00000000-0000-0000-0000-%012d", number))!
    }
}

@Suite("Todos example")
@MainActor
struct TodosTests {
    private func makeStore(_ state: Todos.State = Todos.State()) -> TestStore<Todos.State, Todos.Action> {
        let ids = SequentialIDs()
        return TestStore(initialState: state, reducer: Todos(makeID: { ids.make() }))
    }

    @Test("Adding a todo through the editor sheet")
    func add() async {
        let store = makeStore()
        await store.send(.addTapped) { $0.editor = Todos.Editor(id: UUID(number: 1)) }
        await store.send(.editorTitleChanged("   ")) { $0.editor?.title = "   " }
        await store.send(.editorSaveTapped)
        await store.send(.editorTitleChanged(" Buy milk ")) { $0.editor?.title = " Buy milk " }
        await store.send(.editorSaveTapped) {
            $0.items = [Todo(id: UUID(number: 1), title: "Buy milk")]
            $0.editor = nil
        }
    }

    @Test("Clearing completed todos asks first and pops their screens")
    func clearCompleted() async {
        let done = Todo(id: UUID(number: 1), title: "Done", isDone: true)
        let open = Todo(id: UUID(number: 2), title: "Open")
        let store = makeStore(Todos.State(items: [done, open], path: [done.id]))
        await store.send(.clearCompletedTapped) { $0.clearConfirmation = Todos.ClearConfirmation(count: 1) }
        await store.send(.clearCompletedConfirmed) {
            $0.items = [open]
            $0.path = []
            $0.clearConfirmation = nil
        }
        await store.send(.clearCompletedTapped)
    }

    @Test("A deep link opens an existing todo and ignores everything else")
    func deepLinks() async {
        let todo = Todo(id: UUID(number: 7), title: "Linked")
        let store = makeStore(Todos.State(items: [todo], filter: .done))
        for link in [
            "https://todos/\(todo.id.uuidString)",
            "statedemo://other/\(todo.id.uuidString)",
            "statedemo://todos/not-a-uuid",
            "statedemo://todos/\(UUID(number: 8).uuidString)",
            "statedemo://todos/\(todo.id.uuidString)/extra",
            "statedemo://todos",
        ] {
            await store.send(.openURL(URL(string: link)!))
        }
        await store.send(.openURL(TodoLink.url(for: todo.id))) {
            $0.filter = .all
            $0.path = [todo.id]
        }
    }

    @Test("A restored stack keeps only existing todos and at most the maximum depth")
    func restoredPath() {
        let items = (1...20).map { Todo(id: UUID(number: $0), title: "\($0)") }
        let saved = [UUID(number: 99)] + items.map(\.id)
        let state = Todos.State.restored(items: items, path: saved)
        #expect(state.path == Array(items.map(\.id).prefix(Todos.State.maximumPathDepth)))
        #expect(Todos.State.restored(items: [], path: saved).path.isEmpty)
    }

    @Test("A navigation stack deeper than the maximum is cut")
    func pathDepth() async {
        let store = makeStore()
        let deep = (1...50).map(UUID.init(number:))
        await store.send(.pathChanged(deep)) { $0.path = Array(deep.prefix(Todos.State.maximumPathDepth)) }
    }

    @Test("Deleting a todo also removes it from the navigation stack")
    func delete() async {
        let todo = Todo(id: UUID(number: 1), title: "A")
        let store = makeStore(Todos.State(items: [todo], path: [todo.id]))
        await store.send(.toggleDone(todo.id)) { $0.items[0].isDone = true }
        await store.send(.notesChanged(todo.id, "note")) { $0.items[0].notes = "note" }
        await store.send(.deleteTapped(todo.id)) {
            $0.items = []
            $0.path = []
        }
        await store.send(.toggleDone(todo.id))
    }

    @Test("Filters show the matching todos")
    func filters() {
        let items = [Todo(id: UUID(number: 1), title: "A", isDone: true), Todo(id: UUID(number: 2), title: "B")]
        var state = Todos.State(items: items)
        state.filter = .active
        #expect(state.visibleItems.map(\.title) == ["B"])
        state.filter = .done
        #expect(state.visibleItems.map(\.title) == ["A"])
    }
}
