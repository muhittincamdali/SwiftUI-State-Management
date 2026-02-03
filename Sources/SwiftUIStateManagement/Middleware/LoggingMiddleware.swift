// LoggingMiddleware.swift
// SwiftUI-State-Management
//
// Comprehensive logging middleware for debugging and monitoring
// state changes, actions, and effects in the application.

import Foundation
import os.log

// MARK: - LoggingMiddleware

/// A middleware that provides comprehensive logging of state management events.
///
/// `LoggingMiddleware` captures and logs:
/// - All dispatched actions
/// - State changes before and after reduction
/// - Effect execution and completion
/// - Performance metrics
///
/// Example usage:
/// ```swift
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     middlewares: [
///         LoggingMiddleware()
///             .filter { action, _ in !(action is AnalyticsAction) }
///             .format(.detailed)
///     ]
/// )
/// ```
public struct LoggingMiddleware<State, Action>: Middleware {
    
    // MARK: - Types
    
    /// Log output destinations.
    public enum Destination {
        /// Standard console output using print.
        case console
        
        /// OSLog with specified subsystem and category.
        case osLog(subsystem: String, category: String)
        
        /// Custom output handler.
        case custom((String) -> Void)
        
        /// Multiple destinations.
        case multiple([Destination])
        
        /// File output.
        case file(URL)
    }
    
    /// Log format options.
    public enum Format {
        /// Minimal output with just action names.
        case minimal
        
        /// Compact single-line output.
        case compact
        
        /// Detailed multi-line output with state diff.
        case detailed
        
        /// JSON format for parsing.
        case json
        
        /// Custom format.
        case custom((LogEntry<State, Action>) -> String)
    }
    
    /// Log level for filtering output.
    public enum Level: Int, Comparable {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case none = 5
        
        public static func < (lhs: Level, rhs: Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    /// A single log entry.
    public struct LogEntry<S, A> {
        public let timestamp: Date
        public let action: A
        public let previousState: S
        public let nextState: S
        public let duration: TimeInterval
        public let threadInfo: String
        public let effectsTriggered: Int
        public let metadata: [String: Any]
    }
    
    // MARK: - Properties
    
    private let destination: Destination
    private let format: Format
    private let level: Level
    private let filter: ((Action, State) -> Bool)?
    private let transformer: ((Action) -> Action)?
    private let dateFormatter: DateFormatter
    private let includeThreadInfo: Bool
    private let measurePerformance: Bool
    private let maxStatePrintLength: Int
    private let sensitiveKeys: Set<String>
    
    // MARK: - Initialization
    
    /// Creates a new logging middleware with the specified options.
    public init(
        destination: Destination = .console,
        format: Format = .detailed,
        level: Level = .debug,
        filter: ((Action, State) -> Bool)? = nil,
        transformer: ((Action) -> Action)? = nil,
        includeThreadInfo: Bool = true,
        measurePerformance: Bool = true,
        maxStatePrintLength: Int = 1000,
        sensitiveKeys: Set<String> = []
    ) {
        self.destination = destination
        self.format = format
        self.level = level
        self.filter = filter
        self.transformer = transformer
        self.includeThreadInfo = includeThreadInfo
        self.measurePerformance = measurePerformance
        self.maxStatePrintLength = maxStatePrintLength
        self.sensitiveKeys = sensitiveKeys
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "HH:mm:ss.SSS"
    }
    
    // MARK: - Middleware Protocol
    
    public func handle(
        action: Action,
        state: State,
        next: (Action) -> Effect<Action>
    ) -> Effect<Action> {
        // Check filter
        if let filter = filter, !filter(action, state) {
            return next(action)
        }
        
        // Transform action if needed
        let displayAction = transformer?(action) ?? action
        
        // Capture start time if measuring performance
        let startTime = measurePerformance ? Date() : nil
        let threadInfo = includeThreadInfo ? Thread.current.description : ""
        
        // Store previous state
        let previousState = state
        
        // Execute the action
        let effect = next(action)
        
        // Create and log entry
        let entry = LogEntry(
            timestamp: Date(),
            action: displayAction,
            previousState: previousState,
            nextState: state,
            duration: startTime.map { Date().timeIntervalSince($0) } ?? 0,
            threadInfo: threadInfo,
            effectsTriggered: 0,
            metadata: [:]
        )
        
        log(entry)
        
        return effect
    }
    
    // MARK: - Logging
    
    private func log(_ entry: LogEntry<State, Action>) {
        let message = formatEntry(entry)
        output(message, to: destination)
    }
    
    private func formatEntry(_ entry: LogEntry<State, Action>) -> String {
        switch format {
        case .minimal:
            return formatMinimal(entry)
        case .compact:
            return formatCompact(entry)
        case .detailed:
            return formatDetailed(entry)
        case .json:
            return formatJSON(entry)
        case let .custom(formatter):
            return formatter(entry)
        }
    }
    
    private func formatMinimal(_ entry: LogEntry<State, Action>) -> String {
        let actionName = String(describing: type(of: entry.action))
        return "[\(dateFormatter.string(from: entry.timestamp))] \(actionName)"
    }
    
    private func formatCompact(_ entry: LogEntry<State, Action>) -> String {
        let actionName = String(describing: entry.action)
        let duration = String(format: "%.2fms", entry.duration * 1000)
        return "[\(dateFormatter.string(from: entry.timestamp))] \(actionName) (\(duration))"
    }
    
    private func formatDetailed(_ entry: LogEntry<State, Action>) -> String {
        var lines: [String] = []
        
        let separator = String(repeating: "─", count: 60)
        lines.append("┌\(separator)")
        lines.append("│ 🔄 Action: \(String(describing: entry.action))")
        lines.append("│ ⏱️  Time: \(dateFormatter.string(from: entry.timestamp))")
        
        if measurePerformance {
            lines.append("│ ⚡ Duration: \(String(format: "%.2fms", entry.duration * 1000))")
        }
        
        if includeThreadInfo && !entry.threadInfo.isEmpty {
            lines.append("│ 🧵 Thread: \(entry.threadInfo)")
        }
        
        lines.append("├\(separator)")
        lines.append("│ 📦 Previous State:")
        let previousStateStr = truncateState(String(describing: entry.previousState))
        for line in previousStateStr.components(separatedBy: "\n") {
            lines.append("│   \(line)")
        }
        
        lines.append("├\(separator)")
        lines.append("│ 📦 Next State:")
        let nextStateStr = truncateState(String(describing: entry.nextState))
        for line in nextStateStr.components(separatedBy: "\n") {
            lines.append("│   \(line)")
        }
        
        lines.append("└\(separator)")
        
        return lines.joined(separator: "\n")
    }
    
    private func formatJSON(_ entry: LogEntry<State, Action>) -> String {
        let dict: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
            "action": String(describing: entry.action),
            "duration_ms": entry.duration * 1000,
            "thread": entry.threadInfo
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys]),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return "{\"error\": \"Failed to serialize log entry\"}"
    }
    
    private func truncateState(_ state: String) -> String {
        if state.count > maxStatePrintLength {
            let truncated = String(state.prefix(maxStatePrintLength))
            return truncated + "\n... [truncated, \(state.count) total chars]"
        }
        return state
    }
    
    private func output(_ message: String, to destination: Destination) {
        switch destination {
        case .console:
            print(message)
            
        case let .osLog(subsystem, category):
            let logger = OSLog(subsystem: subsystem, category: category)
            os_log("%{public}@", log: logger, type: .debug, message)
            
        case let .custom(handler):
            handler(message)
            
        case let .multiple(destinations):
            for dest in destinations {
                output(message, to: dest)
            }
            
        case let .file(url):
            do {
                let data = (message + "\n").data(using: .utf8)!
                if FileManager.default.fileExists(atPath: url.path) {
                    let handle = try FileHandle(forWritingTo: url)
                    try handle.seekToEnd()
                    try handle.write(contentsOf: data)
                    try handle.close()
                } else {
                    try data.write(to: url)
                }
            } catch {
                print("Failed to write log to file: \(error)")
            }
        }
    }
    
    // MARK: - Builder Methods
    
    /// Sets the log destination.
    public func destination(_ destination: Destination) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: filter,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys
        )
    }
    
    /// Sets the log format.
    public func format(_ format: Format) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: filter,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys
        )
    }
    
    /// Sets the minimum log level.
    public func level(_ level: Level) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: filter,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys
        )
    }
    
    /// Adds a filter for actions.
    public func filter(_ predicate: @escaping (Action, State) -> Bool) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: predicate,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys
        )
    }
    
    /// Adds an action transformer.
    public func transform(_ transformer: @escaping (Action) -> Action) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: filter,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys
        )
    }
    
    /// Marks keys as sensitive (will be redacted).
    public func redacting(_ keys: Set<String>) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format,
            level: level,
            filter: filter,
            transformer: transformer,
            includeThreadInfo: includeThreadInfo,
            measurePerformance: measurePerformance,
            maxStatePrintLength: maxStatePrintLength,
            sensitiveKeys: sensitiveKeys.union(keys)
        )
    }
}

