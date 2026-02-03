//
//  TodoViews.swift
//  SwiftUIStateManagement
//
//  SwiftUI views for the Todo application demonstrating
//  integration with the state management framework.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 All rights reserved.
//

import SwiftUI
import SwiftUIStateManagement

// MARK: - Main Todo List View

/// The main view displaying the list of todos
public struct TodoListView: View {
    @ObservedObject private var store: Store<TodoAppState, TodoAction>
    @State private var showingAddTodo = false
    @State private var showingSettings = false
    @State private var selectedTodo: TodoItem?
    @State private var editMode: EditMode = .inactive
    @State private var selectedTodos: Set<UUID> = []
    
    public init(store: Store<TodoAppState, TodoAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                if store.state.isLoading && store.state.todos.isEmpty {
                    LoadingView()
                } else if store.state.todos.isEmpty {
                    EmptyStateView(onAddTodo: { showingAddTodo = true })
                } else {
                    todoListContent
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                leadingToolbarItems
                trailingToolbarItems
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView(store: store)
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(store: store, todo: todo)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(store: store)
            }
            .alert("Error", isPresented: .constant(store.state.errorMessage != nil)) {
                Button("OK") {
                    store.send(.dismissError)
                }
            } message: {
                Text(store.state.errorMessage ?? "")
            }
            .environment(\.editMode, $editMode)
        }
        .onAppear {
            store.send(.loadTodos)
        }
    }
    
    // MARK: - Todo List Content
    
    private var todoListContent: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            SearchFilterBar(
                searchText: Binding(
                    get: { store.state.searchQuery },
                    set: { store.send(.setSearchQuery($0)) }
                ),
                filter: store.state.filter,
                onFilterChange: { store.send(.setFilter($0)) }
            )
            
            // Category Pills
            if !store.state.categories.isEmpty {
                CategoryPillsView(
                    categories: store.state.categories,
                    selectedId: store.state.selectedCategoryId,
                    onSelect: { store.send(.setSelectedCategory($0)) }
                )
            }
            
            // Stats Summary
            StatsSummaryBar(state: store.state)
            
            // Todo List
            List(selection: $selectedTodos) {
                ForEach(store.state.filteredTodos) { todo in
                    TodoRowView(
                        todo: todo,
                        category: store.state.categories.first { $0.id == todo.categoryId },
                        onToggle: { store.send(.toggleTodoCompletion(todo.id)) },
                        onTap: { selectedTodo = todo }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.send(.deleteTodo(todo.id))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            store.send(.duplicateTodo(todo.id))
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            store.send(.toggleTodoCompletion(todo.id))
                        } label: {
                            Label(
                                todo.isCompleted ? "Incomplete" : "Complete",
                                systemImage: todo.isCompleted ? "xmark.circle" : "checkmark.circle"
                            )
                        }
                        .tint(todo.isCompleted ? .orange : .green)
                    }
                }
                .onDelete { indexSet in
                    let ids = indexSet.map { store.state.filteredTodos[$0].id }
                    store.send(.batchDelete(ids))
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                store.send(.loadTodos)
            }
            
            // Batch Actions Bar
            if editMode == .active && !selectedTodos.isEmpty {
                BatchActionsBar(
                    selectedCount: selectedTodos.count,
                    onComplete: {
                        store.send(.batchComplete(Array(selectedTodos)))
                        selectedTodos.removeAll()
                    },
                    onDelete: {
                        store.send(.batchDelete(Array(selectedTodos)))
                        selectedTodos.removeAll()
                    }
                )
            }
        }
    }
    
    // MARK: - Toolbar Items
    
    private var leadingToolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            EditButton()
            
            Menu {
                ForEach(TodoSortOption.allCases, id: \.self) { option in
                    Button {
                        store.send(.setSortOption(option))
                    } label: {
                        HStack {
                            Text(option.displayName)
                            if store.state.sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    
    private var trailingToolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gear")
            }
            
            Button {
                showingAddTodo = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

// MARK: - Search and Filter Bar

/// Search bar with filter options
struct SearchFilterBar: View {
    @Binding var searchText: String
    let filter: TodoFilter
    let onFilterChange: (TodoFilter) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search todos...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterPill(title: "All", isSelected: filter == .all) {
                        onFilterChange(.all)
                    }
                    FilterPill(title: "Active", isSelected: filter == .active) {
                        onFilterChange(.active)
                    }
                    FilterPill(title: "Completed", isSelected: filter == .completed) {
                        onFilterChange(.completed)
                    }
                    FilterPill(title: "Overdue", isSelected: filter == .overdue) {
                        onFilterChange(.overdue)
                    }
                    FilterPill(title: "Today", isSelected: filter == .today) {
                        onFilterChange(.today)
                    }
                    FilterPill(title: "This Week", isSelected: filter == .thisWeek) {
                        onFilterChange(.thisWeek)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

/// Individual filter pill button
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .cornerRadius(16)
        }
    }
}

// MARK: - Category Pills View

/// Horizontal scrollable category selection
struct CategoryPillsView: View {
    let categories: [TodoCategory]
    let selectedId: UUID?
    let onSelect: (UUID?) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All Categories
                CategoryPill(
                    name: "All",
                    iconName: "tray.full",
                    isSelected: selectedId == nil
                ) {
                    onSelect(nil)
                }
                
                ForEach(categories) { category in
                    CategoryPill(
                        name: category.name,
                        iconName: category.iconName,
                        isSelected: selectedId == category.id
                    ) {
                        onSelect(category.id)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 4)
    }
}

/// Individual category pill
struct CategoryPill: View {
    let name: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .cornerRadius(14)
        }
    }
}

// MARK: - Stats Summary Bar

/// Quick stats summary displayed above the list
struct StatsSummaryBar: View {
    let state: TodoAppState
    
    var body: some View {
        HStack(spacing: 16) {
            StatItem(value: state.activeTodoCount, label: "Active", color: .blue)
            StatItem(value: state.completedTodoCount, label: "Done", color: .green)
            StatItem(value: state.overdueTodoCount, label: "Overdue", color: .red)
            
            Spacer()
            
            // Completion Progress
            CircularProgressView(
                progress: Double(state.completedTodoCount) / max(Double(state.todos.count), 1),
                size: 36
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
    }
}

/// Individual stat item
struct StatItem: View {
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

/// Circular progress indicator
struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.3, weight: .semibold))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Todo Row View

/// Individual todo item row
struct TodoRowView: View {
    let todo: TodoItem
    let category: TodoCategory?
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Checkbox
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .font(.body)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    
                    if todo.priority == .urgent {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 8) {
                    // Priority Badge
                    PriorityBadge(priority: todo.priority)
                    
                    // Category
                    if let category = category {
                        HStack(spacing: 2) {
                            Image(systemName: category.iconName)
                            Text(category.name)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                    
                    // Due Date
                    if let dueDate = todo.dueDate {
                        DueDateBadge(date: dueDate, isOverdue: todo.isOverdue)
                    }
                    
                    // Subtask Progress
                    if !todo.subtasks.isEmpty {
                        SubtaskProgressBadge(
                            completed: todo.subtasks.filter { $0.isCompleted }.count,
                            total: todo.subtasks.count
                        )
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

/// Priority indicator badge
struct PriorityBadge: View {
    let priority: TodoPriority
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: priority.iconName)
            Text(priority.displayName)
        }
        .font(.caption2)
        .foregroundColor(priority.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(priority.color.opacity(0.15))
        .cornerRadius(4)
    }
}

/// Due date badge with color coding
struct DueDateBadge: View {
    let date: Date
    let isOverdue: Bool
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
            Text(formatter.string(from: date))
        }
        .font(.caption2)
        .foregroundColor(isOverdue ? .red : .secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(isOverdue ? Color.red.opacity(0.15) : Color(.systemGray5))
        .cornerRadius(4)
    }
}

/// Subtask progress badge
struct SubtaskProgressBadge: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "checklist")
            Text("\(completed)/\(total)")
        }
        .font(.caption2)
        .foregroundColor(.secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGray5))
        .cornerRadius(4)
    }
}

