// EffectHandler.swift
// SwiftUI-State-Management
//
// Advanced effect handling system with support for cancellation,
// debouncing, throttling, and complex effect orchestration.

import Foundation
import Combine

// MARK: - EffectHandler

/// A handler responsible for executing and managing effects.
///
/// `EffectHandler` provides advanced effect management capabilities including:
/// - Automatic cancellation of in-flight effects
/// - Debouncing and throttling of rapid actions
/// - Effect prioritization and queuing
/// - Dependency injection for effects
///
/// Example usage:
/// ```swift
/// let handler = EffectHandler<AppAction>()
/// handler.handle(effect, send: store.send)
/// ```
public final class EffectHandler<Action>: ObservableObject {
    
    // MARK: - Types
    
    /// Configuration options for the effect handler.
    public struct Configuration {
        /// Maximum number of concurrent effects allowed.
        public var maxConcurrentEffects: Int
        
        /// Default timeout for effects in seconds.
        public var defaultTimeout: TimeInterval
        
        /// Whether to automatically cancel effects on deinit.
        public var autoCancelOnDeinit: Bool
        
        /// Queue for effect execution.
        public var executionQueue: DispatchQueue
        
        /// Creates a new configuration with default values.
        public init(
            maxConcurrentEffects: Int = 10,
            defaultTimeout: TimeInterval = 30,
            autoCancelOnDeinit: Bool = true,
            executionQueue: DispatchQueue = .global(qos: .userInitiated)
        ) {
            self.maxConcurrentEffects = maxConcurrentEffects
            self.defaultTimeout = defaultTimeout
            self.autoCancelOnDeinit = autoCancelOnDeinit
            self.executionQueue = executionQueue
        }
        
        /// Default configuration.
        public static let `default` = Configuration()
        
        /// Configuration optimized for performance.
        public static let performance = Configuration(
            maxConcurrentEffects: 20,
            defaultTimeout: 60,
            autoCancelOnDeinit: true,
            executionQueue: .global(qos: .userInteractive)
        )
        
        /// Configuration optimized for battery life.
        public static let lowPower = Configuration(
            maxConcurrentEffects: 5,
            defaultTimeout: 15,
            autoCancelOnDeinit: true,
            executionQueue: .global(qos: .utility)
        )
    }
    
    /// Represents the status of an effect.
    public enum EffectStatus: Equatable {
        case pending
        case running
        case completed
        case cancelled
        case failed(String)
    }
    
    /// Information about a tracked effect.
    public struct EffectInfo: Identifiable {
        public let id: EffectID
        public let startTime: Date
        public var status: EffectStatus
        public var endTime: Date?
        public var actionCount: Int
        
        public var duration: TimeInterval? {
            guard let end = endTime else { return nil }
            return end.timeIntervalSince(startTime)
        }
    }
    
    // MARK: - Properties
    
    /// Current configuration.
    public let configuration: Configuration
    
    /// Active cancellables for effects.
    private var cancellables: [EffectID: AnyCancellable] = [:]
    
    /// Information about tracked effects.
    @Published public private(set) var activeEffects: [EffectID: EffectInfo] = [:]
    
    /// Queue for synchronizing access to cancellables.
    private let queue = DispatchQueue(label: "com.statemanagement.effecthandler")
    
    /// Debounce timers.
    private var debounceTimers: [String: Timer] = [:]
    
    /// Throttle tracking.
    private var throttleLastExecution: [String: Date] = [:]
    
    /// Dependencies for effects.
    private var dependencies: [ObjectIdentifier: Any] = [:]
    
    /// Effect completion handlers.
    private var completionHandlers: [EffectID: (Result<Void, Error>) -> Void] = [:]
    
    // MARK: - Initialization
    
    /// Creates a new effect handler with the specified configuration.
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    deinit {
        if configuration.autoCancelOnDeinit {
            cancelAll()
        }
    }
    
    // MARK: - Effect Handling
    