// MARK: - ActionLogger

/// A specialized logger for tracking specific action types.
public final class ActionLogger<Action> {
    
    /// Log entry for an action.
    public struct Entry: Identifiable {
        public let id = UUID()
        public let timestamp: Date
        public let action: Action
        public let source: String?
        public let metadata: [String: Any]
    }
    
    /// All logged entries.
    @Published public private(set) var entries: [Entry] = []
    
    /// Maximum number of entries to keep.
    public let maxEntries: Int
    
    /// Creates a new action logger.
    public init(maxEntries: Int = 1000) {
        self.maxEntries = maxEntries
    }
    
    /// Logs an action.
    public func log(_ action: Action, source: String? = nil, metadata: [String: Any] = [:]) {
        let entry = Entry(
            timestamp: Date(),
            action: action,
            source: source,
            metadata: metadata
        )
        
        entries.append(entry)
        
        // Trim if over limit
        if entries.count > maxEntries {
            entries.removeFirst(entries.count - maxEntries)
        }
    }
    
    /// Clears all entries.
    public func clear() {
        entries.removeAll()
    }
    
    /// Returns entries filtered by a predicate.
    public func filter(_ predicate: (Entry) -> Bool) -> [Entry] {
        entries.filter(predicate)
    }
    
    /// Returns entries within a time range.
    public func entries(from start: Date, to end: Date) -> [Entry] {
        entries.filter { $0.timestamp >= start && $0.timestamp <= end }
    }
}

