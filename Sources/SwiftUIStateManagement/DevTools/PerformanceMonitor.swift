import Foundation
import os.log

// MARK: - Performance Metrics

/// Comprehensive performance metrics for store operations.
public struct PerformanceMetrics: Sendable {
    
    /// Metrics for a single action dispatch.
    public struct ActionMetric: Identifiable, Sendable {
        public let id = UUID()
        public let actionName: String
        public let timestamp: Date
        public let reducerDuration: TimeInterval
        public let effectDuration: TimeInterval?
        public let middlewareDuration: TimeInterval
        public let totalDuration: TimeInterval
        public let memoryDelta: Int64?
        
        public var isSlowReducer: Bool {
            reducerDuration > 0.016 // 16ms = 60fps threshold
        }
        
        public var isSlowEffect: Bool {
            guard let effectDuration = effectDuration else { return false }
            return effectDuration > 1.0 // 1 second threshold
        }
    }
    
    /// Aggregate statistics.
    public struct Statistics: Sendable {
        public let totalActions: Int
        public let averageReducerTime: TimeInterval
        public let maxReducerTime: TimeInterval
        public let minReducerTime: TimeInterval
        public let averageEffectTime: TimeInterval
        public let slowActionCount: Int
        public let actionsPerSecond: Double
        public let measurementWindow: TimeInterval
        
        public init(from metrics: [ActionMetric], window: TimeInterval) {
            self.totalActions = metrics.count
            self.measurementWindow = window
            
            let reducerTimes = metrics.map(\.reducerDuration)
            self.averageReducerTime = reducerTimes.isEmpty ? 0 : reducerTimes.reduce(0, +) / Double(reducerTimes.count)
            self.maxReducerTime = reducerTimes.max() ?? 0
            self.minReducerTime = reducerTimes.min() ?? 0
            
            let effectTimes = metrics.compactMap(\.effectDuration)
            self.averageEffectTime = effectTimes.isEmpty ? 0 : effectTimes.reduce(0, +) / Double(effectTimes.count)
            
            self.slowActionCount = metrics.filter(\.isSlowReducer).count
            self.actionsPerSecond = window > 0 ? Double(metrics.count) / window : 0
        }
    }
    
    /// All recorded action metrics.
    public private(set) var actions: [ActionMetric] = []
    
    /// When monitoring started.
    public let startTime: Date
    
    /// Maximum number of metrics to retain.
    public let maxMetrics: Int
    
    public init(maxMetrics: Int = 1000) {
        self.startTime = Date()
        self.maxMetrics = maxMetrics
    }
    
    /// Computes aggregate statistics.
    public var statistics: Statistics {
        Statistics(
            from: actions,
            window: Date().timeIntervalSince(startTime)
        )
    }
    
    /// Adds a new action metric.
    public mutating func record(_ metric: ActionMetric) {
        actions.append(metric)
        
        // Trim old metrics
        if actions.count > maxMetrics {
            actions.removeFirst(actions.count - maxMetrics)
        }
    }
    
    /// Clears all recorded metrics.
    public mutating func reset() {
        actions.removeAll()
    }
    
    /// Returns metrics for the last N seconds.
    public func recentMetrics(seconds: TimeInterval) -> [ActionMetric] {
        let cutoff = Date().addingTimeInterval(-seconds)
        return actions.filter { $0.timestamp > cutoff }
    }
    
    /// Returns slow actions (reducer > 16ms).
    public var slowActions: [ActionMetric] {
        actions.filter(\.isSlowReducer)
    }
}

// MARK: - Performance Monitor

/// Real-time performance monitoring for store operations.
/// Tracks reducer execution time, effect duration, and memory usage.
@MainActor
public final class PerformanceMonitor<State, Action>: ObservableObject {
    
    // MARK: - Configuration
    
    /// Configuration for performance monitoring.
    public struct Configuration {
        /// Whether to log warnings for slow reducers.
        public var logSlowReducers: Bool = true
        
        /// Threshold for slow reducer warning (in seconds).
        public var slowReducerThreshold: TimeInterval = 0.016
        
        /// Whether to track memory usage.
        public var trackMemory: Bool = true
        
        /// Maximum metrics to retain.
        public var maxMetrics: Int = 1000
        