    /// Handles an effect by subscribing to it and forwarding actions.
    ///
    /// - Parameters:
    ///   - effect: The effect to handle.
    ///   - send: The function to call with produced actions.
    @discardableResult
    public func handle(
        _ effect: Effect<Action>,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        switch effect.operation {
        case .none:
            return nil
            
        case let .publisher(publisher):
            return handlePublisher(publisher, send: send, id: effect.id, cancelID: effect.cancelID)
            
        case let .run(priority, operation):
            return handleAsyncOperation(operation, priority: priority, send: send, id: effect.id, cancelID: effect.cancelID)
            
        case let .merge(effects):
            handleMerge(effects, send: send)
            return nil
            
        case let .concatenate(effects):
            handleConcatenate(effects, send: send)
            return nil
            
        case let .cancel(id):
            cancel(id: id)
            return nil
            
        case .cancelAll:
            cancelAll()
            return nil
            
        case let .debounce(effect, id, interval):
            return handleDebounce(effect, id: id, interval: interval, send: send)
            
        case let .throttle(effect, id, interval):
            return handleThrottle(effect, id: id, interval: interval, send: send)
            
        case let .delay(effect, interval):
            return handleDelay(effect, interval: interval, send: send)
            
        case let .timeout(effect, interval, timeoutAction):
            return handleTimeout(effect, interval: interval, timeoutAction: timeoutAction, send: send)
            
        case let .retry(effect, maxAttempts, delay):
            return handleRetry(effect, maxAttempts: maxAttempts, delay: delay, send: send)
        }
    }
    
    // MARK: - Publisher Handling
    