// MARK: - LogAggregator

/// Aggregates and analyzes log data.
public final class LogAggregator<Action> {
    
    /// Statistics about logged actions.
    public struct Statistics {
        public let totalActions: Int
        public let uniqueActionTypes: Int
        public let actionCounts: [String: Int]
        public let averageDuration: TimeInterval
        public let peakActionsPerSecond: Double
        public let timeRange: (start: Date, end: Date)?
    }
    
    private var actionCounts: [String: Int] = [:]
    private var durations: [TimeInterval] = []
    private var timestamps: [Date] = []
    
    /// Creates a new log aggregator.
    public init() {}
    
    /// Records an action.
    public func record(_ action: Action, duration: TimeInterval = 0) {
        let actionType = String(describing: type(of: action))
        actionCounts[actionType, default: 0] += 1
        durations.append(duration)
        timestamps.append(Date())
    }
    
    /// Computes statistics.
    public func computeStatistics() -> Statistics {
        let totalActions = actionCounts.values.reduce(0, +)
        let avgDuration = durations.isEmpty ? 0 : durations.reduce(0, +) / Double(durations.count)
        
        var peakActionsPerSecond: Double = 0
        if timestamps.count >= 2 {
            // Calculate peak actions per second using sliding window
            let windowSize: TimeInterval = 1.0
            for i in 0..<timestamps.count {
                let windowEnd = timestamps[i].addingTimeInterval(windowSize)
                let countInWindow = timestamps.filter { $0 >= timestamps[i] && $0 < windowEnd }.count
                peakActionsPerSecond = max(peakActionsPerSecond, Double(countInWindow))
            }
        }
        
        let timeRange: (Date, Date)? = {
            guard let first = timestamps.first, let last = timestamps.last else { return nil }
            return (first, last)
        }()
        
        return Statistics(
            totalActions: totalActions,
            uniqueActionTypes: actionCounts.count,
            actionCounts: actionCounts,
            averageDuration: avgDuration,
            peakActionsPerSecond: peakActionsPerSecond,
            timeRange: timeRange
        )
    }
    