        /// Whether to automatically clean up old metrics.
        public var autoCleanup: Bool = true
        
        /// Interval for automatic cleanup (in seconds).
        public var cleanupInterval: TimeInterval = 300 // 5 minutes
        
        public static let `default` = Configuration()
        
        public static let production = Configuration(
            logSlowReducers: false,
            trackMemory: false,
            maxMetrics: 100,
            autoCleanup: true
        )
    }
    
    // MARK: - Published Properties
    
    /// Current performance metrics.
    @Published public private(set) var metrics: PerformanceMetrics
    
    /// Whether monitoring is active.
    @Published public private(set) var isMonitoring: Bool = false
    
    /// Most recent action metric.
    @Published public private(set) var lastMetric: PerformanceMetrics.ActionMetric?
    
    /// Current actions per second.
    @Published public private(set) var currentThroughput: Double = 0
    
    // MARK: - Private Properties
    
    private let configuration: Configuration
    private let logger = Logger(subsystem: "SwiftUIStateManagement", category: "Performance")
    private var cleanupTask: Task<Void, Never>?
    private var throughputTask: Task<Void, Never>?
    
    // Timing state
    private var currentActionStart: Date?
    private var currentReducerStart: Date?
    private var currentReducerEnd: Date?
    private var currentMiddlewareDuration: TimeInterval = 0
    private var currentActionName: String = ""
    private var baselineMemory: Int64 = 0
    
    // MARK: - Initialization
    
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
        self.metrics = PerformanceMetrics(maxMetrics: configuration.maxMetrics)
    }
    
    deinit {
        cleanupTask?.cancel()
        throughputTask?.cancel()
    }
    
    // MARK: - Lifecycle
    
    /// Starts performance monitoring.
    public func start() {
        guard !isMonitoring else { return }
        isMonitoring = true
        
        if configuration.autoCleanup {
            startCleanupTask()
        }
        
        startThroughputTask()
        
        logger.info("Performance monitoring started")
    }
    
    /// Stops performance monitoring.
    public func stop() {
        isMonitoring = false
        cleanupTask?.cancel()
        cleanupTask = nil
        throughputTask?.cancel()
        throughputTask = nil
        
        logger.info("Performance monitoring stopped")
    }
    
    /// Resets all metrics.
    public func reset() {
        metrics.reset()
        lastMetric = nil
        currentThroughput = 0
        
        logger.info("Performance metrics reset")
    }
    
    // MARK: - Event Handlers
    
    /// Called when an action dispatch begins.
    public func willDispatch(_ action: Action) {
        guard isMonitoring else { return }
        
        currentActionStart = Date()
        currentActionName = String(describing: type(of: action))
        currentMiddlewareDuration = 0
        
        if configuration.trackMemory {
            baselineMemory = currentMemoryUsage()
        }
    }
    
    /// Called when middleware processing begins.
    public func willProcessMiddleware(_ middlewareName: String) {
        // Track middleware start for detailed breakdown
    }
    
    /// Called when middleware processing ends.
    public func didProcessMiddleware(_ middlewareName: String, duration: TimeInterval) {
        currentMiddlewareDuration += duration
    }
    
    /// Called when the reducer begins processing.
    public func willReduce(_ action: Action) {
        guard isMonitoring else { return }
        currentReducerStart = Date()
    }
    
    /// Called when the reducer finishes processing.
    public func didReduce(_ action: Action) {
        guard isMonitoring else { return }
        currentReducerEnd = Date()
    }
    
    /// Called when all effects from an action have completed.
    public func didCompleteEffects(duration: TimeInterval?) {
        guard isMonitoring,
              let actionStart = currentActionStart,
              let reducerStart = currentReducerStart,
              let reducerEnd = currentReducerEnd else { return }
        
        let reducerDuration = reducerEnd.timeIntervalSince(reducerStart)
        let totalDuration = Date().timeIntervalSince(actionStart)
        
        var memoryDelta: Int64? = nil
        if configuration.trackMemory {
            memoryDelta = currentMemoryUsage() - baselineMemory
        }
        
        let metric = PerformanceMetrics.ActionMetric(
            actionName: currentActionName,
            timestamp: actionStart,
            reducerDuration: reducerDuration,
            effectDuration: duration,
            middlewareDuration: currentMiddlewareDuration,
            totalDuration: totalDuration,
            memoryDelta: memoryDelta
        )
        
        recordMetric(metric)
    }
    
    /// Records a completed action without effect tracking.
    public func didDispatch(_ action: Action) {
        guard isMonitoring,
              let actionStart = currentActionStart,
              let reducerStart = currentReducerStart,
              let reducerEnd = currentReducerEnd else { return }
        
        let reducerDuration = reducerEnd.timeIntervalSince(reducerStart)
        let totalDuration = Date().timeIntervalSince(actionStart)
        
        var memoryDelta: Int64? = nil
        if configuration.trackMemory {
            memoryDelta = currentMemoryUsage() - baselineMemory
        }
        
        let metric = PerformanceMetrics.ActionMetric(
            actionName: currentActionName,
            timestamp: actionStart,
            reducerDuration: reducerDuration,
            effectDuration: nil,
            middlewareDuration: currentMiddlewareDuration,
            totalDuration: totalDuration,
            memoryDelta: memoryDelta
        )
        
        recordMetric(metric)
    }
    
    // MARK: - Private Methods
    
    private func recordMetric(_ metric: PerformanceMetrics.ActionMetric) {
        metrics.record(metric)
        lastMetric = metric
        
        if configuration.logSlowReducers && metric.isSlowReducer {
            logger.warning("""
                Slow reducer detected: \(metric.actionName)
                Duration: \(String(format: "%.2fms", metric.reducerDuration * 1000))
                Threshold: \(String(format: "%.2fms", self.configuration.slowReducerThreshold * 1000))
                """)
        }
    }
    
    private func currentMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        return result == KERN_SUCCESS ? Int64(info.resident_size) : 0
    }
    
    private func startCleanupTask() {
        cleanupTask = Task { [weak self, configuration] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(configuration.cleanupInterval * 1_000_000_000))
                
                guard let self = self else { break }
                
                await MainActor.run {
                    // Cleanup is handled by PerformanceMetrics.record() automatically
                }
            }
        }
    }
    
    private func startThroughputTask() {
        throughputTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                guard let self = self else { break }
                
                await MainActor.run {
                    let recentCount = self.metrics.recentMetrics(seconds: 1).count
                    self.currentThroughput = Double(recentCount)
                }
            }
        }
    }
}