// MARK: - Batch Actions Bar

/// Bottom bar for batch actions when in edit mode
struct BatchActionsBar: View {
    let selectedCount: Int
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text("\(selectedCount) selected")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: onComplete) {
                Label("Complete All", systemImage: "checkmark.circle")
            }
            .buttonStyle(.bordered)
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(radius: 2)
    }
}

// MARK: - Loading View

/// Loading indicator view
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading todos...")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Empty State View

/// View shown when there are no todos
struct EmptyStateView: View {
    let onAddTodo: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Todos Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add your first todo to get started!")
                    .foregroundColor(.secondary)
            }
            
            Button(action: onAddTodo) {
                Label("Add Todo", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Add Todo View

/// Sheet for adding a new todo
struct AddTodoView: View {
    @ObservedObject var store: Store<TodoAppState, TodoAction>
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TodoPriority = .medium
    @State private var selectedCategoryId: UUID?
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasReminder = false
    @State private var reminder = Date()
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info Section
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Priority & Category Section
                Section("Organization") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TodoPriority.allCases) { p in
                            HStack {
                                Image(systemName: p.iconName)
                                    .foregroundColor(p.color)
                                Text(p.displayName)
                            }
                            .tag(p)
                        }
                    }
                    
                    Picker("Category", selection: $selectedCategoryId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(store.state.categories) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                Text(category.name)
                            }
                            .tag(category.id as UUID?)
                        }
                    }
                }
                
                // Date Section
                Section("Dates") {
                    Toggle("Has Due Date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Toggle("Set Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Reminder", selection: $reminder, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // Tags Section
                Section("Tags") {
                    FlowLayout(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagChip(tag: tag) {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                    
                    HStack {
                        TextField("Add tag", text: $newTag)
                            .onSubmit(addTag)
                        
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTag.isEmpty)
                    }
                }
                
                // Notes Section
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTodo()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespaces)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        newTag = ""
    }
    
    private func saveTodo() {
        let todo = TodoItem(
            title: title,
            description: description,
            priority: priority,
            categoryId: selectedCategoryId,
            dueDate: hasDueDate ? dueDate : nil,
            reminder: hasReminder ? reminder : nil,
            tags: tags,
            notes: notes
        )
        store.send(.addTodo(todo))
        dismiss()
    }
}