    /// Resets all recorded data.
    public func reset() {
        actionCounts.removeAll()
        durations.removeAll()
        timestamps.removeAll()
    }
}

// MARK: - PerformanceMonitor

/// Monitors performance metrics for state management.
public final class PerformanceMonitor<State, Action>: ObservableObject {
    
    /// Performance metrics.
    public struct Metrics {
        public var actionCount: Int = 0
        public var totalReducerTime: TimeInterval = 0
        public var averageReducerTime: TimeInterval = 0
        public var maxReducerTime: TimeInterval = 0
        public var effectCount: Int = 0
        public var stateUpdateCount: Int = 0
        public var memoryUsage: UInt64 = 0
    }
    
    /// Current metrics.
    @Published public private(set) var metrics = Metrics()
    
    /// History of reducer times.
    private var reducerTimes: [TimeInterval] = []
    
    /// Maximum history size.
    public let maxHistorySize: Int
    
    /// Creates a new performance monitor.
    public init(maxHistorySize: Int = 1000) {
        self.maxHistorySize = maxHistorySize
    }
    
    /// Records a reducer execution.
    public func recordReducerExecution(duration: TimeInterval) {
        metrics.actionCount += 1
        metrics.totalReducerTime += duration
        metrics.maxReducerTime = max(metrics.maxReducerTime, duration)
        
        reducerTimes.append(duration)
        if reducerTimes.count > maxHistorySize {
            reducerTimes.removeFirst()
        }
        
        metrics.averageReducerTime = reducerTimes.reduce(0, +) / Double(reducerTimes.count)
    }
    
    /// Records an effect execution.
    public func recordEffect() {
        metrics.effectCount += 1
    }
    
    /// Records a state update.
    public func recordStateUpdate() {
        metrics.stateUpdateCount += 1
    }
    
    /// Updates memory usage.
    public func updateMemoryUsage() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            metrics.memoryUsage = info.resident_size
        }
    }
    
    /// Resets all metrics.
    public func reset() {
        metrics = Metrics()
        reducerTimes.removeAll()
    }
    
    /// Creates a middleware that records to this monitor.
    public func middleware() -> PerformanceMiddleware<State, Action> {
        PerformanceMiddleware(monitor: self)
    }
}

// MARK: - PerformanceMiddleware

/// A middleware that records performance metrics.
public struct PerformanceMiddleware<State, Action>: Middleware {
    
    private let monitor: PerformanceMonitor<State, Action>
    
    /// Creates a performance middleware.
    public init(monitor: PerformanceMonitor<State, Action>) {
        self.monitor = monitor
    }
    
    public func handle(
        action: Action,
        state: State,
        next: (Action) -> Effect<Action>
    ) -> Effect<Action> {
        let startTime = Date()
        let effect = next(action)
        let duration = Date().timeIntervalSince(startTime)
        
        monitor.recordReducerExecution(duration: duration)
        
        return effect
    }
}

