import Foundation
import os.log

// MARK: - Middleware Protocol

/// A protocol for intercepting actions before they reach the reducer.
/// Middleware can transform actions, perform side effects, or cancel actions entirely.
///
/// ## Usage
///
/// ```swift
/// struct LoggingMiddleware: Middleware {
///     typealias State = AppState
///     typealias Action = AppAction
///
///     let name = "Logger"
///
///     func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
///         print("Action: \(action)")
///         next(action)  // Continue to next middleware/reducer
///         print("New state: \(state)")
///     }
/// }
/// ```
public protocol Middleware<State, Action> {
    associatedtype State
    associatedtype Action
    
    /// The unique name of this middleware.
    var name: String { get }
    
    /// Handles an action, optionally modifying or canceling it.
    ///
    /// - Parameters:
    ///   - action: The action being dispatched.
    ///   - state: The current state (read-only).
    ///   - next: Call this to continue to the next middleware/reducer.
    func handle(action: Action, state: State, next: @escaping (Action) -> Void)
}

// MARK: - Type-Erased Middleware

/// A type-erased wrapper for middleware.
public struct AnyMiddleware<State, Action>: Middleware {
    
    public let name: String
    private let _handle: (Action, State, @escaping (Action) -> Void) -> Void
    
    /// Creates a type-erased middleware from a concrete implementation.
    public init<M: Middleware>(_ middleware: M) where M.State == State, M.Action == Action {
        self.name = middleware.name
        self._handle = middleware.handle
    }
    
    /// Creates a middleware from a closure.
    public init(
        name: String,
        handle: @escaping (Action, State, @escaping (Action) -> Void) -> Void
    ) {
        self.name = name
        self._handle = handle
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        _handle(action, state, next)
    }
}

// MARK: - Built-in Middleware

/// Middleware that logs all dispatched actions.
public struct LoggingMiddleware<State, Action>: Middleware {
    
    public let name = "LoggingMiddleware"
    
    public enum LogLevel: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        
        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    private let level: LogLevel
    private let logger: Logger
    private let includeState: Bool
    private let actionFilter: ((Action) -> Bool)?
    
    /// Creates a logging middleware.
    ///
    /// - Parameters:
    ///   - level: Minimum log level.
    ///   - includeState: Whether to log state changes.
    ///   - filter: Optional filter for which actions to log.
    public init(
        level: LogLevel = .debug,
        includeState: Bool = false,
        filter: ((Action) -> Bool)? = nil
    ) {
        self.level = level
        self.includeState = includeState
        self.actionFilter = filter
        self.logger = Logger(subsystem: "SwiftUIStateManagement", category: "Actions")
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        // Check filter
        if let filter = actionFilter, !filter(action) {
            next(action)
            return
        }
        
        let actionDescription = String(describing: action)
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        
        switch level {
        case .debug:
            logger.debug("[\(timestamp)] 📤 \(actionDescription)")
        case .info:
            logger.info("[\(timestamp)] 📤 \(actionDescription)")
        case .warning:
            logger.warning("[\(timestamp)] 📤 \(actionDescription)")
        case .error:
            logger.error("[\(timestamp)] 📤 \(actionDescription)")
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        next(action)
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        if includeState {
            logger.debug("[\(timestamp)] State: \(String(describing: state))")
        }
        
        logger.debug("[\(timestamp)] ⏱️ Duration: \(String(format: "%.2fms", duration * 1000))")
    }
}

/// Middleware that throttles actions by type.
public struct ThrottleMiddleware<State, Action: Hashable>: Middleware {
    
    public let name = "ThrottleMiddleware"
    
    private let duration: TimeInterval
    private var lastDispatchTimes: [Int: Date] = [:]
    
    /// Creates a throttle middleware.
    ///
    /// - Parameter duration: Minimum time between same actions.
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        let actionHash = action.hashValue
        let now = Date()
        
        if let lastTime = lastDispatchTimes[actionHash],
           now.timeIntervalSince(lastTime) < duration {
            // Throttled - skip this action
            return
        }
        
        var mutableSelf = self
        mutableSelf.lastDispatchTimes[actionHash] = now
        next(action)
    }
}

/// Middleware that validates actions before they reach the reducer.
public struct ValidationMiddleware<State, Action>: Middleware {
    
    public let name = "ValidationMiddleware"
    
    public struct ValidationResult {
        public let isValid: Bool
        public let errorMessage: String?
        
        public static let valid = ValidationResult(isValid: true, errorMessage: nil)
        
        public static func invalid(_ message: String) -> ValidationResult {
            ValidationResult(isValid: false, errorMessage: message)
        }
    }
    
    private let validate: (Action, State) -> ValidationResult
    private let onInvalid: ((Action, String) -> Void)?
    private let logger = Logger(subsystem: "SwiftUIStateManagement", category: "Validation")
    
    /// Creates a validation middleware.
    ///
    /// - Parameters:
    ///   - validate: Validation closure.
    ///   - onInvalid: Called when validation fails.
    public init(
        validate: @escaping (Action, State) -> ValidationResult,
        onInvalid: ((Action, String) -> Void)? = nil
    ) {
        self.validate = validate
        self.onInvalid = onInvalid
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        let result = validate(action, state)
        
        if result.isValid {
            next(action)
        } else {
            let message = result.errorMessage ?? "Unknown validation error"
            logger.warning("Action rejected: \(String(describing: action)) - \(message)")
            onInvalid?(action, message)
        }
    }
}

