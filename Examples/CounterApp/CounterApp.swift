//
//  CounterApp.swift
//  SwiftUIStateManagement
//
//  A comprehensive Counter application demonstrating state management
//  patterns including composition, effects, middleware, and testing.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 All rights reserved.
//

import SwiftUI
import Combine
import SwiftUIStateManagement

// MARK: - Counter State

/// The state for a single counter with history and statistics
public struct CounterState: Equatable, Codable {
    /// The current count value
    public var count: Int
    
    /// Step size for increment/decrement operations
    public var stepSize: Int
    
    /// Minimum allowed value
    public var minValue: Int
    
    /// Maximum allowed value
    public var maxValue: Int
    
    /// History of all count changes with timestamps
    public var history: [CounterHistoryEntry]
    
    /// Whether the counter is currently animating
    public var isAnimating: Bool
    
    /// Animation style for count changes
    public var animationStyle: CounterAnimationStyle
    
    /// Statistics about counter usage
    public var statistics: CounterStatistics
    
    /// Alert message to display
    public var alertMessage: String?
    
    /// Whether the counter is locked
    public var isLocked: Bool
    
    /// Custom name for the counter
    public var name: String
    
    /// Color theme for the counter
    public var colorTheme: CounterColorTheme
    
    public init(
        count: Int = 0,
        stepSize: Int = 1,
        minValue: Int = Int.min,
        maxValue: Int = Int.max,
        history: [CounterHistoryEntry] = [],
        isAnimating: Bool = false,
        animationStyle: CounterAnimationStyle = .spring,
        statistics: CounterStatistics = CounterStatistics(),
        alertMessage: String? = nil,
        isLocked: Bool = false,
        name: String = "Counter",
        colorTheme: CounterColorTheme = .blue
    ) {
        self.count = count
        self.stepSize = stepSize
        self.minValue = minValue
        self.maxValue = maxValue
        self.history = history
        self.isAnimating = isAnimating
        self.animationStyle = animationStyle
        self.statistics = statistics
        self.alertMessage = alertMessage
        self.isLocked = isLocked
        self.name = name
        self.colorTheme = colorTheme
    }
    
    /// Checks if increment is allowed
    public var canIncrement: Bool {
        !isLocked && count + stepSize <= maxValue
    }
    
    /// Checks if decrement is allowed
    public var canDecrement: Bool {
        !isLocked && count - stepSize >= minValue
    }
    
    /// Returns the percentage position between min and max
    public var progressPercentage: Double {
        guard maxValue != minValue else { return 0.5 }
        let range = Double(maxValue - minValue)
        let position = Double(count - minValue)
        return position / range
    }
    
    /// Returns the count as a formatted string
    public var formattedCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
}

/// A record of a count change
public struct CounterHistoryEntry: Identifiable, Equatable, Codable {
    public let id: UUID
    public let previousValue: Int
    public let newValue: Int
    public let changeType: CounterChangeType
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        previousValue: Int,
        newValue: Int,
        changeType: CounterChangeType,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.previousValue = previousValue
        self.newValue = newValue
        self.changeType = changeType
        self.timestamp = timestamp
    }
    
    /// The delta between previous and new value
    public var delta: Int {
        newValue - previousValue
    }
}

/// Types of changes that can occur to a counter
public enum CounterChangeType: String, Codable, CaseIterable {
    case increment = "increment"
    case decrement = "decrement"
    case set = "set"
    case reset = "reset"
    case random = "random"
    case double = "double"
    case halve = "halve"
    case negate = "negate"
    
    public var displayName: String {
        switch self {
        case .increment: return "Increment"
        case .decrement: return "Decrement"
        case .set: return "Set Value"
        case .reset: return "Reset"
        case .random: return "Random"
        case .double: return "Double"
        case .halve: return "Halve"
        case .negate: return "Negate"
        }
    }
    
    public var iconName: String {
        switch self {
        case .increment: return "plus"
        case .decrement: return "minus"
        case .set: return "number"
        case .reset: return "arrow.counterclockwise"
        case .random: return "dice"
        case .double: return "multiply"
        case .halve: return "divide"
        case .negate: return "plusminus"
        }
    }
}

/// Animation styles for counter changes
public enum CounterAnimationStyle: String, Codable, CaseIterable {
    case none = "none"
    case spring = "spring"
    case easeInOut = "easeInOut"
    case bounce = "bounce"
    case linear = "linear"
    
