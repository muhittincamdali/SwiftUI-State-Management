// ActionLogger.swift
// SwiftUI-State-Management
//
// Advanced action logging and analysis for debugging.
// Provides detailed insights into action flow and patterns.

import Foundation
import Combine
import SwiftUI

// MARK: - ActionLogger

/// A comprehensive action logging system for debugging and analysis.
///
/// `ActionLogger` provides:
/// - Detailed action logging with metadata
/// - Action flow visualization
/// - Pattern detection and analysis
/// - Performance tracking per action type
/// - Export capabilities for analysis
///
/// Example usage:
/// ```swift
/// let logger = ActionLogger<AppAction>()
/// logger.log(.userTapped, source: "HomeView")
///
/// // Analyze action patterns
/// let stats = logger.analyzePatterns()
/// ```
public final class ActionLogger<Action>: ObservableObject {
    
    // MARK: - Types
    
    /// A logged action entry.
    public struct LogEntry: Identifiable {
        public let id: UUID
        public let timestamp: Date
        public let action: Action
        public let actionType: String
        public let source: String?
        public let file: String?
        public let line: Int?
        public let function: String?
        public let metadata: [String: Any]
        public let stackTrace: [String]?
        public let duration: TimeInterval?
        public let effectsTriggered: [String]
        
        public init(
            timestamp: Date = Date(),
            action: Action,
            source: String? = nil,
            file: String? = nil,
            line: Int? = nil,
            function: String? = nil,
            metadata: [String: Any] = [:],
            stackTrace: [String]? = nil,
            duration: TimeInterval? = nil,
            effectsTriggered: [String] = []
        ) {
            self.id = UUID()
            self.timestamp = timestamp
            self.action = action
            self.actionType = String(describing: type(of: action))
            self.source = source
            self.file = file
            self.line = line
            self.function = function
            self.metadata = metadata
            self.stackTrace = stackTrace
            self.duration = duration
            self.effectsTriggered = effectsTriggered
        }
    }
    
    /// Filter options for log entries.
    public struct Filter {
        public var actionTypes: Set<String>?
        public var sources: Set<String>?
        public var startDate: Date?
        public var endDate: Date?
        public var minDuration: TimeInterval?
        public var maxDuration: TimeInterval?
        public var searchText: String?
        
        public init(
            actionTypes: Set<String>? = nil,
            sources: Set<String>? = nil,
            startDate: Date? = nil,
            endDate: Date? = nil,
            minDuration: TimeInterval? = nil,
            maxDuration: TimeInterval? = nil,
            searchText: String? = nil
        ) {
            self.actionTypes = actionTypes
            self.sources = sources
            self.startDate = startDate
            self.endDate = endDate
            self.minDuration = minDuration
            self.maxDuration = maxDuration
            self.searchText = searchText
        }
        
        public static let none = Filter()
    }
    
    /// Statistics about logged actions.
    public struct Statistics {
        public var totalActions: Int
        public var uniqueActionTypes: Int
        public var actionTypeCounts: [String: Int]
        public var averageDuration: TimeInterval?
        public var maxDuration: TimeInterval?
        public var minDuration: TimeInterval?
        public var actionsPerSecond: Double
        public var effectTriggerRate: Double
        public var topSources: [(String, Int)]
        public var timeRange: (start: Date, end: Date)?
    }
    
    /// Action pattern detection result.
    public struct Pattern: Identifiable {
        public let id = UUID()
        public let name: String
        public let description: String
        public let actions: [String]
        public let occurrences: Int
        public let averageInterval: TimeInterval
    }
    
    // MARK: - Properties
    
    /// All logged entries.
    @Published public private(set) var entries: [LogEntry] = []
    
    /// Maximum number of entries to keep.
    public let maxEntries: Int
    
    /// Whether logging is enabled.
    @Published public var isEnabled: Bool = true
    
    /// Whether to capture stack traces.
    public var captureStackTraces: Bool = false
    
    /// Current filter.
    @Published public var filter: Filter = .none
    