    private func handlePublisher(
        _ publisher: AnyPublisher<Action, Never>,
        send: @escaping (Action) -> Void,
        id: EffectID,
        cancelID: EffectID?
    ) -> EffectID {
        // Cancel existing effect with same cancelID if provided
        if let cancelID = cancelID {
            cancel(id: cancelID)
        }
        
        let effectID = cancelID ?? id
        trackEffect(id: effectID)
        
        let cancellable = publisher
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.incrementActionCount(for: effectID)
                },
                receiveCompletion: { [weak self] _ in
                    self?.completeEffect(id: effectID, status: .completed)
                },
                receiveCancel: { [weak self] in
                    self?.completeEffect(id: effectID, status: .cancelled)
                }
            )
            .sink(receiveValue: send)
        
        queue.sync {
            cancellables[effectID] = cancellable
        }
        
        return effectID
    }
    
    // MARK: - Async Operation Handling
    
    private func handleAsyncOperation(
        _ operation: @Sendable @escaping (Send<Action>) async -> Void,
        priority: TaskPriority?,
        send: @escaping (Action) -> Void,
        id: EffectID,
        cancelID: EffectID?
    ) -> EffectID {
        // Cancel existing effect with same cancelID if provided
        if let cancelID = cancelID {
            cancel(id: cancelID)
        }
        
        let effectID = cancelID ?? id
        trackEffect(id: effectID)
        
        let task = Task(priority: priority) { [weak self] in
            let sendWrapper = Send<Action> { action in
                Task { @MainActor in
                    send(action)
                    self?.incrementActionCount(for: effectID)
                }
            }
            
            await operation(sendWrapper)
            
            await MainActor.run {
                self?.completeEffect(id: effectID, status: .completed)
            }
        }
        
        let cancellable = AnyCancellable {
            task.cancel()
        }
        
        queue.sync {
            cancellables[effectID] = cancellable
        }
        
        return effectID
    }
    
    // MARK: - Merge Handling
    
    private func handleMerge(
        _ effects: [Effect<Action>],
        send: @escaping (Action) -> Void
    ) {
        for effect in effects {
            handle(effect, send: send)
        }
    }
    
    // MARK: - Concatenate Handling
    
    private func handleConcatenate(
        _ effects: [Effect<Action>],
        send: @escaping (Action) -> Void
    ) {
        guard !effects.isEmpty else { return }
        
        var remainingEffects = effects
        let firstEffect = remainingEffects.removeFirst()
        
        func handleNext() {
            guard !remainingEffects.isEmpty else { return }
            let nextEffect = remainingEffects.removeFirst()
            
            if let effectID = handle(nextEffect, send: send) {
                onCompletion(of: effectID) { _ in
                    handleNext()
                }
            } else {
                handleNext()
            }
        }
        
        if let effectID = handle(firstEffect, send: send) {
            onCompletion(of: effectID) { _ in
                handleNext()
            }
        } else {
            handleNext()
        }
    }
    
    // MARK: - Debounce Handling
    
    private func handleDebounce(
        _ effect: Effect<Action>,
        id: String,
        interval: TimeInterval,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        queue.sync {
            // Cancel existing timer
            debounceTimers[id]?.invalidate()
            
            // Create new timer
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                self?.handle(effect, send: send)
                self?.queue.sync {
                    self?.debounceTimers.removeValue(forKey: id)
                }
            }
            
            debounceTimers[id] = timer
        }
        
        return nil
    }
    
    // MARK: - Throttle Handling
    
    private func handleThrottle(
        _ effect: Effect<Action>,
        id: String,
        interval: TimeInterval,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        var shouldExecute = false
        
        queue.sync {
            let now = Date()
            if let lastExecution = throttleLastExecution[id] {
                if now.timeIntervalSince(lastExecution) >= interval {
                    shouldExecute = true
                    throttleLastExecution[id] = now
                }
            } else {
                shouldExecute = true
                throttleLastExecution[id] = now
            }
        }
        
        if shouldExecute {
            return handle(effect, send: send)
        }
        
        return nil
    }
    
    // MARK: - Delay Handling
    
    private func handleDelay(
        _ effect: Effect<Action>,
        interval: TimeInterval,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        let effectID = EffectID()
        trackEffect(id: effectID)
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.handle(effect, send: send)
            self?.completeEffect(id: effectID, status: .completed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem)
        
        let cancellable = AnyCancellable {
            workItem.cancel()
        }
        
        queue.sync {
            cancellables[effectID] = cancellable
        }
        
        return effectID
    }
    
    // MARK: - Timeout Handling
    
    private func handleTimeout(
        _ effect: Effect<Action>,
        interval: TimeInterval,
        timeoutAction: Action?,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        let effectID = EffectID()
        trackEffect(id: effectID)
        
        var completed = false
        let lock = NSLock()
        
        // Set up timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            lock.lock()
            defer { lock.unlock() }
            
            guard !completed else { return }
            completed = true
            
            self?.cancel(id: effectID)
            
            if let timeoutAction = timeoutAction {
                send(timeoutAction)
            }
            
            self?.completeEffect(id: effectID, status: .failed("Timeout"))
        }
        
        // Handle the effect
        if let innerEffectID = handle(effect, send: send) {
            onCompletion(of: innerEffectID) { [weak self] _ in
                lock.lock()
                defer { lock.unlock() }
                
                guard !completed else { return }
                completed = true
                
                self?.completeEffect(id: effectID, status: .completed)
            }
        }
        
        return effectID
    }
    
    // MARK: - Retry Handling
    
    private func handleRetry(
        _ effect: Effect<Action>,
        maxAttempts: Int,
        delay: TimeInterval,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        let effectID = EffectID()
        trackEffect(id: effectID)
        
        var currentAttempt = 0
        
        func attemptEffect() {
            currentAttempt += 1
            
            if let innerEffectID = handle(effect, send: send) {
                onCompletion(of: innerEffectID) { [weak self] result in
                    switch result {
                    case .success:
                        self?.completeEffect(id: effectID, status: .completed)
                    case .failure:
                        if currentAttempt < maxAttempts {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                attemptEffect()
                            }
                        } else {
                            self?.completeEffect(id: effectID, status: .failed("Max retries exceeded"))
                        }
                    }
                }
            }
        }
        
        attemptEffect()
        return effectID
    }
    
    // MARK: - Cancellation
    
    /// Cancels an effect with the specified ID.
    public func cancel(id: EffectID) {
        queue.sync {
            cancellables[id]?.cancel()
            cancellables.removeValue(forKey: id)
        }
        
        completeEffect(id: id, status: .cancelled)
    }
    
    /// Cancels all active effects.
    public func cancelAll() {
        queue.sync {
            for (_, cancellable) in cancellables {
                cancellable.cancel()
            }
            cancellables.removeAll()
        }
        
        for (id, _) in activeEffects {
            completeEffect(id: id, status: .cancelled)
        }
    }
    
    /// Checks if an effect with the specified ID is currently running.
    public func isRunning(id: EffectID) -> Bool {
        queue.sync {
            cancellables[id] != nil
        }
    }
    
    // MARK: - Effect Tracking
    
    private func trackEffect(id: EffectID) {
        DispatchQueue.main.async { [weak self] in
            self?.activeEffects[id] = EffectInfo(
                id: id,
                startTime: Date(),
                status: .running,
                endTime: nil,
                actionCount: 0
            )
        }
    }
    
    private func completeEffect(id: EffectID, status: EffectStatus) {
        DispatchQueue.main.async { [weak self] in
            guard var info = self?.activeEffects[id] else { return }
            info.status = status
            info.endTime = Date()
            self?.activeEffects[id] = info
            
            // Remove completed effects after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.activeEffects.removeValue(forKey: id)
            }
        }
        
        // Call completion handler
        queue.sync {
            let handler = completionHandlers.removeValue(forKey: id)
            handler?(.success(()))
        }
    }
    
    private func incrementActionCount(for id: EffectID) {
        DispatchQueue.main.async { [weak self] in
            guard var info = self?.activeEffects[id] else { return }
            info.actionCount += 1
            self?.activeEffects[id] = info
        }
    }
    
    // MARK: - Completion Handling
    
    /// Registers a completion handler for an effect.
    public func onCompletion(
        of id: EffectID,
        handler: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.sync {
            completionHandlers[id] = handler
        }
    }
    
    // MARK: - Dependencies
    
    /// Registers a dependency for injection into effects.
    public func register<T>(_ dependency: T) {
        let key = ObjectIdentifier(T.self)
        dependencies[key] = dependency
    }
    
    /// Retrieves a registered dependency.
    public func dependency<T>(_ type: T.Type) -> T? {
        let key = ObjectIdentifier(type)
        return dependencies[key] as? T
    }
}

