//
//  CounterViews.swift
//  SwiftUIStateManagement
//
//  SwiftUI views for the Counter application demonstrating
//  various state management patterns and UI components.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 All rights reserved.
//

import SwiftUI
import SwiftUIStateManagement

// MARK: - Single Counter View

/// Main view for a single counter with full functionality
public struct CounterView: View {
    @ObservedObject private var store: Store<CounterState, CounterAction>
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var showStatistics = false
    @State private var customValue: String = ""
    
    public init(store: Store<CounterState, CounterAction>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            store.state.colorTheme.gradient
                .opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                headerSection
                
                Spacer()
                
                // Counter Display
                counterDisplay
                
                // Progress Bar
                if store.state.minValue != Int.min && store.state.maxValue != Int.max {
                    progressBar
                }
                
                Spacer()
                
                // Main Controls
                mainControls
                
                // Additional Controls
                additionalControls
                
                // Quick Actions
                quickActionsBar
            }
            .padding()
        }
        .navigationTitle(store.state.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showSettings) {
            CounterSettingsView(store: store)
        }
        .sheet(isPresented: $showHistory) {
            CounterHistoryView(store: store)
        }
        .sheet(isPresented: $showStatistics) {
            CounterStatisticsView(store: store)
        }
        .alert("Notice", isPresented: .constant(store.state.alertMessage != nil)) {
            Button("OK") {
                store.send(.dismissAlert)
            }
        } message: {
            Text(store.state.alertMessage ?? "")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            // Lock indicator
            if store.state.isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
            }
            
            Spacer()
            
            // Step size indicator
            HStack(spacing: 4) {
                Text("Step:")
                    .foregroundColor(.secondary)
                Text("\(store.state.stepSize)")
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Counter Display
    
    private var counterDisplay: some View {
        VStack(spacing: 16) {
            // Main count display
            Text(store.state.formattedCount)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(store.state.colorTheme.color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .scaleEffect(store.state.isAnimating ? 1.1 : 1.0)
                .animation(store.state.animationStyle.animation, value: store.state.count)
            
            // Subtitle with limits
            if store.state.minValue != Int.min || store.state.maxValue != Int.max {
                HStack(spacing: 16) {
                    if store.state.minValue != Int.min {
                        Label("Min: \(store.state.minValue)", systemImage: "arrow.down.to.line")
                    }
                    if store.state.maxValue != Int.max {
                        Label("Max: \(store.state.maxValue)", systemImage: "arrow.up.to.line")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray4))
                    
                    Capsule()
                        .fill(store.state.colorTheme.gradient)
                        .frame(width: geo.size.width * store.state.progressPercentage)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(store.state.minValue)")
                Spacer()
                Text("\(Int(store.state.progressPercentage * 100))%")
                    .fontWeight(.medium)
                Spacer()
                Text("\(store.state.maxValue)")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Main Controls
    
    private var mainControls: some View {
        HStack(spacing: 40) {
            // Decrement Button
            CounterButton(
                systemImage: "minus",
                color: store.state.colorTheme.color,
                size: .large,
                isDisabled: !store.state.canDecrement
            ) {
                withAnimation(store.state.animationStyle.animation) {
                    store.send(.decrement)
                }
            }
            
            // Reset Button
            CounterButton(
                systemImage: "arrow.counterclockwise",
                color: .secondary,
                size: .medium
            ) {
                withAnimation(store.state.animationStyle.animation) {
                    store.send(.reset)
                }
            }
            
            // Increment Button
            CounterButton(
                systemImage: "plus",
                color: store.state.colorTheme.color,
                size: .large,
                isDisabled: !store.state.canIncrement
            ) {
                withAnimation(store.state.animationStyle.animation) {
                    store.send(.increment)
                }
            }
        }
    }
    
    // MARK: - Additional Controls
    
    private var additionalControls: some View {
        VStack(spacing: 16) {
            // Step size controls
            HStack {
                Text("Step Size")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        store.send(.decreaseStepSize)
                    } label: {
                        Image(systemName: "minus.circle")
                    }
                    .disabled(store.state.stepSize <= 1)
                    
                    Text("\(store.state.stepSize)")
                        .font(.headline)
                        .frame(minWidth: 40)
                    
                    Button {
                        store.send(.increaseStepSize)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .disabled(store.state.stepSize >= 1000)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Custom value input
            HStack {
                TextField("Set value", text: $customValue)
                    .keyboardType(.numbersAndPunctuation)
                    .textFieldStyle(.roundedBorder)
                
                Button("Set") {
                    if let value = Int(customValue) {
                        store.send(.set(value))
                        customValue = ""
                    }
                }
                .buttonStyle(.bordered)
                .disabled(Int(customValue) == nil)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Quick Actions Bar
    
    private var quickActionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Random",
                    icon: "dice",
                    color: .purple
                ) {
                    store.send(.randomize(min: store.state.minValue, max: store.state.maxValue))
                }
                
                QuickActionButton(
                    title: "Double",
                    icon: "multiply",
                    color: .green
                ) {
                    store.send(.double)
                }
                
                QuickActionButton(
                    title: "Halve",
                    icon: "divide",
                    color: .orange
                ) {
                    store.send(.halve)
                }
                
                QuickActionButton(
                    title: "Negate",
                    icon: "plusminus",
                    color: .red
                ) {
                    store.send(.negate)
                }
                
                QuickActionButton(
                    title: store.state.isLocked ? "Unlock" : "Lock",
                    icon: store.state.isLocked ? "lock.open" : "lock",
                    color: .yellow
                ) {
                    store.send(.toggleLock)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Toolbar
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                showStatistics = true
            } label: {
                Image(systemName: "chart.bar")
            }
            
            Button {
                showHistory = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
            }
            
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

// MARK: - Counter Button

/// A circular button used for counter operations
struct CounterButton: View {
    enum Size {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 60
            case .large: return 80
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small: return .title3
            case .medium: return .title2
            case .large: return .largeTitle
            }
        }
    }
    
    let systemImage: String
    let color: Color
    var size: Size = .medium
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(size.iconSize)
                .foregroundColor(isDisabled ? .gray : .white)
                .frame(width: size.dimension, height: size.dimension)
                .background(isDisabled ? Color.gray.opacity(0.3) : color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 0.95 : 1.0)
    }
}

// MARK: - Quick Action Button

/// Compact button for quick actions
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(color)
            .frame(width: 70, height: 60)
            .background(color.opacity(0.15))
            .cornerRadius(12)
        }
    }
}

// MARK: - Counter Settings View

/// Settings sheet for counter customization
struct CounterSettingsView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var stepSize: Int
    @State private var minValue: String
    @State private var maxValue: String
    @State private var hasMinLimit: Bool
    @State private var hasMaxLimit: Bool
    @State private var animationStyle: CounterAnimationStyle
    @State private var colorTheme: CounterColorTheme
    
    init(store: Store<CounterState, CounterAction>) {
        self.store = store
        let state = store.state
        self._name = State(initialValue: state.name)
        self._stepSize = State(initialValue: state.stepSize)
        self._minValue = State(initialValue: state.minValue == Int.min ? "" : "\(state.minValue)")
        self._maxValue = State(initialValue: state.maxValue == Int.max ? "" : "\(state.maxValue)")
        self._hasMinLimit = State(initialValue: state.minValue != Int.min)
        self._hasMaxLimit = State(initialValue: state.maxValue != Int.max)
        self._animationStyle = State(initialValue: state.animationStyle)
        self._colorTheme = State(initialValue: state.colorTheme)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Settings
                Section("General") {
                    TextField("Counter Name", text: $name)
                    
                    Stepper("Step Size: \(stepSize)", value: $stepSize, in: 1...1000)
                }
                
                // Limits
                Section("Limits") {
                    Toggle("Set Minimum", isOn: $hasMinLimit)
                    
                    if hasMinLimit {
                        TextField("Minimum Value", text: $minValue)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    
                    Toggle("Set Maximum", isOn: $hasMaxLimit)
                    
                    if hasMaxLimit {
                        TextField("Maximum Value", text: $maxValue)
                            .keyboardType(.numbersAndPunctuation)
                    }
                }
                
                // Appearance
                Section("Appearance") {
                    Picker("Animation Style", selection: $animationStyle) {
                        ForEach(CounterAnimationStyle.allCases, id: \.self) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    
                    Picker("Color Theme", selection: $colorTheme) {
                        ForEach(CounterColorTheme.allCases, id: \.self) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 20, height: 20)
                                Text(theme.rawValue.capitalized)
                            }
                            .tag(theme)
                        }
                    }
                }
                
                // Preview
                Section("Preview") {
                    HStack {
                        Spacer()
                        Text("42")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(colorTheme.color)
                        Spacer()
                    }
                    .padding()
                }
                
                // Danger Zone
                Section {
                    Button("Reset Statistics") {
                        store.send(.resetStatistics)
                    }
                    .foregroundColor(.orange)
                    
                    Button("Clear History") {
                        store.send(.clearHistory)
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
                        applySettings()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applySettings() {
        store.send(.setName(name))
        store.send(.setStepSize(stepSize))
        store.send(.setAnimationStyle(animationStyle))
        store.send(.setColorTheme(colorTheme))
        
        if hasMinLimit, let min = Int(minValue) {
            store.send(.setMinValue(min))
        } else {
            store.send(.removeMinLimit)
        }
        
        if hasMaxLimit, let max = Int(maxValue) {
            store.send(.setMaxValue(max))
        } else {
            store.send(.removeMaxLimit)
        }
    }
}

// MARK: - Counter History View

/// Shows the history of counter changes
struct CounterHistoryView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Group {
                if store.state.history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No History Yet")
                            .font(.headline)
                        Text("Changes to the counter will appear here")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(store.state.history.reversed()) { entry in
                            HistoryEntryRow(entry: entry)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !store.state.history.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Clear") {
                            store.send(.clearHistory)
                        }
                        .foregroundColor(.red)
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button("Undo") {
                            store.send(.undoLastChange)
                        }
                    }
                }
            }
        }
    }
}