    /// Filtered entries based on current filter.
    public var filteredEntries: [LogEntry] {
        applyFilter(filter, to: entries)
    }
    
    /// Unique action types in the log.
    public var actionTypes: Set<String> {
        Set(entries.map { $0.actionType })
    }
    
    /// Unique sources in the log.
    public var sources: Set<String> {
        Set(entries.compactMap { $0.source })
    }
    
    private var observers: [UUID: (LogEntry) -> Void] = [:]
    private let queue = DispatchQueue(label: "com.statemanagement.actionlogger")
    
    // MARK: - Initialization
    
    /// Creates a new action logger.
    public init(maxEntries: Int = 5000) {
        self.maxEntries = maxEntries
    }
    
    // MARK: - Logging
    
    /// Logs an action with optional metadata.
    public func log(
        _ action: Action,
        source: String? = nil,
        file: String = #file,
        line: Int = #line,
        function: String = #function,
        metadata: [String: Any] = [:],
        duration: TimeInterval? = nil,
        effectsTriggered: [String] = []
    ) {
        guard isEnabled else { return }
        
        let entry = LogEntry(
            timestamp: Date(),
            action: action,
            source: source,
            file: file,
            line: line,
            function: function,
            metadata: metadata,
            stackTrace: captureStackTraces ? Thread.callStackSymbols : nil,
            duration: duration,
            effectsTriggered: effectsTriggered
        )
        
        queue.sync {
            entries.append(entry)
            
            // Trim if over limit
            if entries.count > maxEntries {
                entries.removeFirst(entries.count - maxEntries)
            }
        }
        
        // Notify observers
        for (_, observer) in observers {
            observer(entry)
        }
    }
    
    /// Logs an action with a duration measurement.
    public func logWithTiming(
        _ action: Action,
        source: String? = nil,
        metadata: [String: Any] = [:],
        block: () -> Void
    ) {
        let startTime = Date()
        block()
        let duration = Date().timeIntervalSince(startTime)
        
        log(action, source: source, metadata: metadata, duration: duration)
    }
    
    // MARK: - Filtering
    
    private func applyFilter(_ filter: Filter, to entries: [LogEntry]) -> [LogEntry] {
        var result = entries
        
        if let actionTypes = filter.actionTypes, !actionTypes.isEmpty {
            result = result.filter { actionTypes.contains($0.actionType) }
        }
        
        if let sources = filter.sources, !sources.isEmpty {
            result = result.filter { entry in
                guard let source = entry.source else { return false }
                return sources.contains(source)
            }
        }
        
        if let startDate = filter.startDate {
            result = result.filter { $0.timestamp >= startDate }
        }
        
        if let endDate = filter.endDate {
            result = result.filter { $0.timestamp <= endDate }
        }
        
        if let minDuration = filter.minDuration {
            result = result.filter { ($0.duration ?? 0) >= minDuration }
        }
        
        if let maxDuration = filter.maxDuration {
            result = result.filter { ($0.duration ?? 0) <= maxDuration }
        }
        
        if let searchText = filter.searchText, !searchText.isEmpty {
            let lowercased = searchText.lowercased()
            result = result.filter { entry in
                entry.actionType.lowercased().contains(lowercased) ||
                (entry.source?.lowercased().contains(lowercased) ?? false) ||
                String(describing: entry.action).lowercased().contains(lowercased)
            }
        }
        
        return result
    }
    
    // MARK: - Analysis
    