    public var displayName: String {
        switch self {
        case .none: return "None"
        case .spring: return "Spring"
        case .easeInOut: return "Ease In/Out"
        case .bounce: return "Bounce"
        case .linear: return "Linear"
        }
    }
    
    /// Returns the SwiftUI animation for this style
    public var animation: Animation? {
        switch self {
        case .none: return nil
        case .spring: return .spring(response: 0.3, dampingFraction: 0.6)
        case .easeInOut: return .easeInOut(duration: 0.2)
        case .bounce: return .interpolatingSpring(stiffness: 300, damping: 10)
        case .linear: return .linear(duration: 0.15)
        }
    }
}

/// Color themes for the counter
public enum CounterColorTheme: String, Codable, CaseIterable {
    case blue = "blue"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    case red = "red"
    case teal = "teal"
    
    public var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .red: return .red
        case .teal: return .teal
        }
    }
    
    public var gradient: LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// Statistics about counter usage
public struct CounterStatistics: Equatable, Codable {
    public var totalIncrements: Int
    public var totalDecrements: Int
    public var totalResets: Int
    public var highestValue: Int
    public var lowestValue: Int
    public var averageValue: Double
    public var sessionStartTime: Date
    public var lastActivityTime: Date?
    public var valueSum: Int
    public var valueCount: Int
    
    public init(
        totalIncrements: Int = 0,
        totalDecrements: Int = 0,
        totalResets: Int = 0,
        highestValue: Int = 0,
        lowestValue: Int = 0,
        averageValue: Double = 0,
        sessionStartTime: Date = Date(),
        lastActivityTime: Date? = nil,
        valueSum: Int = 0,
        valueCount: Int = 0
    ) {
        self.totalIncrements = totalIncrements
        self.totalDecrements = totalDecrements
        self.totalResets = totalResets
        self.highestValue = highestValue
        self.lowestValue = lowestValue
        self.averageValue = averageValue
        self.sessionStartTime = sessionStartTime
        self.lastActivityTime = lastActivityTime
        self.valueSum = valueSum
        self.valueCount = valueCount
    }
    
    /// Total number of operations
    public var totalOperations: Int {
        totalIncrements + totalDecrements + totalResets
    }
    
    /// Session duration
    public var sessionDuration: TimeInterval {
        (lastActivityTime ?? Date()).timeIntervalSince(sessionStartTime)
    }
    
    /// Operations per minute
    public var operationsPerMinute: Double {
        guard sessionDuration > 0 else { return 0 }
        return Double(totalOperations) / (sessionDuration / 60.0)
    }
    
    /// Updates the average with a new value
    public mutating func recordValue(_ value: Int) {
        valueSum += value
        valueCount += 1
        averageValue = Double(valueSum) / Double(valueCount)
        highestValue = max(highestValue, value)
        lowestValue = min(lowestValue, value)
        lastActivityTime = Date()
    }
}

// MARK: - Counter Actions

/// All possible actions for the counter
public enum CounterAction: Action, Equatable {
    // Basic Operations
    case increment
    case decrement
    case incrementBy(Int)
    case decrementBy(Int)
    case set(Int)
    case reset
    
    // Advanced Operations
    case randomize(min: Int, max: Int)
    case double
    case halve
    case negate
    case clamp(min: Int, max: Int)
    
    // Step Size
    case setStepSize(Int)
    case increaseStepSize
    case decreaseStepSize
    
    // Limits
    case setMinValue(Int)
    case setMaxValue(Int)
    case removeMinLimit
    case removeMaxLimit
    
    // UI State
    case setAnimating(Bool)
    case setAnimationStyle(CounterAnimationStyle)
    case showAlert(String)
    case dismissAlert
    case setLocked(Bool)
    case toggleLock
    
    // Customization
    case setName(String)
    case setColorTheme(CounterColorTheme)
    
    // History
    case undoLastChange
    case redoLastChange
    case clearHistory
    
    // Statistics
    case updateStatistics
    case resetStatistics
    
    // Persistence
    case save
    case load
    case loadSuccess(CounterState)
    case loadFailure(String)
    
    // Effects
    case startAutoIncrement(interval: TimeInterval)
    case stopAutoIncrement
    case delayedAction(CounterAction, delay: TimeInterval)
}

// MARK: - Counter Reducer