/// Row displaying a single history entry
struct HistoryEntryRow: View {
    let entry: CounterHistoryEntry
    
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .short
        return f
    }
    
    var body: some View {
        HStack {
            // Icon
            Image(systemName: entry.changeType.iconName)
                .font(.title3)
                .foregroundColor(deltaColor)
                .frame(width: 40, height: 40)
                .background(deltaColor.opacity(0.15))
                .clipShape(Circle())
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.changeType.displayName)
                    .font(.headline)
                
                Text(formatter.string(from: entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Values
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Text("\(entry.previousValue)")
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                    Text("\(entry.newValue)")
                        .fontWeight(.semibold)
                }
                
                Text(deltaString)
                    .font(.caption)
                    .foregroundColor(deltaColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var deltaString: String {
        let delta = entry.delta
        if delta >= 0 {
            return "+\(delta)"
        } else {
            return "\(delta)"
        }
    }
    
    private var deltaColor: Color {
        if entry.delta > 0 {
            return .green
        } else if entry.delta < 0 {
            return .red
        } else {
            return .secondary
        }
    }
}

// MARK: - Counter Statistics View

/// Displays statistics about counter usage
struct CounterStatisticsView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Overview Section
                Section("Overview") {
                    StatRow(title: "Current Value", value: "\(store.state.count)")
                    StatRow(title: "Total Operations", value: "\(store.state.statistics.totalOperations)")
                    StatRow(
                        title: "Operations/min",
                        value: String(format: "%.1f", store.state.statistics.operationsPerMinute)
                    )
                }
                
                // Operations Section
                Section("Operations") {
                    StatRow(
                        title: "Increments",
                        value: "\(store.state.statistics.totalIncrements)",
                        icon: "plus.circle",
                        color: .green
                    )
                    StatRow(
                        title: "Decrements",
                        value: "\(store.state.statistics.totalDecrements)",
                        icon: "minus.circle",
                        color: .red
                    )
                    StatRow(
                        title: "Resets",
                        value: "\(store.state.statistics.totalResets)",
                        icon: "arrow.counterclockwise",
                        color: .orange
                    )
                }
                
                // Range Section
                Section("Range") {
                    StatRow(
                        title: "Highest Value",
                        value: "\(store.state.statistics.highestValue)",
                        icon: "arrow.up",
                        color: .blue
                    )
                    StatRow(
                        title: "Lowest Value",
                        value: "\(store.state.statistics.lowestValue)",
                        icon: "arrow.down",
                        color: .purple
                    )
                    StatRow(
                        title: "Average Value",
                        value: String(format: "%.2f", store.state.statistics.averageValue),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .teal
                    )
                }
                
                // Session Section
                Section("Session") {
                    StatRow(
                        title: "Session Duration",
                        value: formatDuration(store.state.statistics.sessionDuration)
                    )
                    StatRow(
                        title: "History Entries",
                        value: "\(store.state.history.count)"
                    )
                }
                
                // Chart Section
                Section("Distribution") {
                    OperationsChart(statistics: store.state.statistics)
                        .frame(height: 150)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset") {
                        store.send(.resetStatistics)
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(secs)s"
        } else if minutes > 0 {
            return "\(minutes)m \(secs)s"
        } else {
            return "\(secs)s"
        }
    }
}