/// Individual tag chip with delete button
struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.15))
        .foregroundColor(.accentColor)
        .cornerRadius(8)
    }
}

/// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}

// MARK: - Todo Detail View

/// Detailed view of a single todo
struct TodoDetailView: View {
    @ObservedObject var store: Store<TodoAppState, TodoAction>
    let todo: TodoItem
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedTodo: TodoItem
    @State private var isEditing = false
    @State private var newSubtaskTitle = ""
    
    init(store: Store<TodoAppState, TodoAction>, todo: TodoItem) {
        self.store = store
        self.todo = todo
        self._editedTodo = State(initialValue: todo)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    todoHeader
                    
                    Divider()
                    
                    // Description
                    if !editedTodo.description.isEmpty {
                        descriptionSection
                    }
                    
                    // Subtasks
                    subtasksSection
                    
                    // Details
                    detailsSection
                    
                    // Notes
                    if !editedTodo.notes.isEmpty {
                        notesSection
                    }
                    
                    // Metadata
                    metadataSection
                }
                .padding()
            }
            .navigationTitle("Todo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            store.send(.updateTodo(editedTodo))
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
    
    private var todoHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    editedTodo.isCompleted.toggle()
                    if editedTodo.isCompleted {
                        editedTodo.completedAt = Date()
                    } else {
                        editedTodo.completedAt = nil
                    }
                    store.send(.updateTodo(editedTodo))
                } label: {
                    Image(systemName: editedTodo.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(editedTodo.isCompleted ? .green : .gray)
                }
                
                if isEditing {
                    TextField("Title", text: $editedTodo.title)
                        .font(.title2.bold())
                } else {
                    Text(editedTodo.title)
                        .font(.title2.bold())
                        .strikethrough(editedTodo.isCompleted)
                }
            }
            
            HStack(spacing: 12) {
                PriorityBadge(priority: editedTodo.priority)
                
                if let category = store.state.categories.first(where: { $0.id == editedTodo.categoryId }) {
                    HStack(spacing: 4) {
                        Image(systemName: category.iconName)
                        Text(category.name)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                if let dueDate = editedTodo.dueDate {
                    DueDateBadge(date: dueDate, isOverdue: editedTodo.isOverdue)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            
            if isEditing {
                TextField("Description", text: $editedTodo.description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(editedTodo.description)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Subtasks")
                    .font(.headline)
                
                Spacer()
                
                Text("\(editedTodo.subtasks.filter { $0.isCompleted }.count)/\(editedTodo.subtasks.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(editedTodo.subtasks) { subtask in
                HStack {
                    Button {
                        store.send(.toggleSubtaskCompletion(todoId: todo.id, subtaskId: subtask.id))
                        if let index = editedTodo.subtasks.firstIndex(where: { $0.id == subtask.id }) {
                            editedTodo.subtasks[index].isCompleted.toggle()
                        }
                    } label: {
                        Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                            .foregroundColor(subtask.isCompleted ? .green : .gray)
                    }
                    
                    Text(subtask.title)
                        .strikethrough(subtask.isCompleted)
                        .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    if isEditing {
                        Button {
                            store.send(.deleteSubtask(todoId: todo.id, subtaskId: subtask.id))
                            editedTodo.subtasks.removeAll { $0.id == subtask.id }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Add subtask
            HStack {
                TextField("New subtask", text: $newSubtaskTitle)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    let subtask = Subtask(title: newSubtaskTitle)
                    store.send(.addSubtask(todoId: todo.id, subtask: subtask))
                    editedTodo.subtasks.append(subtask)
                    newSubtaskTitle = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newSubtaskTitle.isEmpty)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            if isEditing {
                Picker("Priority", selection: $editedTodo.priority) {
                    ForEach(TodoPriority.allCases) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                
                Picker("Category", selection: $editedTodo.categoryId) {
                    Text("None").tag(nil as UUID?)
                    ForEach(store.state.categories) { category in
                        Text(category.name).tag(category.id as UUID?)
                    }
                }
            }
            
            // Tags
            if !editedTodo.tags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tags")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(editedTodo.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $editedTodo.notes)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                Text(editedTodo.notes)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Activity")
                .font(.headline)
            
            HStack {
                Text("Created:")
                    .foregroundColor(.secondary)
                Text(editedTodo.createdAt.formatted())
            }
            .font(.caption)
            
            HStack {
                Text("Updated:")
                    .foregroundColor(.secondary)
                Text(editedTodo.updatedAt.formatted())
            }
            .font(.caption)
            
            if let completedAt = editedTodo.completedAt {
                HStack {
                    Text("Completed:")
                        .foregroundColor(.secondary)
                    Text(completedAt.formatted())
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Settings View

/// Application settings view
struct SettingsView: View {
    @ObservedObject var store: Store<TodoAppState, TodoAction>
    @Environment(\.dismiss) private var dismiss
    
    @State private var preferences: TodoPreferences
    
    init(store: Store<TodoAppState, TodoAction>) {
        self.store = store
        self._preferences = State(initialValue: store.state.preferences)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Default Settings
                Section("Defaults") {
                    Picker("Default Priority", selection: $preferences.defaultPriority) {
                        ForEach(TodoPriority.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    
                    Picker("Default Category", selection: $preferences.defaultCategoryId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(store.state.categories) { category in
                            Text(category.name).tag(category.id as UUID?)
                        }
                    }
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $preferences.enableNotifications)
                    Toggle("Show Badge Count", isOn: $preferences.showBadgeCount)
                }
                
                // Experience
                Section("Experience") {
                    Toggle("Haptic Feedback", isOn: $preferences.hapticFeedback)
                    
                    Picker("Theme", selection: $preferences.theme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                }
                
                // Archive
                Section("Archive") {
                    Toggle("Auto-archive Completed", isOn: $preferences.autoArchiveCompleted)
                    
                    if preferences.autoArchiveCompleted {
                        Stepper("After \(preferences.archiveAfterDays) days", value: $preferences.archiveAfterDays, in: 1...30)
                    }
                }
                
                // Statistics
                Section("Statistics") {
                    HStack {
                        Text("Total Created")
                        Spacer()
                        Text("\(store.state.statistics.totalCreated)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Completed")
                        Spacer()
                        Text("\(store.state.statistics.totalCompleted)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completion Rate")
                        Spacer()
                        Text(String(format: "%.1f%%", store.state.statistics.completionRate))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Current Streak")
                        Spacer()
                        Text("\(store.state.statistics.currentStreak) days")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Reset Statistics") {
                        store.send(.resetStatistics)
                    }
                    .foregroundColor(.red)
                }
                
                // Data Management
                Section("Data Management") {
                    Button("Clear Completed Todos") {
                        store.send(.clearCompletedTodos)
                    }
                    
                    Button("Clear All Todos") {
                        store.send(.clearAllTodos)
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.send(.updatePreferences(preferences))
                        dismiss()
                    }
                }
            }
        }
    }
}