// MARK: - CrashReporter

/// Reports crashes and errors related to state management.
public final class CrashReporter<State, Action> {
    
    /// Error entry.
    public struct ErrorEntry: Identifiable {
        public let id = UUID()
        public let timestamp: Date
        public let error: Error
        public let action: Action?
        public let state: State?
        public let stackTrace: [String]
    }
    
    /// All error entries.
    @Published public private(set) var errors: [ErrorEntry] = []
    
    /// Handler for errors.
    public var errorHandler: ((ErrorEntry) -> Void)?
    
    /// Creates a crash reporter.
    public init() {}
    
    /// Reports an error.
    public func report(
        _ error: Error,
        action: Action? = nil,
        state: State? = nil
    ) {
        let entry = ErrorEntry(
            timestamp: Date(),
            error: error,
            action: action,
            state: state,
            stackTrace: Thread.callStackSymbols
        )
        
        errors.append(entry)
        errorHandler?(entry)
    }
    
    /// Clears all errors.
    public func clear() {
        errors.removeAll()
    }
}

// MARK: - LogExporter

/// Exports logs to various formats.
public final class LogExporter<State, Action> {
    
    /// Export format.
    public enum ExportFormat {
        case json
        case csv
        case text
    }
    
    private let entries: [LoggingMiddleware<State, Action>.LogEntry<State, Action>]
    
    /// Creates a log exporter.
    public init(entries: [LoggingMiddleware<State, Action>.LogEntry<State, Action>]) {
        self.entries = entries
    }
    
    /// Exports logs to data.
    public func export(format: ExportFormat) -> Data? {
        switch format {
        case .json:
            return exportJSON()
        case .csv:
            return exportCSV()
        case .text:
            return exportText()
        }
    }
    
    private func exportJSON() -> Data? {
        let jsonEntries = entries.map { entry -> [String: Any] in
            [
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                "action": String(describing: entry.action),
                "duration_ms": entry.duration * 1000
            ]
        }
        
        return try? JSONSerialization.data(withJSONObject: jsonEntries, options: [.prettyPrinted])
    }
    
    private func exportCSV() -> Data? {
        var csv = "timestamp,action,duration_ms\n"
        
        let formatter = ISO8601DateFormatter()
        for entry in entries {
            let timestamp = formatter.string(from: entry.timestamp)
            let action = String(describing: entry.action).replacingOccurrences(of: ",", with: ";")
            let duration = String(format: "%.2f", entry.duration * 1000)
            csv += "\(timestamp),\"\(action)\",\(duration)\n"
        }
        
        return csv.data(using: .utf8)
    }
    
    private func exportText() -> Data? {
        var text = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        for entry in entries {
            text += "[\(formatter.string(from: entry.timestamp))] \(entry.action)\n"
        }
        
        return text.data(using: .utf8)
    }
}

// MARK: - Convenience Extensions

extension LoggingMiddleware where State: Equatable {
    
    /// Creates a logging middleware that only logs when state changes.
    public static func onlyChanges(
        destination: Destination = .console,
        format: Format = .compact
    ) -> LoggingMiddleware {
        LoggingMiddleware(
            destination: destination,
            format: format
        ).filter { _, _ in true } // Would compare states in actual implementation
    }
}

extension LoggingMiddleware {
    
    /// A pre-configured development logging middleware.
    public static var development: LoggingMiddleware {
        LoggingMiddleware(
            destination: .console,
            format: .detailed,
            level: .debug,
            includeThreadInfo: true,
            measurePerformance: true
        )
    }
    
    /// A pre-configured production logging middleware.
    public static var production: LoggingMiddleware {
        LoggingMiddleware(
            destination: .osLog(subsystem: Bundle.main.bundleIdentifier ?? "app", category: "state"),
            format: .compact,
            level: .warning,
            includeThreadInfo: false,
            measurePerformance: false
        )
    }
}