/// Row displaying a single statistic
struct StatRow: View {
    let title: String
    let value: String
    var icon: String? = nil
    var color: Color = .primary
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
            }
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

/// Simple bar chart showing operation distribution
struct OperationsChart: View {
    let statistics: CounterStatistics
    
    private var total: Int {
        max(statistics.totalOperations, 1)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 24) {
            ChartBar(
                label: "Inc",
                value: statistics.totalIncrements,
                maxValue: total,
                color: .green
            )
            
            ChartBar(
                label: "Dec",
                value: statistics.totalDecrements,
                maxValue: total,
                color: .red
            )
            
            ChartBar(
                label: "Reset",
                value: statistics.totalResets,
                maxValue: total,
                color: .orange
            )
        }
        .padding()
    }
}

/// Single bar in the chart
struct ChartBar: View {
    let label: String
    let value: Int
    let maxValue: Int
    let color: Color
    
    private var height: CGFloat {
        guard maxValue > 0 else { return 20 }
        return CGFloat(value) / CGFloat(maxValue) * 100
    }
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.caption)
                .fontWeight(.semibold)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color.gradient)
                .frame(width: 40, height: max(height, 4))
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Multi-Counter View

/// View for managing multiple counters
public struct MultiCounterView: View {
    @ObservedObject private var store: Store<MultiCounterState, MultiCounterAction>
    @State private var newCounterName = ""
    
