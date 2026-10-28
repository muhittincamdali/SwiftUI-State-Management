import SwiftUI
import SwiftUIStateManagement

struct TodosView: View {
    let store: Store<Todos.State, Todos.Action>

    var body: some View {
        NavigationStack(path: store.binding(\.path, send: Todos.Action.pathChanged)) {
            List {
                Section {
                    Picker("Show", selection: store.binding(\.filter, send: Todos.Action.filterChanged)) {
                        ForEach(Todos.Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    ForEach(store.visibleItems) { todo in
                        TodoRow(todo: todo) {
                            store.send(.toggleDone(todo.id), animation: .default)
                        }
                    }
                } footer: {
                    Text("Saved to disk after each change. Restart the app: the list and the open screen come back.")
                }
            }
            .navigationTitle("Todos")
            .navigationDestination(for: Todo.ID.self) { id in
                TodoDetailView(store: store, id: id)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") { store.send(.addTapped) }
                }
                ToolbarItem {
                    Button("Clear completed", systemImage: "trash") { store.send(.clearCompletedTapped) }
                }
            }
            .sheet(item: store.binding(\.editor, dismiss: .editorDismissed)) { _ in
                EditorView(store: store)
            }
            .alert(
                "Delete \(store.clearConfirmation?.count ?? 0) completed todos?",
                isPresented: store.isPresented(\.clearConfirmation, dismiss: .clearCompletedDismissed)
            ) {
                Button("Delete", role: .destructive) { store.send(.clearCompletedConfirmed) }
            }
        }
    }
}

private struct TodoRow: View {
    let todo: Todo
    let toggle: () -> Void

    var body: some View {
        HStack {
            Button(action: toggle) {
                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
            .accessibilityLabel(todo.isDone ? "Mark as not done" : "Mark as done")
            NavigationLink(value: todo.id) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
            }
        }
    }
}

private struct TodoDetailView: View {
    let store: Store<Todos.State, Todos.Action>
    let id: Todo.ID

    var body: some View {
        if let todo = store.state.todo(id) {
            Form {
                Section("Title") {
                    Text(todo.title)
                }
                Section("Notes") {
                    // A per-item binding: read the item, send an action with its id.
                    TextField("Notes", text: Binding(
                        get: { todo.notes },
                        set: { store.send(.notesChanged(id, $0)) }
                    ), axis: .vertical)
                }
                Section {
                    Toggle("Done", isOn: Binding(
                        get: { todo.isDone },
                        set: { _ in store.send(.toggleDone(id)) }
                    ))
                    ShareLink(item: TodoLink.url(for: id)) {
                        Label("Share a link to this todo", systemImage: "link")
                    }
                    Button("Delete", role: .destructive) { store.send(.deleteTapped(id)) }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(todo.title)
        } else {
            ContentUnavailableView("Deleted", systemImage: "trash")
        }
    }
}

private struct EditorView: View {
    let store: Store<Todos.State, Todos.Action>
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: store.binding(\.editorTitle, send: Todos.Action.editorTitleChanged))
                    .focused($titleFocused)
                    .onSubmit { store.send(.editorSaveTapped) }
            }
            .formStyle(.grouped)
            .navigationTitle("New todo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { store.send(.editorDismissed) }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { store.send(.editorSaveTapped) }
                        .disabled(store.editorTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
        .presentationDetents([.medium])
    }
}