    /// Computes statistics for all logged actions.
    public func computeStatistics() -> Statistics {
        let actionTypeCounts = Dictionary(grouping: entries, by: { $0.actionType })
            .mapValues { $0.count }
        
        let durations = entries.compactMap { $0.duration }
        let avgDuration = durations.isEmpty ? nil : durations.reduce(0, +) / Double(durations.count)
        
        let sourceCounts = Dictionary(grouping: entries.compactMap { $0.source }, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
            .prefix(10)
        
        let timeRange: (Date, Date)? = {
            guard let first = entries.first?.timestamp,
                  let last = entries.last?.timestamp else { return nil }
            return (first, last)
        }()
        
        let totalDuration = timeRange.map { $0.1.timeIntervalSince($0.0) } ?? 0
        let actionsPerSecond = totalDuration > 0 ? Double(entries.count) / totalDuration : 0
        
        let effectCount = entries.reduce(0) { $0 + $1.effectsTriggered.count }
        let effectRate = entries.isEmpty ? 0 : Double(effectCount) / Double(entries.count)
        
        return Statistics(
            totalActions: entries.count,
            uniqueActionTypes: actionTypeCounts.count,
            actionTypeCounts: actionTypeCounts,
            averageDuration: avgDuration,
            maxDuration: durations.max(),
            minDuration: durations.min(),
            actionsPerSecond: actionsPerSecond,
            effectTriggerRate: effectRate,
            topSources: Array(sourceCounts),
            timeRange: timeRange
        )
    }
    
    /// Detects patterns in action sequences.
    public func detectPatterns(minOccurrences: Int = 3) -> [Pattern] {
        var patterns: [Pattern] = []
        let actionTypes = entries.map { $0.actionType }
        
        // Look for repeated sequences of 2-5 actions
        for sequenceLength in 2...5 {
            var sequenceCounts: [String: (count: Int, intervals: [TimeInterval])] = [:]
            
            for i in 0..<(actionTypes.count - sequenceLength + 1) {
                let sequence = Array(actionTypes[i..<(i + sequenceLength)])
                let key = sequence.joined(separator: " → ")
                
                var existing = sequenceCounts[key] ?? (count: 0, intervals: [])
                existing.count += 1
                
                // Calculate interval if we have timestamps
                if i + sequenceLength < entries.count {
                    let interval = entries[i + sequenceLength].timestamp.timeIntervalSince(entries[i].timestamp)
                    existing.intervals.append(interval)
                }
                
                sequenceCounts[key] = existing
            }
            
            for (sequence, data) in sequenceCounts where data.count >= minOccurrences {
                let avgInterval = data.intervals.isEmpty ? 0 : data.intervals.reduce(0, +) / Double(data.intervals.count)
                
                patterns.append(Pattern(
                    name: "Sequence Pattern",
                    description: "Detected \(data.count) occurrences of this action sequence",
                    actions: sequence.components(separatedBy: " → "),
                    occurrences: data.count,
                    averageInterval: avgInterval
                ))
            }
        }
        
        // Sort by occurrences
        return patterns.sorted { $0.occurrences > $1.occurrences }
    }
    
    /// Finds rapid action sequences (potential spam or issues).
    public func findRapidSequences(threshold: TimeInterval = 0.1) -> [(LogEntry, LogEntry)] {
        var rapidPairs: [(LogEntry, LogEntry)] = []
        
        for i in 1..<entries.count {
            let interval = entries[i].timestamp.timeIntervalSince(entries[i - 1].timestamp)
            if interval < threshold {
                rapidPairs.append((entries[i - 1], entries[i]))
            }
        }
        
        return rapidPairs
    }
    
    /// Finds slow actions.
    public func findSlowActions(threshold: TimeInterval = 0.5) -> [LogEntry] {
        entries.filter { ($0.duration ?? 0) > threshold }
    }
    
    // MARK: - Observation
    
    /// Adds an observer for new log entries.
    @discardableResult
    public func addObserver(_ handler: @escaping (LogEntry) -> Void) -> UUID {
        let id = UUID()
        observers[id] = handler
        return id
    }
    
    /// Removes an observer.
    public func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }
    
    // MARK: - Management
    
    /// Clears all logged entries.
    public func clear() {
        queue.sync {
            entries.removeAll()
        }
    }
    
    /// Clears entries older than the specified date.
    public func clearOlderThan(_ date: Date) {
        queue.sync {
            entries.removeAll { $0.timestamp < date }
        }
    }
    
