//
//  TodoApp.swift
//  SwiftUIStateManagement
//
//  A comprehensive Todo application demonstrating the full capabilities
//  of the SwiftUIStateManagement framework including state management,
//  middleware integration, persistence, and time-travel debugging.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 All rights reserved.
//

import SwiftUI
import SwiftUIStateManagement

// MARK: - Domain Models

/// Represents the priority level of a todo item.
/// Priority affects sorting and visual representation.
public enum TodoPriority: String, Codable, CaseIterable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    public var id: String { rawValue }
    
    /// Display name for the priority level
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    /// Color associated with this priority level
    public var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    /// Sort order value (higher = more important)
    public var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .urgent: return 3
        }
    }
    
    /// System image name for the priority indicator
    public var iconName: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.circle.fill"
        }
    }
}

/// Represents a category for organizing todos
public struct TodoCategory: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var name: String
    public var colorHex: String
    public var iconName: String
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = createdAt
    }
    
    /// Predefined categories for quick setup
    public static let work = TodoCategory(name: "Work", colorHex: "#FF9500", iconName: "briefcase")
    public static let personal = TodoCategory(name: "Personal", colorHex: "#5856D6", iconName: "person")
    public static let shopping = TodoCategory(name: "Shopping", colorHex: "#34C759", iconName: "cart")
    public static let health = TodoCategory(name: "Health", colorHex: "#FF2D55", iconName: "heart")
    public static let education = TodoCategory(name: "Education", colorHex: "#007AFF", iconName: "book")
    
    public static let defaultCategories: [TodoCategory] = [
        .work, .personal, .shopping, .health, .education
    ]
}

/// Represents a single todo item with all its properties
public struct TodoItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var description: String
    public var isCompleted: Bool
    public var priority: TodoPriority
    public var categoryId: UUID?
    public var dueDate: Date?
    public var reminder: Date?
    public var tags: [String]
    public var subtasks: [Subtask]
    public var attachmentURLs: [URL]
    public var notes: String
    public var createdAt: Date
    public var updatedAt: Date
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: TodoPriority = .medium,
        categoryId: UUID? = nil,
        dueDate: Date? = nil,
        reminder: Date? = nil,
        tags: [String] = [],
        subtasks: [Subtask] = [],
        attachmentURLs: [URL] = [],
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.categoryId = categoryId
        self.dueDate = dueDate
        self.reminder = reminder
        self.tags = tags
        self.subtasks = subtasks
        self.attachmentURLs = attachmentURLs
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
    
    /// Calculates the completion percentage based on subtasks
    public var completionPercentage: Double {
        guard !subtasks.isEmpty else { return isCompleted ? 100.0 : 0.0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count) * 100.0
    }
    
    /// Checks if the todo is overdue
    public var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
    
    /// Checks if the todo is due today
    public var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    /// Checks if the todo is due this week
    public var isDueThisWeek: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Returns the number of days until due date
    public var daysUntilDue: Int? {
        guard let dueDate = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }
    
    /// Marks the todo as completed with timestamp
    public mutating func markCompleted() {
        isCompleted = true
        completedAt = Date()
        updatedAt = Date()
    }
    
    /// Marks the todo as incomplete
    public mutating func markIncomplete() {
        isCompleted = false
        completedAt = nil
        updatedAt = Date()
    }
}

/// Represents a subtask within a todo item
public struct Subtask: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - Application State

/// The complete state of the Todo application
public struct TodoAppState: Equatable, Codable {
    /// All todo items in the application
    public var todos: [TodoItem]
    
    /// All categories for organizing todos
    public var categories: [TodoCategory]
    
    /// Currently selected filter
    public var filter: TodoFilter
    
    /// Current sort option
    public var sortOption: TodoSortOption
    
    /// Search query for filtering todos
    public var searchQuery: String
    
    /// Currently selected category ID for filtering
    public var selectedCategoryId: UUID?
    
    /// Whether the app is loading data
    public var isLoading: Bool
    
    /// Error message if any operation failed
    public var errorMessage: String?
    
    /// Whether to show completed todos
    public var showCompleted: Bool
    
    /// User preferences
    public var preferences: TodoPreferences
    
    /// Statistics about todos
    public var statistics: TodoStatistics
    