// MARK: - Performance Report

/// A detailed performance report for export or display.
public struct PerformanceReport: Codable {
    public let generatedAt: Date
    public let measurementDuration: TimeInterval
    public let totalActions: Int
    public let averageReducerTime: Double
    public let maxReducerTime: Double
    public let slowActionCount: Int
    public let actionsPerSecond: Double
    public let topSlowActions: [SlowAction]
    
    public struct SlowAction: Codable {
        public let name: String
        public let duration: Double
        public let timestamp: Date
    }
    
    public init(from metrics: PerformanceMetrics) {
        self.generatedAt = Date()
        self.measurementDuration = Date().timeIntervalSince(metrics.startTime)
        
        let stats = metrics.statistics
        self.totalActions = stats.totalActions
        self.averageReducerTime = stats.averageReducerTime * 1000 // Convert to ms
        self.maxReducerTime = stats.maxReducerTime * 1000
        self.slowActionCount = stats.slowActionCount
        self.actionsPerSecond = stats.actionsPerSecond
        
        self.topSlowActions = metrics.slowActions
            .sorted { $0.reducerDuration > $1.reducerDuration }
            .prefix(10)
            .map { SlowAction(name: $0.actionName, duration: $0.reducerDuration * 1000, timestamp: $0.timestamp) }
    }
    
    /// Exports the report as JSON.
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}

// MARK: - Performance Middleware

/// Middleware that automatically tracks performance metrics.
public struct PerformanceMiddleware<State, Action>: Middleware {
    public let name: String = "PerformanceMiddleware"
    
    private let monitor: PerformanceMonitor<State, Action>
    
    public init(monitor: PerformanceMonitor<State, Action>) {
        self.monitor = monitor
    }
    
    public func handle(
        action: Action,
        state: State,
        next: @escaping (Action) -> Void
    ) {
        Task { @MainActor in
            monitor.willDispatch(action)
        }
        
        next(action)
        
        Task { @MainActor in
            monitor.didDispatch(action)
        }
    }
}