/// Middleware that transforms actions before they reach the reducer.
public struct TransformMiddleware<State, Action>: Middleware {
    
    public let name: String
    private let transform: (Action, State) -> Action?
    
    /// Creates a transform middleware.
    ///
    /// - Parameters:
    ///   - name: Middleware name.
    ///   - transform: Transformation closure. Return nil to cancel the action.
    public init(
        name: String = "TransformMiddleware",
        transform: @escaping (Action, State) -> Action?
    ) {
        self.name = name
        self.transform = transform
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        if let transformed = transform(action, state) {
            next(transformed)
        }
        // If transform returns nil, action is cancelled
    }
}

/// Middleware that records all actions for debugging/replay.
public final class RecordingMiddleware<State, Action>: Middleware {
    
    public let name = "RecordingMiddleware"
    
    public struct Record {
        public let action: Action
        public let state: State
        public let timestamp: Date
    }
    
    public private(set) var records: [Record] = []
    public var maxRecords: Int = 1000
    
    public init() {}
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        let record = Record(action: action, state: state, timestamp: Date())
        records.append(record)
        
        // Trim old records
        if records.count > maxRecords {
            records.removeFirst(records.count - maxRecords)
        }
        
        next(action)
    }
    
    /// Clears all recorded actions.
    public func clear() {
        records.removeAll()
    }
    
    /// Exports records as JSON.
    public func exportJSON() throws -> Data where Action: Encodable, State: Encodable {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        struct ExportRecord: Encodable {
            let action: Action
            let state: State
            let timestamp: Date
        }
        
        let exportable = records.map {
            ExportRecord(action: $0.action, state: $0.state, timestamp: $0.timestamp)
        }
        
        return try encoder.encode(exportable)
    }
}

/// Middleware that adds analytics tracking.
public struct AnalyticsMiddleware<State, Action>: Middleware {
    
    public let name = "AnalyticsMiddleware"
    
    public struct AnalyticsEvent {
        public let name: String
        public let properties: [String: Any]
    }
    
    private let tracker: (AnalyticsEvent) -> Void
    private let actionToEvent: (Action) -> AnalyticsEvent?
    
    /// Creates an analytics middleware.
    ///
    /// - Parameters:
    ///   - actionToEvent: Maps actions to analytics events.
    ///   - tracker: Called with analytics events.
    public init(
        actionToEvent: @escaping (Action) -> AnalyticsEvent?,
        tracker: @escaping (AnalyticsEvent) -> Void
    ) {
        self.actionToEvent = actionToEvent
        self.tracker = tracker
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        if let event = actionToEvent(action) {
            tracker(event)
        }
        next(action)
    }
}

/// Middleware that catches and handles errors from effects.
public struct ErrorHandlingMiddleware<State, Action>: Middleware {
    
    public let name = "ErrorHandlingMiddleware"
    
    private let onError: (Error, Action) -> Action?
    private let logger = Logger(subsystem: "SwiftUIStateManagement", category: "Errors")
    
    /// Creates an error handling middleware.
    ///
    /// - Parameter onError: Called when an error occurs. Return an action to dispatch, or nil.
    public init(onError: @escaping (Error, Action) -> Action?) {
        self.onError = onError
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        next(action)
        // Note: Effect errors are handled in the Store, not middleware
    }
}

/// Middleware that provides undo/redo functionality.
public final class UndoMiddleware<State: Equatable, Action>: Middleware {
    
    public let name = "UndoMiddleware"
    
    private var undoStack: [State] = []
    private var redoStack: [State] = []
    private let maxUndoLevels: Int
    
    public init(maxUndoLevels: Int = 50) {
        self.maxUndoLevels = maxUndoLevels
    }
    
    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        // Save current state for undo
        undoStack.append(state)
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
        
        // Clear redo stack on new action
        redoStack.removeAll()
        
        next(action)
    }
    
    /// Returns the previous state for undo.
    public func popUndo(currentState: State) -> State? {
        guard let previousState = undoStack.popLast() else { return nil }
        redoStack.append(currentState)
        return previousState
    }
    
    /// Returns the next state for redo.
    public func popRedo(currentState: State) -> State? {
        guard let nextState = redoStack.popLast() else { return nil }
        undoStack.append(currentState)
        return nextState
    }
    
    /// Whether undo is available.
    public var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    /// Whether redo is available.
    public var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    /// Clears all undo/redo history.
    public func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}

// MARK: - Middleware Extensions

extension AnyMiddleware {
    /// Creates a logging middleware.
    public static func logging(
        includeState: Bool = false
    ) -> AnyMiddleware {
        AnyMiddleware(LoggingMiddleware<State, Action>(includeState: includeState))
    }
    
    /// Creates a validation middleware.
    public static func validation(
        _ validate: @escaping (Action, State) -> Bool,
        onInvalid: ((Action, String) -> Void)? = nil
    ) -> AnyMiddleware {
        let validationMiddleware = ValidationMiddleware<State, Action>(
            validate: { action, state in
                validate(action, state) ? .valid : .invalid("Validation failed")
            },
            onInvalid: onInvalid
        )
        return AnyMiddleware(validationMiddleware)
    }
    
    /// Creates a transform middleware.
    public static func transform(
        _ transform: @escaping (Action, State) -> Action?
    ) -> AnyMiddleware {
        AnyMiddleware(TransformMiddleware<State, Action>(transform: transform))
    }
}