    public init(
        todos: [TodoItem] = [],
        categories: [TodoCategory] = TodoCategory.defaultCategories,
        filter: TodoFilter = .all,
        sortOption: TodoSortOption = .dueDate,
        searchQuery: String = "",
        selectedCategoryId: UUID? = nil,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        showCompleted: Bool = true,
        preferences: TodoPreferences = TodoPreferences(),
        statistics: TodoStatistics = TodoStatistics()
    ) {
        self.todos = todos
        self.categories = categories
        self.filter = filter
        self.sortOption = sortOption
        self.searchQuery = searchQuery
        self.selectedCategoryId = selectedCategoryId
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.showCompleted = showCompleted
        self.preferences = preferences
        self.statistics = statistics
    }
    
    /// Returns filtered and sorted todos based on current state
    public var filteredTodos: [TodoItem] {
        var result = todos
        
        // Apply search filter
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { todo in
                todo.title.lowercased().contains(query) ||
                todo.description.lowercased().contains(query) ||
                todo.tags.contains { $0.lowercased().contains(query) }
            }
        }
        
        // Apply category filter
        if let categoryId = selectedCategoryId {
            result = result.filter { $0.categoryId == categoryId }
        }
        
        // Apply status filter
        switch filter {
        case .all:
            if !showCompleted {
                result = result.filter { !$0.isCompleted }
            }
        case .active:
            result = result.filter { !$0.isCompleted }
        case .completed:
            result = result.filter { $0.isCompleted }
        case .overdue:
            result = result.filter { $0.isOverdue }
        case .today:
            result = result.filter { $0.isDueToday }
        case .thisWeek:
            result = result.filter { $0.isDueThisWeek }
        case .priority(let priority):
            result = result.filter { $0.priority == priority }
        }
        
        // Apply sorting
        switch sortOption {
        case .dueDate:
            result.sort { first, second in
                guard let date1 = first.dueDate else { return false }
                guard let date2 = second.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            result.sort { $0.priority.sortOrder > $1.priority.sortOrder }
        case .alphabetical:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .createdDate:
            result.sort { $0.createdAt > $1.createdAt }
        case .updatedDate:
            result.sort { $0.updatedAt > $1.updatedAt }
        }
        
        return result
    }
    
    /// Returns the count of active (incomplete) todos
    public var activeTodoCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    /// Returns the count of completed todos
    public var completedTodoCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    /// Returns the count of overdue todos
    public var overdueTodoCount: Int {
        todos.filter { $0.isOverdue }.count
    }
}

/// Filter options for todos
public enum TodoFilter: Equatable, Codable {
    case all
    case active
    case completed
    case overdue
    case today
    case thisWeek
    case priority(TodoPriority)
    
    public var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .completed: return "Completed"
        case .overdue: return "Overdue"
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .priority(let p): return p.displayName
        }
    }
}

/// Sort options for todos
public enum TodoSortOption: String, Codable, CaseIterable {
    case dueDate = "dueDate"
    case priority = "priority"
    case alphabetical = "alphabetical"
    case createdDate = "createdDate"
    case updatedDate = "updatedDate"
    
    public var displayName: String {
        switch self {
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .alphabetical: return "Alphabetical"
        case .createdDate: return "Created Date"
        case .updatedDate: return "Updated Date"
        }
    }
}

/// User preferences for the todo app
public struct TodoPreferences: Equatable, Codable {
    public var defaultPriority: TodoPriority
    public var defaultCategoryId: UUID?
    public var enableNotifications: Bool
    public var notificationLeadTime: TimeInterval
    public var showBadgeCount: Bool
    public var hapticFeedback: Bool
    public var autoArchiveCompleted: Bool
    public var archiveAfterDays: Int
    public var theme: AppTheme
    
    public init(
        defaultPriority: TodoPriority = .medium,
        defaultCategoryId: UUID? = nil,
        enableNotifications: Bool = true,
        notificationLeadTime: TimeInterval = 3600,
        showBadgeCount: Bool = true,
        hapticFeedback: Bool = true,
        autoArchiveCompleted: Bool = false,
        archiveAfterDays: Int = 7,
        theme: AppTheme = .system
    ) {
        self.defaultPriority = defaultPriority
        self.defaultCategoryId = defaultCategoryId
        self.enableNotifications = enableNotifications
        self.notificationLeadTime = notificationLeadTime
        self.showBadgeCount = showBadgeCount
        self.hapticFeedback = hapticFeedback
        self.autoArchiveCompleted = autoArchiveCompleted
        self.archiveAfterDays = archiveAfterDays
        self.theme = theme
    }
}