/// The reducer for counter state
public struct CounterReducer: Reducer {
    public typealias State = CounterState
    public typealias ActionType = CounterAction
    
    public init() {}
    
    public func reduce(state: inout CounterState, action: CounterAction) -> Effect<CounterAction> {
        switch action {
        // MARK: - Basic Operations
        case .increment:
            guard state.canIncrement else {
                return Effect.send(.showAlert("Cannot increment: maximum value reached"))
            }
            let previous = state.count
            state.count += state.stepSize
            state.statistics.totalIncrements += 1
            recordChange(&state, previous: previous, changeType: .increment)
            return Effect.send(.updateStatistics)
            
        case .decrement:
            guard state.canDecrement else {
                return Effect.send(.showAlert("Cannot decrement: minimum value reached"))
            }
            let previous = state.count
            state.count -= state.stepSize
            state.statistics.totalDecrements += 1
            recordChange(&state, previous: previous, changeType: .decrement)
            return Effect.send(.updateStatistics)
            
        case .incrementBy(let amount):
            guard !state.isLocked else { return .none }
            let previous = state.count
            state.count = min(state.count + amount, state.maxValue)
            recordChange(&state, previous: previous, changeType: .increment)
            return Effect.send(.updateStatistics)
            
        case .decrementBy(let amount):
            guard !state.isLocked else { return .none }
            let previous = state.count
            state.count = max(state.count - amount, state.minValue)
            recordChange(&state, previous: previous, changeType: .decrement)
            return Effect.send(.updateStatistics)
            
        case .set(let value):
            guard !state.isLocked else { return .none }
            let previous = state.count
            state.count = max(state.minValue, min(value, state.maxValue))
            recordChange(&state, previous: previous, changeType: .set)
            return Effect.send(.updateStatistics)
            
        case .reset:
            let previous = state.count
            state.count = 0
            state.statistics.totalResets += 1
            recordChange(&state, previous: previous, changeType: .reset)
            return Effect.send(.updateStatistics)
            
        // MARK: - Advanced Operations
        case .randomize(let min, let max):
            guard !state.isLocked else { return .none }
            let previous = state.count
            let effectiveMin = Swift.max(min, state.minValue)
            let effectiveMax = Swift.min(max, state.maxValue)
            guard effectiveMin <= effectiveMax else { return .none }
            state.count = Int.random(in: effectiveMin...effectiveMax)
            recordChange(&state, previous: previous, changeType: .random)
            return Effect.send(.updateStatistics)
            
        case .double:
            guard !state.isLocked else { return .none }
            let previous = state.count
            let doubled = state.count * 2
            state.count = min(doubled, state.maxValue)
            recordChange(&state, previous: previous, changeType: .double)
            return Effect.send(.updateStatistics)
            
        case .halve:
            guard !state.isLocked else { return .none }
            let previous = state.count
            state.count = state.count / 2
            recordChange(&state, previous: previous, changeType: .halve)
            return Effect.send(.updateStatistics)
            
        case .negate:
            guard !state.isLocked else { return .none }
            let previous = state.count
            let negated = -state.count
            if negated >= state.minValue && negated <= state.maxValue {
                state.count = negated
                recordChange(&state, previous: previous, changeType: .negate)
            }
            return Effect.send(.updateStatistics)
            
        case .clamp(let min, let max):
            let previous = state.count
            state.count = Swift.max(min, Swift.min(state.count, max))
            if state.count != previous {
                recordChange(&state, previous: previous, changeType: .set)
            }
            return .none
            
        // MARK: - Step Size
        case .setStepSize(let size):
            state.stepSize = max(1, size)
            return .none
            
        case .increaseStepSize:
            state.stepSize = min(state.stepSize * 2, 1000)
            return .none
            
        case .decreaseStepSize:
            state.stepSize = max(state.stepSize / 2, 1)
            return .none
            
        // MARK: - Limits
        case .setMinValue(let value):
            state.minValue = value
            if state.count < value {
                return Effect.send(.set(value))
            }
            return .none
            
        case .setMaxValue(let value):
            state.maxValue = value
            if state.count > value {
                return Effect.send(.set(value))
            }
            return .none
            
        case .removeMinLimit:
            state.minValue = Int.min
            return .none
            
        case .removeMaxLimit:
            state.maxValue = Int.max
            return .none
            
        // MARK: - UI State
        case .setAnimating(let animating):
            state.isAnimating = animating
            return .none
            
        case .setAnimationStyle(let style):
            state.animationStyle = style
            return .none
            
        case .showAlert(let message):
            state.alertMessage = message
            return .none
            
        case .dismissAlert:
            state.alertMessage = nil
            return .none
            
        case .setLocked(let locked):
            state.isLocked = locked
            return .none
            
        case .toggleLock:
            state.isLocked.toggle()
            return .none
            
        // MARK: - Customization
        case .setName(let name):
            state.name = name
            return .none
            
        case .setColorTheme(let theme):
            state.colorTheme = theme
            return .none
            
        // MARK: - History
        case .undoLastChange:
            guard let lastEntry = state.history.last else { return .none }
            state.count = lastEntry.previousValue
            state.history.removeLast()
            return .none
            
        case .redoLastChange:
            // Would need a separate redo stack for full implementation
            return .none
            
        case .clearHistory:
            state.history.removeAll()
            return .none
            
        // MARK: - Statistics
        case .updateStatistics:
            state.statistics.recordValue(state.count)
            return .none
            
        case .resetStatistics:
            state.statistics = CounterStatistics()
            state.history.removeAll()
            return .none
            
        // MARK: - Persistence
        case .save:
            // Handled by middleware
            return .none
            
        case .load:
            // Handled by middleware
            return .none
            
        case .loadSuccess(let loadedState):
            state = loadedState
            return .none
            
        case .loadFailure(let error):
            state.alertMessage = "Failed to load: \(error)"
            return .none
            
        // MARK: - Effects
        case .startAutoIncrement:
            // Handled by effect handler
            return .none
            
        case .stopAutoIncrement:
            // Handled by effect handler
            return .none
            
        case .delayedAction:
            // Handled by effect handler
            return .none
        }
    }
    
