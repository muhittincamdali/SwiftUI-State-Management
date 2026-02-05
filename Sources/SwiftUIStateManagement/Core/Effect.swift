import Foundation
import Combine

// MARK: - Effect

/// Represents an asynchronous side effect that can optionally produce
/// an action to feed back into the store.
///
/// Effects are the primary mechanism for handling async work like network
/// requests, timers, persistence, or any other side effects in your app.
///
/// ## Basic Usage
///
/// ```swift
/// func reduce(state: inout State, action: Action) -> Effect<Action> {
///     switch action {
///     case .fetchUsers:
///         return .task {
///             let users = try await api.fetchUsers()
///             return .usersLoaded(users)
///         }
///     case .usersLoaded(let users):
///         state.users = users
///         return .none
///     }
/// }
/// ```
///
/// ## Effect Composition
///
/// ```swift
/// Effect.merge(
///     .task { ... },
///     .task { ... }
/// )
/// ```
///
/// ## Cancellation
///
/// ```swift
/// Effect.task(id: "search") { ... }
/// Effect.cancel(id: "search")
/// ```
public struct Effect<Action>: @unchecked Sendable {

    // MARK: - Kind

    /// The underlying representation of the effect.
    enum Kind {
        /// No side effect.
        case none

        /// An async task that may produce an action.
        case task(@Sendable () async throws -> Action?)

        /// Multiple effects combined together.
        case combine([Effect<Action>])

        /// Cancel a previously started effect by identifier.
        case cancel(String)
        
        /// Debounce an effect with given duration.
        case debounce(Effect<Action>, duration: TimeInterval, id: String)
        
        /// Throttle an effect with given duration.
        case throttle(Effect<Action>, duration: TimeInterval, id: String)
    }

    /// The kind of this effect.
    let kind: Kind
    
    /// Optional identifier for cancellation.
    let id: String?

    // MARK: - Private Initialization
    
    private init(kind: Kind, id: String? = nil) {
        self.kind = kind
        self.id = id
    }

    // MARK: - Factories

    /// An effect that does nothing.
    public static var none: Effect {
        Effect(kind: .none)
    }

    /// Creates an effect from an async closure that produces an action.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for cancellation.
    ///   - priority: Task priority for execution.
    ///   - work: The async work to perform.
    /// - Returns: An effect wrapping the async task.
    public static func task(
        id: String? = nil,
        priority: TaskPriority? = nil,
        _ work: @Sendable @escaping () async throws -> Action?
    ) -> Effect {
        Effect(kind: .task(work), id: id)
    }
    
    /// Creates an effect from an async closure that produces an action.
    ///
    /// - Parameter work: The async work to perform.
    /// - Returns: An effect wrapping the async task.
    public init(_ work: @Sendable @escaping () async throws -> Action?) {
        self.kind = .task(work)
        self.id = nil
    }

    /// Creates an effect that performs work without producing an action.
    ///
    /// - Parameters:
    ///   - id: Optional identifier for cancellation.
    ///   - work: The async work to perform (fire-and-forget).
    /// - Returns: An effect that runs the work.
    public static func fireAndForget(
        id: String? = nil,
        _ work: @Sendable @escaping () async throws -> Void
    ) -> Effect {
        Effect(kind: .task({
            try await work()
            return nil
        }), id: id)
    }

    /// Creates an effect that immediately produces an action synchronously.
    ///
    /// - Parameter action: The action to dispatch.
    /// - Returns: An effect that returns the action immediately.
    public static func send(_ action: Action) -> Effect {
        Effect(kind: .task({ action }))
    }
    
    /// Alias for send.
    public static func just(_ action: Action) -> Effect {
        send(action)
    }
    
    /// Creates an effect that dispatches multiple actions in sequence.
    ///
    /// - Parameter actions: The actions to dispatch.
    /// - Returns: A merged effect of all actions.
    public static func send(_ actions: Action...) -> Effect {
        merge(actions.map { send($0) })
    }

    /// Merges multiple effects into a single combined effect.
    /// All effects run concurrently.
    ///
    /// - Parameter effects: The effects to merge.
    /// - Returns: A combined effect.
    public static func merge(_ effects: [Effect<Action>]) -> Effect {
        let filtered = effects.filter {
            if case .none = $0.kind { return false }
            return true
        }
        guard !filtered.isEmpty else { return .none }
        if filtered.count == 1 { return filtered[0] }
        return Effect(kind: .combine(filtered))
    }

    /// Convenience for merging variadic effects.
    public static func merge(_ effects: Effect<Action>...) -> Effect {
        merge(effects)
    }
    