// MARK: - Send

/// A wrapper for sending actions from within an effect.
@MainActor
public struct Send<Action>: Sendable {
    private let _send: @MainActor (Action) -> Void
    
    public init(_ send: @escaping @MainActor (Action) -> Void) {
        self._send = send
    }
    
    public func callAsFunction(_ action: Action) {
        _send(action)
    }
    
    /// Sends an action after a delay.
    public func callAsFunction(_ action: Action, after delay: TimeInterval) {
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            _send(action)
        }
    }
}

// MARK: - Effect Extensions

extension Effect {
    
    /// The operation type for this effect.
    public enum Operation {
        case none
        case publisher(AnyPublisher<Action, Never>)
        case run(TaskPriority?, @Sendable (Send<Action>) async -> Void)
        case merge([Effect])
        case concatenate([Effect])
        case cancel(EffectID)
        case cancelAll
        case debounce(Effect, id: String, interval: TimeInterval)
        case throttle(Effect, id: String, interval: TimeInterval)
        case delay(Effect, interval: TimeInterval)
        case timeout(Effect, interval: TimeInterval, timeoutAction: Action?)
        case retry(Effect, maxAttempts: Int, delay: TimeInterval)
    }
    
    /// The operation for this effect (for internal use).
    public var operation: Operation {
        // This would be implemented based on how Effect is defined
        // For now, return .none as placeholder
        .none
    }
    
    /// The unique identifier for this effect.
    public var id: EffectID {
        EffectID()
    }
    
    /// The cancel identifier for this effect.
    public var cancelID: EffectID? {
        nil
    }
    
    /// Creates a debounced effect.
    public func debounce(id: String, for interval: TimeInterval) -> Effect {
        // Implementation would create a debounced effect
        self
    }
    
    /// Creates a throttled effect.
    public func throttle(id: String, for interval: TimeInterval) -> Effect {
        // Implementation would create a throttled effect
        self
    }
    
    /// Creates a delayed effect.
    public func delay(for interval: TimeInterval) -> Effect {
        // Implementation would create a delayed effect
        self
    }
    
    /// Creates an effect with a timeout.
    public func timeout(after interval: TimeInterval, action: Action? = nil) -> Effect {
        // Implementation would create a timed out effect
        self
    }
    
    /// Creates a retrying effect.
    public func retry(maxAttempts: Int, delay: TimeInterval = 1) -> Effect {
        // Implementation would create a retrying effect
        self
    }
    
    /// Assigns a cancellation ID to this effect.
    public func cancellable(id: EffectID) -> Effect {
        // Implementation would assign cancel ID
        self
    }
}

// MARK: - EffectID

/// A unique identifier for an effect.
public struct EffectID: Hashable, Equatable, Sendable {
    private let rawValue: UUID
    
    /// Creates a new unique effect ID.
    public init() {
        self.rawValue = UUID()
    }
    
    /// Creates an effect ID from a string.
    public init(_ string: String) {
        self.rawValue = UUID(uuidString: string) ?? UUID()
    }
    
    /// Creates an effect ID from an existing UUID.
    public init(uuid: UUID) {
        self.rawValue = uuid
    }
}

