import Foundation

// MARK: - Effect

/// Represents an asynchronous side effect that can optionally produce
/// an action to feed back into the store.
///
/// Effects are returned by reducers to handle async work like network
/// requests, timers, or persistence operations.
///
/// Usage:
/// ```swift
/// return Effect {
///     let data = try await api.fetchUser()
///     return .userLoaded(data)
/// }
/// ```
public struct Effect<Action> {

    // MARK: - Kind

    /// The underlying representation of the effect.
    enum Kind {
        /// No side effect.
        case none

        /// An async task that may produce an action.
        case task(() async throws -> Action?)

        /// Multiple effects combined together.
        case combine([Effect<Action>])

        /// Cancel a previously started effect by identifier.
        case cancel(String)
    }

    /// The kind of this effect.
    let kind: Kind

    // MARK: - Factories

    /// An effect that does nothing.
    public static var none: Effect {
        Effect(kind: .none)
    }

    /// Creates an effect from an async closure that produces an action.
    ///
    /// - Parameter work: The async work to perform.
    /// - Returns: An effect wrapping the async task.
    public init(_ work: @escaping () async throws -> Action?) {
        self.kind = .task(work)
    }

    /// Creates an effect that performs work without producing an action.
    ///
    /// - Parameter work: The async work to perform (fire-and-forget).
    /// - Returns: An effect that runs the work.
    public static func fireAndForget(_ work: @escaping () async throws -> Void) -> Effect {
        Effect {
            try await work()
            return nil
        }
    }

    /// Creates an effect that immediately produces an action synchronously.
    ///
    /// - Parameter action: The action to dispatch.
    /// - Returns: An effect that returns the action immediately.
    public static func just(_ action: Action) -> Effect {
        Effect { action }
    }

    /// Merges multiple effects into a single combined effect.
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

    /// Creates a cancellation effect for the given identifier.
    ///
    /// - Parameter id: The effect identifier to cancel.
    /// - Returns: A cancellation effect.
    public static func cancel(id: String) -> Effect {
        Effect(kind: .cancel(id))
    }

    // MARK: - Transforms

    /// Maps the action type of this effect to a new type.
    ///
    /// - Parameter transform: A closure that converts the action.
    /// - Returns: A new effect with the transformed action type.
    public func map<NewAction>(_ transform: @escaping (Action) -> NewAction) -> Effect<NewAction> {
        switch kind {
        case .none:
            return .none

        case .task(let work):
            return Effect<NewAction> {
                guard let action = try await work() else { return nil }
                return transform(action)
            }

        case .combine(let effects):
            return .merge(effects.map { $0.map(transform) })

        case .cancel(let id):
            return .cancel(id: id)
        }
    }

    /// Delays the effect execution by the specified duration.
    ///
    /// - Parameter nanoseconds: The delay in nanoseconds.
    /// - Returns: A delayed version of this effect.
    public func delay(nanoseconds: UInt64) -> Effect {
        switch kind {
        case .none:
            return .none

        case .task(let work):
            return Effect {
                try await Task.sleep(nanoseconds: nanoseconds)
                return try await work()
            }

        default:
            return self
        }
    }
}