/// Theme options for the app
public enum AppTheme: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

/// Statistics about todos
public struct TodoStatistics: Equatable, Codable {
    public var totalCreated: Int
    public var totalCompleted: Int
    public var currentStreak: Int
    public var longestStreak: Int
    public var averageCompletionTime: TimeInterval
    public var lastActivityDate: Date?
    public var completionsByDay: [String: Int]
    public var completionsByCategory: [UUID: Int]
    
    public init(
        totalCreated: Int = 0,
        totalCompleted: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        averageCompletionTime: TimeInterval = 0,
        lastActivityDate: Date? = nil,
        completionsByDay: [String: Int] = [:],
        completionsByCategory: [UUID: Int] = [:]
    ) {
        self.totalCreated = totalCreated
        self.totalCompleted = totalCompleted
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.averageCompletionTime = averageCompletionTime
        self.lastActivityDate = lastActivityDate
        self.completionsByDay = completionsByDay
        self.completionsByCategory = completionsByCategory
    }
    
    /// Calculates the completion rate as a percentage
    public var completionRate: Double {
        guard totalCreated > 0 else { return 0 }
        return Double(totalCompleted) / Double(totalCreated) * 100.0
    }
}

// MARK: - Actions

/// All possible actions that can be dispatched in the Todo app
public enum TodoAction: Action, Equatable {
    // CRUD Operations
    case addTodo(TodoItem)
    case updateTodo(TodoItem)
    case deleteTodo(UUID)
    case toggleTodoCompletion(UUID)
    case batchDelete([UUID])
    case batchComplete([UUID])
    case duplicateTodo(UUID)
    
    // Subtask Operations
    case addSubtask(todoId: UUID, subtask: Subtask)
    case updateSubtask(todoId: UUID, subtask: Subtask)
    case deleteSubtask(todoId: UUID, subtaskId: UUID)
    case toggleSubtaskCompletion(todoId: UUID, subtaskId: UUID)
    
    // Category Operations
    case addCategory(TodoCategory)
    case updateCategory(TodoCategory)
    case deleteCategory(UUID)
    case setSelectedCategory(UUID?)
    
    // Filter and Sort Operations
    case setFilter(TodoFilter)
    case setSortOption(TodoSortOption)
    case setSearchQuery(String)
    case toggleShowCompleted
    case clearFilters
    
    // Preferences
    case updatePreferences(TodoPreferences)
    
    // Data Operations
    case loadTodos
    case loadTodosSuccess([TodoItem])
    case loadTodosFailure(String)
    case saveTodos
    case saveTodosSuccess
    case saveTodosFailure(String)
    case clearAllTodos
    case clearCompletedTodos
    case importTodos([TodoItem])
    case exportTodos
    
    // Statistics
    case updateStatistics
    case resetStatistics
    
    // UI State
    case setLoading(Bool)
    case setError(String?)
    case dismissError
    
    // Sync Operations
    case syncWithCloud
    case syncSuccess
    case syncFailure(String)
}

// MARK: - Reducer

/// The main reducer for the Todo application
public struct TodoReducer: Reducer {
    public typealias State = TodoAppState
    public typealias ActionType = TodoAction
    
    public init() {}
    