    public init(store: Store<MultiCounterState, MultiCounterAction>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack {
                // Summary
                if !store.state.counters.isEmpty {
                    summarySection
                }
                
                // Counter List
                if store.state.counters.isEmpty {
                    emptyState
                } else {
                    counterList
                }
            }
            .navigationTitle("Counters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.send(.setAddingCounter(true))
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                if !store.state.counters.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Menu {
                            Button("Reset All") {
                                store.send(.resetAllCounters)
                            }
                            Button("Increment All") {
                                store.send(.incrementAllCounters)
                            }
                            Button("Decrement All") {
                                store.send(.decrementAllCounters)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("New Counter", isPresented: .constant(store.state.isAddingCounter)) {
                TextField("Counter Name", text: $newCounterName)
                Button("Cancel") {
                    store.send(.setAddingCounter(false))
                    newCounterName = ""
                }
                Button("Add") {
                    store.send(.addCounter(name: newCounterName.isEmpty ? "Counter" : newCounterName))
                    newCounterName = ""
                }
            } message: {
                Text("Enter a name for the new counter")
            }
        }
    }
    
    private var summarySection: some View {
        HStack(spacing: 24) {
            VStack {
                Text("\(store.state.counters.count)")
                    .font(.title2.bold())
                Text("Counters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(store.state.totalCount)")
                    .font(.title2.bold())
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text(String(format: "%.1f", store.state.averageCount))
                    .font(.title2.bold())
                Text("Average")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "number.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Counters")
                .font(.title2.bold())
            
            Text("Tap + to add your first counter")
                .foregroundColor(.secondary)
            
            Button {
                store.send(.setAddingCounter(true))
            } label: {
                Label("Add Counter", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var counterList: some View {
        List {
            ForEach(store.state.sortedCounters, id: \.id) { item in
                CounterCardRow(
                    counter: item.state,
                    isSelected: item.id == store.state.selectedCounterId,
                    onIncrement: {
                        store.send(.counter(id: item.id, action: .increment))
                    },
                    onDecrement: {
                        store.send(.counter(id: item.id, action: .decrement))
                    },
                    onSelect: {
                        store.send(.selectCounter(item.id))
                    }
                )
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        store.send(.removeCounter(item.id))
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        store.send(.duplicateCounter(item.id))
                    } label: {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// Card-style row for a counter in the list
struct CounterCardRow: View {
    let counter: CounterState
    let isSelected: Bool
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(counter.colorTheme.color)
                .frame(width: 4)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(counter.name)
                        .font(.headline)
                    
                    if counter.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text("Step: \(counter.stepSize)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Count and controls
            HStack(spacing: 16) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(counter.canDecrement ? counter.colorTheme.color : .gray)
                }
                .buttonStyle(.plain)
                .disabled(!counter.canDecrement)
                
                Text(counter.formattedCount)
                    .font(.title2.bold())
                    .frame(minWidth: 50)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(counter.canIncrement ? counter.colorTheme.color : .gray)
                }
                .buttonStyle(.plain)
                .disabled(!counter.canIncrement)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .listRowBackground(isSelected ? counter.colorTheme.color.opacity(0.1) : Color.clear)
    }
}