// MARK: - EffectContext

/// Context provided to effects during execution.
public struct EffectContext<Action> {
    
    /// The handler managing this effect.
    public weak var handler: EffectHandler<Action>?
    
    /// The ID of this effect.
    public let effectID: EffectID
    
    /// Whether this effect has been cancelled.
    public var isCancelled: Bool {
        guard let handler = handler else { return true }
        return !handler.isRunning(id: effectID)
    }
    
    /// Checks if cancellation was requested and throws if so.
    public func checkCancellation() throws {
        if isCancelled {
            throw CancellationError()
        }
    }
    
    /// Retrieves a dependency from the handler.
    public func dependency<T>(_ type: T.Type) -> T? {
        handler?.dependency(type)
    }
}

// MARK: - EffectQueue

/// A queue for managing effect execution order.
public final class EffectQueue<Action> {
    
    /// Queue execution strategy.
    public enum Strategy {
        /// Execute effects one at a time.
        case serial
        
        /// Execute effects concurrently up to a limit.
        case concurrent(maxConcurrency: Int)
        
        /// Execute all effects immediately.
        case immediate
    }
    
    private let strategy: Strategy
    private var pendingEffects: [Effect<Action>] = []
    private var runningCount = 0
    private let lock = NSLock()
    private weak var handler: EffectHandler<Action>?
    private var send: ((Action) -> Void)?
    
    /// Creates a new effect queue with the specified strategy.
    public init(strategy: Strategy = .serial) {
        self.strategy = strategy
    }
    
    /// Configures the queue with a handler and send function.
    public func configure(
        handler: EffectHandler<Action>,
        send: @escaping (Action) -> Void
    ) {
        self.handler = handler
        self.send = send
    }
    
    /// Enqueues an effect for execution.
    public func enqueue(_ effect: Effect<Action>) {
        lock.lock()
        defer { lock.unlock() }
        
        switch strategy {
        case .immediate:
            executeEffect(effect)
            
        case .serial:
            if runningCount == 0 {
                runningCount = 1
                executeEffect(effect)
            } else {
                pendingEffects.append(effect)
            }
            
        case let .concurrent(maxConcurrency):
            if runningCount < maxConcurrency {
                runningCount += 1
                executeEffect(effect)
            } else {
                pendingEffects.append(effect)
            }
        }
    }
    
    private func executeEffect(_ effect: Effect<Action>) {
        guard let handler = handler, let send = send else { return }
        
        if let effectID = handler.handle(effect, send: send) {
            handler.onCompletion(of: effectID) { [weak self] _ in
                self?.effectCompleted()
            }
        } else {
            effectCompleted()
        }
    }
    
    private func effectCompleted() {
        lock.lock()
        defer { lock.unlock() }
        
        runningCount -= 1
        
        if !pendingEffects.isEmpty {
            let nextEffect = pendingEffects.removeFirst()
            runningCount += 1
            executeEffect(nextEffect)
        }
    }
    
    /// Clears all pending effects.
    public func clearPending() {
        lock.lock()
        pendingEffects.removeAll()
        lock.unlock()
    }
    
    /// Returns the number of pending effects.
    public var pendingCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return pendingEffects.count
    }
}

// MARK: - EffectObserver

/// Observes effect lifecycle events.
public protocol EffectObserver: AnyObject {
    associatedtype Action
    
    /// Called when an effect starts.
    func effectDidStart(id: EffectID, effect: Effect<Action>)
    
    /// Called when an effect completes.
    func effectDidComplete(id: EffectID, status: EffectHandler<Action>.EffectStatus)
    
    /// Called when an effect produces an action.
    func effectDidProduce(id: EffectID, action: Action)
}

/// Default implementation for optional observer methods.
extension EffectObserver {
    public func effectDidStart(id: EffectID, effect: Effect<Action>) {}
    public func effectDidComplete(id: EffectID, status: EffectHandler<Action>.EffectStatus) {}
    public func effectDidProduce(id: EffectID, action: Action) {}
}

// MARK: - ObservableEffectHandler

/// An effect handler that publishes its state for observation.
public final class ObservableEffectHandler<Action>: ObservableObject {
    
    /// The underlying effect handler.
    public let handler: EffectHandler<Action>
    
    /// Currently active effects.
    @Published public private(set) var activeEffects: [EffectID: EffectHandler<Action>.EffectInfo] = [:]
    