    /// Concatenates effects to run one after another.
    ///
    /// - Parameter effects: The effects to concatenate.
    /// - Returns: A concatenated effect.
    public static func concatenate(_ effects: [Effect<Action>]) -> Effect {
        guard !effects.isEmpty else { return .none }
        
        return .task {
            for effect in effects {
                if case .task(let work) = effect.kind {
                    if let action = try await work() {
                        return action
                    }
                }
            }
            return nil
        }
    }
    
    /// Convenience for concatenating variadic effects.
    public static func concatenate(_ effects: Effect<Action>...) -> Effect {
        concatenate(effects)
    }

    /// Creates a cancellation effect for the given identifier.
    ///
    /// - Parameter id: The effect identifier to cancel.
    /// - Returns: A cancellation effect.
    public static func cancel(id: String) -> Effect {
        Effect(kind: .cancel(id))
    }
    
    /// Creates a cancellation effect for multiple identifiers.
    ///
    /// - Parameter ids: The effect identifiers to cancel.
    /// - Returns: A merged cancellation effect.
    public static func cancel(ids: String...) -> Effect {
        merge(ids.map { cancel(id: $0) })
    }
    
    // MARK: - Timing Effects
    
    /// Creates a debounced effect that only executes after a quiet period.
    ///
    /// - Parameters:
    ///   - duration: The debounce duration in seconds.
    ///   - id: Unique identifier for this debounce group.
    ///   - effect: The effect to debounce.
    /// - Returns: A debounced effect.
    public static func debounce(
        duration: TimeInterval,
        id: String,
        effect: Effect<Action>
    ) -> Effect {
        Effect(kind: .debounce(effect, duration: duration, id: id))
    }
    
    /// Creates a throttled effect that limits execution frequency.
    ///
    /// - Parameters:
    ///   - duration: The throttle duration in seconds.
    ///   - id: Unique identifier for this throttle group.
    ///   - effect: The effect to throttle.
    /// - Returns: A throttled effect.
    public static func throttle(
        duration: TimeInterval,
        id: String,
        effect: Effect<Action>
    ) -> Effect {
        Effect(kind: .throttle(effect, duration: duration, id: id))
    }
    
    /// Creates an effect that executes after a delay.
    ///
    /// - Parameters:
    ///   - seconds: The delay in seconds.
    ///   - action: The action to dispatch after delay.
    /// - Returns: A delayed effect.
    public static func delay(
        _ seconds: TimeInterval,
        action: Action
    ) -> Effect {
        .task {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return action
        }
    }
    
    /// Creates an effect that executes after a delay.
    ///
    /// - Parameters:
    ///   - seconds: The delay in seconds.
    ///   - effect: The effect to delay.
    /// - Returns: A delayed effect.
    public static func delay(
        _ seconds: TimeInterval,
        effect: Effect<Action>
    ) -> Effect {
        guard case .task(let work) = effect.kind else { return effect }
        
        return .task(id: effect.id) {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            return try await work()
        }
    }
    
    /// Creates a repeating timer effect.
    ///
    /// - Parameters:
    ///   - interval: The interval between ticks.
    ///   - id: Identifier for cancellation.
    ///   - action: Action to dispatch on each tick.
    /// - Returns: A timer effect.
    public static func timer(
        interval: TimeInterval,
        id: String,
        action: @escaping @autoclosure () -> Action
    ) -> Effect {
        .task(id: id) {
            while !Task.isCancelled {
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                return action()
            }
            return nil
        }
    }

    // MARK: - Transforms

    /// Maps the action type of this effect to a new type.
    ///
    /// - Parameter transform: A closure that converts the action.
    /// - Returns: A new effect with the transformed action type.
    public func map<NewAction>(_ transform: @escaping @Sendable (Action) -> NewAction) -> Effect<NewAction> {
        switch kind {
        case .none:
            return .none

        case .task(let work):
            return Effect<NewAction>.task(id: id) {
                guard let action = try await work() else { return nil }
                return transform(action)
            }

        case .combine(let effects):
            return .merge(effects.map { $0.map(transform) })

        case .cancel(let cancelId):
            return .cancel(id: cancelId)
            
        case .debounce(let inner, let duration, let debounceId):
            return Effect<NewAction>(
                kind: .debounce(inner.map(transform), duration: duration, id: debounceId)
            )
            
        case .throttle(let inner, let duration, let throttleId):
            return Effect<NewAction>(
                kind: .throttle(inner.map(transform), duration: duration, id: throttleId)
            )
        }
    }
    