    public func reduce(state: inout TodoAppState, action: TodoAction) -> Effect<TodoAction> {
        switch action {
        // MARK: - CRUD Operations
        case .addTodo(let todo):
            state.todos.append(todo)
            state.statistics.totalCreated += 1
            state.statistics.lastActivityDate = Date()
            return Effect.merge([
                Effect.send(.saveTodos),
                Effect.send(.updateStatistics)
            ])
            
        case .updateTodo(let updatedTodo):
            if let index = state.todos.firstIndex(where: { $0.id == updatedTodo.id }) {
                var todo = updatedTodo
                todo.updatedAt = Date()
                state.todos[index] = todo
            }
            return Effect.send(.saveTodos)
            
        case .deleteTodo(let id):
            state.todos.removeAll { $0.id == id }
            return Effect.send(.saveTodos)
            
        case .toggleTodoCompletion(let id):
            if let index = state.todos.firstIndex(where: { $0.id == id }) {
                if state.todos[index].isCompleted {
                    state.todos[index].markIncomplete()
                } else {
                    state.todos[index].markCompleted()
                    state.statistics.totalCompleted += 1
                }
                state.statistics.lastActivityDate = Date()
            }
            return Effect.merge([
                Effect.send(.saveTodos),
                Effect.send(.updateStatistics)
            ])
            
        case .batchDelete(let ids):
            state.todos.removeAll { ids.contains($0.id) }
            return Effect.send(.saveTodos)
            
        case .batchComplete(let ids):
            for id in ids {
                if let index = state.todos.firstIndex(where: { $0.id == id }) {
                    if !state.todos[index].isCompleted {
                        state.todos[index].markCompleted()
                        state.statistics.totalCompleted += 1
                    }
                }
            }
            return Effect.merge([
                Effect.send(.saveTodos),
                Effect.send(.updateStatistics)
            ])
            
        case .duplicateTodo(let id):
            if let original = state.todos.first(where: { $0.id == id }) {
                var duplicate = original
                duplicate = TodoItem(
                    title: "\(original.title) (Copy)",
                    description: original.description,
                    priority: original.priority,
                    categoryId: original.categoryId,
                    dueDate: original.dueDate,
                    tags: original.tags,
                    subtasks: original.subtasks.map { Subtask(title: $0.title) },
                    notes: original.notes
                )
                state.todos.append(duplicate)
                state.statistics.totalCreated += 1
            }
            return Effect.send(.saveTodos)
            
        // MARK: - Subtask Operations
        case .addSubtask(let todoId, let subtask):
            if let index = state.todos.firstIndex(where: { $0.id == todoId }) {
                state.todos[index].subtasks.append(subtask)
                state.todos[index].updatedAt = Date()
            }
            return Effect.send(.saveTodos)
            
        case .updateSubtask(let todoId, let subtask):
            if let todoIndex = state.todos.firstIndex(where: { $0.id == todoId }),
               let subtaskIndex = state.todos[todoIndex].subtasks.firstIndex(where: { $0.id == subtask.id }) {
                state.todos[todoIndex].subtasks[subtaskIndex] = subtask
                state.todos[todoIndex].updatedAt = Date()
            }
            return Effect.send(.saveTodos)
            
        case .deleteSubtask(let todoId, let subtaskId):
            if let todoIndex = state.todos.firstIndex(where: { $0.id == todoId }) {
                state.todos[todoIndex].subtasks.removeAll { $0.id == subtaskId }
                state.todos[todoIndex].updatedAt = Date()
            }
            return Effect.send(.saveTodos)
            
        case .toggleSubtaskCompletion(let todoId, let subtaskId):
            if let todoIndex = state.todos.firstIndex(where: { $0.id == todoId }),
               let subtaskIndex = state.todos[todoIndex].subtasks.firstIndex(where: { $0.id == subtaskId }) {
                state.todos[todoIndex].subtasks[subtaskIndex].isCompleted.toggle()
                state.todos[todoIndex].updatedAt = Date()
                
                // Auto-complete parent if all subtasks done
                let allSubtasksComplete = state.todos[todoIndex].subtasks.allSatisfy { $0.isCompleted }
                if allSubtasksComplete && !state.todos[todoIndex].isCompleted {
                    state.todos[todoIndex].markCompleted()
                    state.statistics.totalCompleted += 1
                }
            }
            return Effect.send(.saveTodos)
            
        // MARK: - Category Operations
        case .addCategory(let category):
            state.categories.append(category)
            return .none
            
        case .updateCategory(let category):
            if let index = state.categories.firstIndex(where: { $0.id == category.id }) {
                state.categories[index] = category
            }
            return .none
            
        case .deleteCategory(let id):
            state.categories.removeAll { $0.id == id }
            // Remove category from todos
            for index in state.todos.indices {
                if state.todos[index].categoryId == id {
                    state.todos[index].categoryId = nil
                }
            }
            if state.selectedCategoryId == id {
                state.selectedCategoryId = nil
            }
            return Effect.send(.saveTodos)
            
        case .setSelectedCategory(let categoryId):
            state.selectedCategoryId = categoryId
            return .none
            
        // MARK: - Filter and Sort Operations
        case .setFilter(let filter):
            state.filter = filter
            return .none
            
        case .setSortOption(let option):
            state.sortOption = option
            return .none
            
        case .setSearchQuery(let query):
            state.searchQuery = query
            return .none
            
        case .toggleShowCompleted:
            state.showCompleted.toggle()
            return .none
            
        case .clearFilters:
            state.filter = .all
            state.searchQuery = ""
            state.selectedCategoryId = nil
            state.showCompleted = true
            return .none
            
        // MARK: - Preferences
        case .updatePreferences(let preferences):
            state.preferences = preferences
            return .none
            
        // MARK: - Data Operations
        case .loadTodos:
            state.isLoading = true
            state.errorMessage = nil
            return .none
            
        case .loadTodosSuccess(let todos):
            state.todos = todos
            state.isLoading = false
            return Effect.send(.updateStatistics)
            
        case .loadTodosFailure(let error):
            state.isLoading = false
            state.errorMessage = error
            return .none
            
        case .saveTodos:
            return .none
            
        case .saveTodosSuccess:
            return .none
            
        case .saveTodosFailure(let error):
            state.errorMessage = error
            return .none
            
        case .clearAllTodos:
            state.todos.removeAll()
            state.statistics = TodoStatistics()
            return Effect.send(.saveTodos)
            
        case .clearCompletedTodos:
            state.todos.removeAll { $0.isCompleted }
            return Effect.send(.saveTodos)
            
        case .importTodos(let todos):
            state.todos.append(contentsOf: todos)
            state.statistics.totalCreated += todos.count
            return Effect.merge([
                Effect.send(.saveTodos),
                Effect.send(.updateStatistics)
            ])
            
        case .exportTodos:
            // Handle by middleware
            return .none
            
        // MARK: - Statistics
        case .updateStatistics:
            updateStatistics(&state)
            return .none
            
        case .resetStatistics:
            state.statistics = TodoStatistics()
            return .none
            
        // MARK: - UI State
        case .setLoading(let loading):
            state.isLoading = loading
            return .none
            
        case .setError(let error):
            state.errorMessage = error
            return .none
            
        case .dismissError:
            state.errorMessage = nil
            return .none
            
        // MARK: - Sync Operations
        case .syncWithCloud:
            state.isLoading = true
            return .none
            
        case .syncSuccess:
            state.isLoading = false
            return .none
            
        case .syncFailure(let error):
            state.isLoading = false
            state.errorMessage = error
            return .none
        }
    }
    