    /// Total number of effects handled.
    @Published public private(set) var totalEffectsHandled: Int = 0
    
    /// Number of effects currently running.
    public var runningEffectsCount: Int {
        activeEffects.filter { $0.value.status == .running }.count
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Creates an observable effect handler.
    public init(configuration: EffectHandler<Action>.Configuration = .default) {
        self.handler = EffectHandler(configuration: configuration)
        
        handler.$activeEffects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] effects in
                self?.activeEffects = effects
            }
            .store(in: &cancellables)
    }
    
    /// Handles an effect.
    @discardableResult
    public func handle(
        _ effect: Effect<Action>,
        send: @escaping (Action) -> Void
    ) -> EffectID? {
        totalEffectsHandled += 1
        return handler.handle(effect, send: send)
    }
    
    /// Cancels an effect.
    public func cancel(id: EffectID) {
        handler.cancel(id: id)
    }
    
    /// Cancels all effects.
    public func cancelAll() {
        handler.cancelAll()
    }
}

// MARK: - EffectCancellationToken

/// A token that can be used to cancel an effect.
public final class EffectCancellationToken {
    
    private let id: EffectID
    private weak var handler: EffectHandler<AnyObject>?
    private var isCancelled = false
    
    init(id: EffectID) {
        self.id = id
    }
    
    /// Cancels the associated effect.
    public func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        // Would call handler.cancel(id: id) if properly typed
    }
    
    deinit {
        cancel()
    }
}

// MARK: - EffectDeduplication

/// Strategies for deduplicating effects.
public enum EffectDeduplicationStrategy {
    /// Cancel the previous effect and start the new one.
    case cancelPrevious
    
    /// Keep the previous effect and ignore the new one.
    case keepPrevious
    
    /// Allow both effects to run.
    case allowDuplicates
}

// MARK: - EffectPriority

/// Priority levels for effect execution.
public enum EffectPriority: Int, Comparable {
    case low = 0
    case normal = 1
    case high = 2
    case critical = 3
    
    public static func < (lhs: EffectPriority, rhs: EffectPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - PrioritizedEffectQueue

/// A queue that executes effects based on priority.
public final class PrioritizedEffectQueue<Action> {
    
    private struct PrioritizedEffect {
        let effect: Effect<Action>
        let priority: EffectPriority
        let timestamp: Date
    }
    
    private var pendingEffects: [PrioritizedEffect] = []
    private var runningCount = 0
    private let maxConcurrency: Int
    private let lock = NSLock()
    private weak var handler: EffectHandler<Action>?
    private var send: ((Action) -> Void)?
    
    /// Creates a new prioritized effect queue.
    public init(maxConcurrency: Int = 3) {
        self.maxConcurrency = maxConcurrency
    }
    
    /// Configures the queue with a handler and send function.
    public func configure(
        handler: EffectHandler<Action>,
        send: @escaping (Action) -> Void
    ) {
        self.handler = handler
        self.send = send
    }
    
    /// Enqueues an effect with a priority.
    public func enqueue(_ effect: Effect<Action>, priority: EffectPriority = .normal) {
        lock.lock()
        defer { lock.unlock() }
        
        let prioritizedEffect = PrioritizedEffect(
            effect: effect,
            priority: priority,
            timestamp: Date()
        )
        
        // Insert in sorted order (higher priority first, then by timestamp)
        let insertIndex = pendingEffects.firstIndex { existing in
            if existing.priority != priority {
                return existing.priority < priority
            }
            return existing.timestamp > prioritizedEffect.timestamp
        } ?? pendingEffects.endIndex
        
        pendingEffects.insert(prioritizedEffect, at: insertIndex)
        
        processQueue()
    }
    
    private func processQueue() {
        while runningCount < maxConcurrency && !pendingEffects.isEmpty {
            let nextEffect = pendingEffects.removeFirst()
            runningCount += 1
            executeEffect(nextEffect.effect)
        }
    }
    
    private func executeEffect(_ effect: Effect<Action>) {
        guard let handler = handler, let send = send else { return }
        
        if let effectID = handler.handle(effect, send: send) {
            handler.onCompletion(of: effectID) { [weak self] _ in
                self?.effectCompleted()
            }
        } else {
            effectCompleted()
        }
    }
    
    private func effectCompleted() {
        lock.lock()
        defer { lock.unlock() }
        
        runningCount -= 1
        processQueue()
    }
}