    // MARK: - Export
    
    /// Exports log entries to JSON.
    public func exportJSON() -> Data? {
        struct ExportEntry: Encodable {
            let timestamp: Date
            let actionType: String
            let action: String
            let source: String?
            let duration: TimeInterval?
            let effectsTriggered: [String]
        }
        
        let exportable = entries.map { entry in
            ExportEntry(
                timestamp: entry.timestamp,
                actionType: entry.actionType,
                action: String(describing: entry.action),
                source: entry.source,
                duration: entry.duration,
                effectsTriggered: entry.effectsTriggered
            )
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return try? encoder.encode(exportable)
    }
    
    /// Exports log entries to CSV.
    public func exportCSV() -> String {
        var csv = "timestamp,action_type,source,duration_ms,effects_count\n"
        
        let formatter = ISO8601DateFormatter()
        
        for entry in entries {
            let timestamp = formatter.string(from: entry.timestamp)
            let actionType = entry.actionType.replacingOccurrences(of: ",", with: ";")
            let source = entry.source?.replacingOccurrences(of: ",", with: ";") ?? ""
            let duration = entry.duration.map { String(format: "%.2f", $0 * 1000) } ?? ""
            let effectsCount = String(entry.effectsTriggered.count)
            
            csv += "\(timestamp),\(actionType),\(source),\(duration),\(effectsCount)\n"
        }
        
        return csv
    }
    
    /// Creates a middleware for automatic logging.
    public func middleware<State>() -> ActionLoggerMiddleware<State, Action> {
        ActionLoggerMiddleware(logger: self)
    }
}

// MARK: - ActionLoggerMiddleware

/// Middleware that automatically logs all actions.
public struct ActionLoggerMiddleware<State, Action>: Middleware {
    
    private let logger: ActionLogger<Action>
    
    public init(logger: ActionLogger<Action>) {
        self.logger = logger
    }
    
    public func handle(
        action: Action,
        state: State,
        next: (Action) -> Effect<Action>
    ) -> Effect<Action> {
        let startTime = Date()
        let effect = next(action)
        let duration = Date().timeIntervalSince(startTime)
        
        logger.log(action, source: "Middleware", duration: duration)
        
        return effect
    }
}

// MARK: - ActionLogView

/// SwiftUI view for browsing action logs.
public struct ActionLogView<Action>: View {
    
    @ObservedObject var logger: ActionLogger<Action>
    @State private var searchText = ""
    @State private var selectedEntry: ActionLogger<Action>.LogEntry?
    @State private var showingStatistics = false
    