    /// Updates the statistics based on current state
    private func updateStatistics(_ state: inout TodoAppState) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Calculate completions by day
        var completionsByDay: [String: Int] = [:]
        for todo in state.todos where todo.isCompleted {
            if let completedAt = todo.completedAt {
                let key = dateFormatter.string(from: completedAt)
                completionsByDay[key, default: 0] += 1
            }
        }
        state.statistics.completionsByDay = completionsByDay
        
        // Calculate completions by category
        var completionsByCategory: [UUID: Int] = [:]
        for todo in state.todos where todo.isCompleted {
            if let categoryId = todo.categoryId {
                completionsByCategory[categoryId, default: 0] += 1
            }
        }
        state.statistics.completionsByCategory = completionsByCategory
        
        // Calculate average completion time
        var totalTime: TimeInterval = 0
        var count = 0
        for todo in state.todos where todo.isCompleted {
            if let completedAt = todo.completedAt {
                totalTime += completedAt.timeIntervalSince(todo.createdAt)
                count += 1
            }
        }
        state.statistics.averageCompletionTime = count > 0 ? totalTime / Double(count) : 0
        
        // Calculate streak
        calculateStreak(&state.statistics, completionsByDay: completionsByDay)
    }
    
    /// Calculates the current and longest streak
    private func calculateStreak(_ statistics: inout TodoStatistics, completionsByDay: [String: Int]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var currentStreak = 0
        var longestStreak = 0
        var streakCount = 0
        
        let sortedDays = completionsByDay.keys.sorted().reversed()
        var previousDate: Date?
        
        for dayString in sortedDays {
            guard let date = dateFormatter.date(from: dayString) else { continue }
            
            if let previous = previousDate {
                let daysDiff = Calendar.current.dateComponents([.day], from: date, to: previous).day ?? 0
                if daysDiff == 1 {
                    streakCount += 1
                } else {
                    longestStreak = max(longestStreak, streakCount)
                    streakCount = 1
                }
            } else {
                streakCount = 1
                if Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date) {
                    currentStreak = 1
                }
            }
            
            previousDate = date
        }
        
        longestStreak = max(longestStreak, streakCount)
        statistics.currentStreak = currentStreak
        statistics.longestStreak = longestStreak
    }
}