    /// Records a change in the history
    private func recordChange(_ state: inout CounterState, previous: Int, changeType: CounterChangeType) {
        let entry = CounterHistoryEntry(
            previousValue: previous,
            newValue: state.count,
            changeType: changeType
        )
        state.history.append(entry)
        
        // Limit history size
        if state.history.count > 100 {
            state.history.removeFirst()
        }
    }
}

// MARK: - Multi-Counter State

/// State for managing multiple counters
public struct MultiCounterState: Equatable, Codable {
    public var counters: [UUID: CounterState]
    public var selectedCounterId: UUID?
    public var isAddingCounter: Bool
    public var globalSettings: GlobalCounterSettings
    
    public init(
        counters: [UUID: CounterState] = [:],
        selectedCounterId: UUID? = nil,
        isAddingCounter: Bool = false,
        globalSettings: GlobalCounterSettings = GlobalCounterSettings()
    ) {
        self.counters = counters
        self.selectedCounterId = selectedCounterId
        self.isAddingCounter = isAddingCounter
        self.globalSettings = globalSettings
    }
    
    /// Returns the selected counter state
    public var selectedCounter: CounterState? {
        guard let id = selectedCounterId else { return nil }
        return counters[id]
    }
    
    /// Returns all counters sorted by name
    public var sortedCounters: [(id: UUID, state: CounterState)] {
        counters
            .sorted { $0.value.name < $1.value.name }
            .map { (id: $0.key, state: $0.value) }
    }
    
    /// Returns the total count across all counters
    public var totalCount: Int {
        counters.values.reduce(0) { $0 + $1.count }
    }
    
    /// Returns the average count across all counters
    public var averageCount: Double {
        guard !counters.isEmpty else { return 0 }
        return Double(totalCount) / Double(counters.count)
    }
}

/// Global settings applied to all counters
public struct GlobalCounterSettings: Equatable, Codable {
    public var defaultStepSize: Int
    public var defaultAnimationStyle: CounterAnimationStyle
    public var defaultColorTheme: CounterColorTheme
    public var syncCounters: Bool
    public var showStatistics: Bool
    public var hapticFeedback: Bool
    public var soundEffects: Bool
    
    public init(
        defaultStepSize: Int = 1,
        defaultAnimationStyle: CounterAnimationStyle = .spring,
        defaultColorTheme: CounterColorTheme = .blue,
        syncCounters: Bool = false,
        showStatistics: Bool = true,
        hapticFeedback: Bool = true,
        soundEffects: Bool = false
    ) {
        self.defaultStepSize = defaultStepSize
        self.defaultAnimationStyle = defaultAnimationStyle
        self.defaultColorTheme = defaultColorTheme
        self.syncCounters = syncCounters
        self.showStatistics = showStatistics
        self.hapticFeedback = hapticFeedback
        self.soundEffects = soundEffects
    }
}