    /// Transforms errors from the effect.
    ///
    /// - Parameter transform: Error transformation closure.
    /// - Returns: An effect with transformed errors.
    public func mapError(_ transform: @escaping @Sendable (Error) -> Action) -> Effect {
        guard case .task(let work) = kind else { return self }
        
        return .task(id: id) {
            do {
                return try await work()
            } catch {
                return transform(error)
            }
        }
    }
    
    /// Catches errors and returns a fallback action.
    ///
    /// - Parameter fallback: The action to return on error.
    /// - Returns: An effect that catches errors.
    public func `catch`(_ fallback: @escaping @autoclosure () -> Action) -> Effect {
        mapError { _ in fallback() }
    }

    /// Delays the effect execution by the specified duration.
    ///
    /// - Parameter seconds: The delay in seconds.
    /// - Returns: A delayed version of this effect.
    public func delay(_ seconds: TimeInterval) -> Effect {
        Effect.delay(seconds, effect: self)
    }
    
    /// Assigns a cancellation identifier to this effect.
    ///
    /// - Parameter id: The cancellation identifier.
    /// - Returns: The effect with the assigned identifier.
    public func cancellable(id: String) -> Effect {
        Effect(kind: kind, id: id)
    }
    
    // MARK: - Publisher Integration
    
    /// Creates an effect from a Combine publisher.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to convert.
    ///   - id: Optional cancellation identifier.
    /// - Returns: An effect that subscribes to the publisher.
    public static func publisher<P: Publisher>(
        _ publisher: P,
        id: String? = nil
    ) -> Effect where P.Output == Action, P.Failure == Never {
        .task(id: id) {
            await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher
                    .first()
                    .sink { action in
                        continuation.resume(returning: action)
                        _ = cancellable
                    }
            }
        }
    }
    
    /// Creates an effect from a Combine publisher that can fail.
    ///
    /// - Parameters:
    ///   - publisher: The publisher to convert.
    ///   - id: Optional cancellation identifier.
    ///   - mapError: Closure to convert errors to actions.
    /// - Returns: An effect that subscribes to the publisher.
    public static func publisher<P: Publisher>(
        _ publisher: P,
        id: String? = nil,
        mapError: @escaping (P.Failure) -> Action
    ) -> Effect where P.Output == Action {
        .task(id: id) {
            await withCheckedContinuation { continuation in
                var cancellable: AnyCancellable?
                cancellable = publisher
                    .first()
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(returning: mapError(error))
                            }
                            _ = cancellable
                        },
                        receiveValue: { action in
                            continuation.resume(returning: action)
                        }
                    )
            }
        }
    }
    
    // MARK: - Async Sequence
    
    /// Creates an effect that processes an async sequence.
    ///
    /// - Parameters:
    ///   - sequence: The async sequence to process.
    ///   - id: Optional cancellation identifier.
    ///   - transform: Transform each element to an action.
    /// - Returns: An effect that processes the sequence.
    public static func stream<S: AsyncSequence>(
        _ sequence: S,
        id: String? = nil,
        transform: @escaping @Sendable (S.Element) async -> Action?
    ) -> Effect where S: Sendable, S.Element: Sendable {
        .task(id: id) {
            for try await element in sequence {
                if let action = await transform(element) {
                    return action
                }
            }
            return nil
        }
    }
}

// MARK: - Effect Builder

/// Result builder for composing effects declaratively.
@resultBuilder
public struct EffectBuilder<Action> {
    public static func buildBlock(_ effects: Effect<Action>...) -> Effect<Action> {
        .merge(effects)
    }
    
    public static func buildOptional(_ effect: Effect<Action>?) -> Effect<Action> {
        effect ?? .none
    }
    
    public static func buildEither(first effect: Effect<Action>) -> Effect<Action> {
        effect
    }
    
    public static func buildEither(second effect: Effect<Action>) -> Effect<Action> {
        effect
    }
    
    public static func buildArray(_ effects: [Effect<Action>]) -> Effect<Action> {
        .merge(effects)
    }
    
    public static func buildExpression(_ effect: Effect<Action>) -> Effect<Action> {
        effect
    }
    
    public static func buildExpression(_ action: Action) -> Effect<Action> {
        .send(action)
    }
}

// MARK: - Effect Extension

extension Effect {
    /// Creates merged effects using a result builder.
    public static func build(
        @EffectBuilder<Action> _ builder: () -> Effect<Action>
    ) -> Effect<Action> {
        builder()
    }
}