    public init(logger: ActionLogger<Action>) {
        self.logger = logger
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Entries list
                entriesList
            }
            .navigationTitle("Action Log")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingStatistics = true }) {
                            Label("Statistics", systemImage: "chart.bar")
                        }
                        
                        Button(action: { logger.clear() }) {
                            Label("Clear All", systemImage: "trash")
                        }
                        
                        Toggle("Logging Enabled", isOn: $logger.isEnabled)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView(statistics: logger.computeStatistics())
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search actions...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var entriesList: some View {
        List {
            ForEach(filteredEntries) { entry in
                EntryRow(entry: entry)
                    .onTapGesture {
                        selectedEntry = entry
                    }
            }
        }
        .listStyle(.plain)
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry)
        }
    }
    
    private var filteredEntries: [ActionLogger<Action>.LogEntry] {
        if searchText.isEmpty {
            return logger.entries.reversed()
        } else {
            return logger.entries.filter { entry in
                entry.actionType.localizedCaseInsensitiveContains(searchText) ||
                (entry.source?.localizedCaseInsensitiveContains(searchText) ?? false)
            }.reversed()
        }
    }
    
    // MARK: - Entry Row
    
    struct EntryRow: View {
        let entry: ActionLogger<Action>.LogEntry
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.actionType)
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8) {
                        if let source = entry.source {
                            Text(source)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(entry.timestamp, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let duration = entry.duration {
                    Text(String(format: "%.1fms", duration * 1000))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(durationColor(duration).opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
        }
        
        private func durationColor(_ duration: TimeInterval) -> Color {
            if duration < 0.01 { return .green }
            if duration < 0.1 { return .yellow }
            return .red
        }
    }
    
    // MARK: - Entry Detail View
    
    struct EntryDetailView: View {
        let entry: ActionLogger<Action>.LogEntry
        
        var body: some View {
            NavigationView {
                List {
                    Section("Action") {
                        LabeledContent("Type", value: entry.actionType)
                        LabeledContent("Value", value: String(describing: entry.action))
                    }
                    
                    Section("Timing") {
                        LabeledContent("Timestamp", value: entry.timestamp.formatted())
                        if let duration = entry.duration {
                            LabeledContent("Duration", value: String(format: "%.2fms", duration * 1000))
                        }
                    }
                    
                    if let source = entry.source {
                        Section("Source") {
                            LabeledContent("Source", value: source)
                            if let file = entry.file {
                                LabeledContent("File", value: URL(fileURLWithPath: file).lastPathComponent)
                            }
                            if let line = entry.line {
                                LabeledContent("Line", value: String(line))
                            }
                            if let function = entry.function {
                                LabeledContent("Function", value: function)
                            }
                        }
                    }
                    
                    if !entry.effectsTriggered.isEmpty {
                        Section("Effects") {
                            ForEach(entry.effectsTriggered, id: \.self) { effect in
                                Text(effect)
                            }
                        }
                    }
                    
                    if let stackTrace = entry.stackTrace, !stackTrace.isEmpty {
                        Section("Stack Trace") {
                            ForEach(stackTrace.prefix(20), id: \.self) { frame in
                                Text(frame)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                    }
                }
                .navigationTitle("Action Details")
            }
        }
    }
    
    // MARK: - Statistics View
    
    struct StatisticsView: View {
        let statistics: ActionLogger<Action>.Statistics
        
        var body: some View {
            NavigationView {
                List {
                    Section("Overview") {
                        LabeledContent("Total Actions", value: "\(statistics.totalActions)")
                        LabeledContent("Unique Types", value: "\(statistics.uniqueActionTypes)")
                        if let avg = statistics.averageDuration {
                            LabeledContent("Avg Duration", value: String(format: "%.2fms", avg * 1000))
                        }
                        LabeledContent("Actions/sec", value: String(format: "%.1f", statistics.actionsPerSecond))
                    }
                    
                    Section("Action Types") {
                        ForEach(statistics.actionTypeCounts.sorted { $0.value > $1.value }, id: \.key) { type, count in
                            HStack {
                                Text(type)
                                    .font(.system(.body, design: .monospaced))
                                Spacer()
                                Text("\(count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if !statistics.topSources.isEmpty {
                        Section("Top Sources") {
                            ForEach(statistics.topSources, id: \.0) { source, count in
                                HStack {
                                    Text(source)
                                    Spacer()
                                    Text("\(count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Statistics")
            }
        }
    }
}

// MARK: - ActionFlow

/// Visualizes action flow over time.
public struct ActionFlow<Action>: View {
    
    @ObservedObject var logger: ActionLogger<Action>
    let windowSize: Int
    
    public init(logger: ActionLogger<Action>, windowSize: Int = 20) {
        self.logger = logger
        self.windowSize = windowSize
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(recentEntries) { entry in
                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForAction(entry.actionType))
                        .frame(width: 8, height: 8)
                    
                    Text(entry.actionType)
                        .font(.system(.caption2, design: .monospaced))
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var recentEntries: [ActionLogger<Action>.LogEntry] {
        Array(logger.entries.suffix(windowSize).reversed())
    }
    
    private func colorForAction(_ type: String) -> Color {
        // Hash the type to get a consistent color
        let hash = type.hashValue
        let hue = Double(abs(hash) % 360) / 360.0
        return Color(hue: hue, saturation: 0.7, brightness: 0.8)
    }
}