// MARK: - Multi-Counter Actions

/// Actions for managing multiple counters
public enum MultiCounterAction: Action, Equatable {
    // Counter Management
    case addCounter(name: String)
    case removeCounter(UUID)
    case duplicateCounter(UUID)
    case selectCounter(UUID?)
    
    // Counter Actions (forwarded)
    case counter(id: UUID, action: CounterAction)
    
    // Batch Operations
    case resetAllCounters
    case incrementAllCounters
    case decrementAllCounters
    
    // UI State
    case setAddingCounter(Bool)
    
    // Settings
    case updateGlobalSettings(GlobalCounterSettings)
    
    // Persistence
    case saveAll
    case loadAll
    case loadAllSuccess([UUID: CounterState])
    case loadAllFailure(String)
}

// MARK: - Multi-Counter Reducer

/// Reducer for managing multiple counters
public struct MultiCounterReducer: Reducer {
    public typealias State = MultiCounterState
    public typealias ActionType = MultiCounterAction
    
    private let counterReducer = CounterReducer()
    
    public init() {}
    
    public func reduce(state: inout MultiCounterState, action: MultiCounterAction) -> Effect<MultiCounterAction> {
        switch action {
        // MARK: - Counter Management
        case .addCounter(let name):
            let id = UUID()
            var counter = CounterState(name: name)
            counter.stepSize = state.globalSettings.defaultStepSize
            counter.animationStyle = state.globalSettings.defaultAnimationStyle
            counter.colorTheme = state.globalSettings.defaultColorTheme
            state.counters[id] = counter
            state.selectedCounterId = id
            state.isAddingCounter = false
            return Effect.send(.saveAll)
            
        case .removeCounter(let id):
            state.counters.removeValue(forKey: id)
            if state.selectedCounterId == id {
                state.selectedCounterId = state.counters.keys.first
            }
            return Effect.send(.saveAll)
            
        case .duplicateCounter(let id):
            guard var counter = state.counters[id] else { return .none }
            let newId = UUID()
            counter.name = "\(counter.name) (Copy)"
            counter.history = []
            counter.statistics = CounterStatistics()
            state.counters[newId] = counter
            return Effect.send(.saveAll)
            
        case .selectCounter(let id):
            state.selectedCounterId = id
            return .none
            
        // MARK: - Counter Actions
        case .counter(let id, let action):
            guard var counter = state.counters[id] else { return .none }
            let effect = counterReducer.reduce(state: &counter, action: action)
            state.counters[id] = counter
            
            // Map the effect to our action type
            return effect.map { counterAction in
                MultiCounterAction.counter(id: id, action: counterAction)
            }
            
        // MARK: - Batch Operations
        case .resetAllCounters:
            var effects: [Effect<MultiCounterAction>] = []
            for id in state.counters.keys {
                effects.append(Effect.send(.counter(id: id, action: .reset)))
            }
            return Effect.merge(effects)
            
        case .incrementAllCounters:
            var effects: [Effect<MultiCounterAction>] = []
            for id in state.counters.keys {
                effects.append(Effect.send(.counter(id: id, action: .increment)))
            }
            return Effect.merge(effects)
            
        case .decrementAllCounters:
            var effects: [Effect<MultiCounterAction>] = []
            for id in state.counters.keys {
                effects.append(Effect.send(.counter(id: id, action: .decrement)))
            }
            return Effect.merge(effects)
            
        // MARK: - UI State
        case .setAddingCounter(let adding):
            state.isAddingCounter = adding
            return .none
            
        // MARK: - Settings
        case .updateGlobalSettings(let settings):
            state.globalSettings = settings
            return .none
            
        // MARK: - Persistence
        case .saveAll:
            // Handled by middleware
            return .none
            
        case .loadAll:
            // Handled by middleware
            return .none
            
        case .loadAllSuccess(let counters):
            state.counters = counters
            state.selectedCounterId = counters.keys.first
            return .none
            
        case .loadAllFailure(let error):
            // Show error somehow
            print("Failed to load counters: \(error)")
            return .none
        }
    }
}
