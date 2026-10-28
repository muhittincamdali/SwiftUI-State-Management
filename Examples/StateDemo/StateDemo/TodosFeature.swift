// The logic of the Todos screen: a list saved to disk, a navigation stack restored at launch,
// a sheet, an alert and deep links. The package's test target compiles this file (through a
// symbolic link) and tests it.
import Foundation
import SwiftUIStateManagement

struct Todo: Identifiable, Hashable, Codable, Sendable {
    var id: UUID
    var title: String
    var notes = ""
    var isDone = false
}

extension PersistenceKey where Value == [Todo] {
    static let todos = PersistenceKey("todos", version: 1)
}

extension PersistenceKey where Value == [UUID] {
    /// The ids on the navigation stack, so the app reopens on the screen the user left.
    static let todoPath = PersistenceKey("todo-path", version: 1, maxBytes: 4_096)
}

struct Todos: Reducer {
    enum Filter: String, CaseIterable, Sendable {
        case all = "All"
        case active = "Active"
        case done = "Done"
    }

    struct Editor: Identifiable, Equatable {
        let id: UUID
        var title = ""
    }

    struct ClearConfirmation: Equatable {
        var count: Int
    }

    struct State: Equatable {
        var items: [Todo] = []
        var filter = Filter.all
        var path: [Todo.ID] = []
        var editor: Editor?
        /// The "Clear completed" confirmation, when it is shown.
        var clearConfirmation: ClearConfirmation?

        /// The deepest navigation stack the screen restores or accepts from a link.
        static let maximumPathDepth = 8

        /// A state rebuilt from saved data. Ids on the saved stack whose todo no longer exists
        /// are dropped, and the stack is cut to ``maximumPathDepth``.
        static func restored(items: [Todo], path: [Todo.ID]) -> State {
            let ids = Set(items.map(\.id))
            return State(items: items, path: Array(path.filter(ids.contains).prefix(maximumPathDepth)))
        }

        var visibleItems: [Todo] {
            switch filter {
            case .all: items
            case .active: items.filter { !$0.isDone }
            case .done: items.filter(\.isDone)
            }
        }

        var editorTitle: String { editor?.title ?? "" }

        func todo(_ id: Todo.ID) -> Todo? {
            items.first { $0.id == id }
        }
    }

    enum Action: Equatable {
        case addTapped
        case editorTitleChanged(String)
        case editorSaveTapped
        case editorDismissed
        case toggleDone(Todo.ID)
        case notesChanged(Todo.ID, String)
        case deleteTapped(Todo.ID)
        case filterChanged(Filter)
        case pathChanged([Todo.ID])
        case clearCompletedTapped
        case clearCompletedConfirmed
        case clearCompletedDismissed
        case openURL(URL)
        case movedToBackground
    }

    /// Creates the id of a new todo; tests pass a counter.
    let makeID: @Sendable () -> UUID

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .addTapped:
            state.editor = Editor(id: makeID())
        case .editorTitleChanged(let title):
            state.editor?.title = title
        case .editorSaveTapped:
            guard let editor = state.editor else { return .none }
            let title = editor.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { return .none }
            state.items.insert(Todo(id: editor.id, title: title), at: 0)
            state.editor = nil
        case .editorDismissed:
            state.editor = nil
        case .toggleDone(let id):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return .none }
            state.items[index].isDone.toggle()
        case .notesChanged(let id, let notes):
            guard let index = state.items.firstIndex(where: { $0.id == id }) else { return .none }
            state.items[index].notes = notes
        case .deleteTapped(let id):
            state.items.removeAll { $0.id == id }
            state.path.removeAll { $0 == id }
        case .filterChanged(let filter):
            state.filter = filter
        case .pathChanged(let path):
            state.path = Array(path.prefix(State.maximumPathDepth))
        case .clearCompletedTapped:
            let count = state.items.count(where: \.isDone)
            guard count > 0 else { return .none }
            state.clearConfirmation = ClearConfirmation(count: count)
        case .clearCompletedConfirmed:
            let done = Set(state.items.filter(\.isDone).map(\.id))
            state.items.removeAll { done.contains($0.id) }
            state.path.removeAll { done.contains($0) }
            state.clearConfirmation = nil
        case .clearCompletedDismissed:
            state.clearConfirmation = nil
        case .openURL(let url):
            // statedemo://todos/<id> opens a todo; anything else is ignored.
            guard let id = TodoLink.todoID(in: url), state.todo(id) != nil else { return .none }
            state.filter = .all
            state.path = [id]
        case .movedToBackground:
            // Nothing changes; the persisting reducers flush pending saves on this action.
            break
        }
        return .none
    }
}

/// Parses the app's deep links.
enum TodoLink {
    static let scheme = "statedemo"

    /// The todo id in `statedemo://todos/<uuid>`, or `nil` for any other URL.
    static func todoID(in url: URL) -> UUID? {
        guard
            url.scheme?.lowercased() == scheme,
            url.host()?.lowercased() == "todos"
        else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }
        guard components.count == 1 else { return nil }
        return UUID(uuidString: components[0])
    }

    static func url(for id: UUID) -> URL {
        URL(string: "\(scheme)://todos/\(id.uuidString)")!
    }
}

extension Todos {
    /// The reducer the app runs: the todos and the navigation stack are saved after each change,
    /// at most once a second while the user types, and at once when the app moves to the
    /// background.
    func persisting(in storage: some StateStorage, clock: some Clock<Duration> = ContinuousClock()) -> some Reducer<State, Action> {
        let flush: (Action) -> Bool = { $0 == .movedToBackground }
        return self
            .persisting(\.items, to: .todos, in: storage, debounce: .seconds(1), clock: clock, flush: flush)
            .persisting(\.path, to: .todoPath, in: storage, debounce: .seconds(1), clock: clock, flush: flush)
    }
}
