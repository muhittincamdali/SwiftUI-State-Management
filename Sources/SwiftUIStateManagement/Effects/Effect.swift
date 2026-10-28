/// Work that a reducer asks the store to start after it has changed the state.
///
/// A reducer cannot `await`. When an action needs asynchronous work, such as loading data, the
/// reducer returns an effect; the store runs it on the main actor and feeds the actions it sends
/// back into the reducer.
///
/// ```swift
/// case .refreshTapped:
///     state.isLoading = true
///     return .run(id: CancelID.load, cancelInFlight: true) { [api] send in
///         let items = try await api.items()
///         send(.itemsLoaded(items))
///     } catch: { error, send in
///         send(.loadFailed)
///     }
/// ```
///
/// - ``none``: nothing to do.
/// - ``send(_:)``: process another action right away, before the store's `send` returns.
/// - ``run(priority:operation:catch:)`` and ``run(id:cancelInFlight:priority:operation:catch:)``:
///   start an asynchronous operation.
/// - ``cancel(id:)``: cancel the operations started with an identifier.
/// - ``merge(_:)-(Effect...)``: run several effects.
public struct Effect<Action> {
    struct Run {
        let id: AnyHashable?
        let cancelInFlight: Bool
        let priority: TaskPriority?
        let operation: @MainActor @Sendable (Send<Action>) async throws -> Void
        let onError: (@MainActor @Sendable (any Error, Send<Action>) -> Void)?
    }

    enum Operation {
        case send(Action)
        case run(Run)
        case cancel(AnyHashable)
    }

    let operations: [Operation]

    init(operations: [Operation]) {
        self.operations = operations
    }

    /// An effect that does nothing.
    public static var none: Effect {
        Effect(operations: [])
    }

    /// An effect that sends `action` to the store immediately, before `send` returns.
    ///
    /// Prefer calling shared logic directly in the reducer. Use this effect when the action must
    /// go through the whole reducer again, for example to let a parent feature see it.
    public static func send(_ action: Action) -> Effect {
        Effect(operations: [.send(action)])
    }

    /// An effect that runs `operation` in a new task on the main actor.
    ///
    /// Call `send` inside `operation` to feed results back to the reducer. After the task is
    /// cancelled, `send` ignores the actions it is given, so a cancelled request cannot
    /// overwrite newer state.
    ///
    /// - Parameters:
    ///   - priority: The priority of the task.
    ///   - operation: The work to do.
    ///   - handler: Called with an error that `operation` throws, other than a
    ///     `CancellationError` or any error thrown after the task was cancelled. Without a
    ///     handler, the store reports the error as a ``StoreIssue``.
    public static func run(
        priority: TaskPriority? = nil,
        operation: @escaping @MainActor @Sendable (_ send: Send<Action>) async throws -> Void,
        catch handler: (@MainActor @Sendable (_ error: any Error, _ send: Send<Action>) -> Void)? = nil
    ) -> Effect {
        Effect(operations: [.run(Run(
            id: nil,
            cancelInFlight: false,
            priority: priority,
            operation: operation,
            onError: handler
        ))])
    }

    /// An effect that runs `operation` in a new task and labels it with `id`, so that
    /// ``cancel(id:)`` or a later run with the same identifier can cancel it.
    ///
    /// With `cancelInFlight` set to `true`, the store first cancels every running operation
    /// with the same identifier. That is how a search keeps only the latest query alive:
    ///
    /// ```swift
    /// case .queryChanged(let query):
    ///     state.query = query
    ///     return .run(id: CancelID.search, cancelInFlight: true) { [clock, api] send in
    ///         try await clock.sleep(for: .milliseconds(300))
    ///         send(.resultsLoaded(try await api.search(query)))
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - id: Any hashable value; an enum case is a common choice.
    ///   - cancelInFlight: Whether to cancel running operations with the same `id` first.
    ///   - priority: The priority of the task.
    ///   - operation: The work to do.
    ///   - handler: Called with an error that `operation` throws; see
    ///     ``run(priority:operation:catch:)``.
    public static func run(
        id: some Hashable & Sendable,
        cancelInFlight: Bool = false,
        priority: TaskPriority? = nil,
        operation: @escaping @MainActor @Sendable (_ send: Send<Action>) async throws -> Void,
        catch handler: (@MainActor @Sendable (_ error: any Error, _ send: Send<Action>) -> Void)? = nil
    ) -> Effect {
        Effect(operations: [.run(Run(
            id: AnyHashable(id),
            cancelInFlight: cancelInFlight,
            priority: priority,
            operation: operation,
            onError: handler
        ))])
    }

    /// An effect that cancels every running operation started with `id`.
    ///
    /// Cancelling an identifier with nothing running does nothing.
    public static func cancel(id: some Hashable & Sendable) -> Effect {
        Effect(operations: [.cancel(AnyHashable(id))])
    }

    /// An effect that runs all of `effects`, in order for the immediate parts (``send(_:)`` and
    /// ``cancel(id:)``) and concurrently for the operations.
    public static func merge(_ effects: Effect...) -> Effect {
        merge(effects)
    }

    /// An effect that runs all of `effects`; see ``merge(_:)-(Effect...)``.
    public static func merge(_ effects: [Effect]) -> Effect {
        Effect(operations: effects.flatMap(\.operations))
    }

    /// Returns an effect that runs this effect and then `other`.
    public func merge(with other: Effect) -> Effect {
        Effect(operations: operations + other.operations)
    }

    /// Returns an effect that wraps every action this effect sends with `transform`.
    ///
    /// A parent feature uses it to turn a child's effects into its own actions, usually with an
    /// enum case: `childEffect.map(AppAction.settings)`.
    @MainActor
    public func map<NewAction>(
        _ transform: @escaping @MainActor @Sendable (Action) -> NewAction
    ) -> Effect<NewAction> {
        Effect<NewAction>(operations: operations.map { operation in
            switch operation {
            case .send(let action):
                return .send(transform(action))
            case .cancel(let id):
                return .cancel(id)
            case .run(let run):
                let operation = run.operation
                var mappedOnError: (@MainActor @Sendable (any Error, Send<NewAction>) -> Void)?
                if let onError = run.onError {
                    mappedOnError = { error, send in onError(error, send.map(transform)) }
                }
                return .run(Effect<NewAction>.Run(
                    id: run.id,
                    cancelInFlight: run.cancelInFlight,
                    priority: run.priority,
                    operation: { send in try await operation(send.map(transform)) },
                    onError: mappedOnError
                ))
            }
        })
    }
}

/// Sends actions from an effect back to the store.
///
/// The store creates one for each ``Effect/run(priority:operation:catch:)``. Call it like a
/// function: `send(.loaded(items))`. Once the effect's task is cancelled, calls are ignored.
@MainActor
public struct Send<Action>: Sendable {
    private let deliver: @MainActor @Sendable (Action) -> Void

    /// Creates a `Send` that passes actions to `deliver`. The store and test store create these;
    /// create one yourself only to call an effect's operation directly in a test.
    public init(_ deliver: @escaping @MainActor @Sendable (Action) -> Void) {
        self.deliver = deliver
    }

    /// Sends `action` to the store unless the current task is cancelled.
    public func callAsFunction(_ action: Action) {
        guard !Task.isCancelled else { return }
        deliver(action)
    }

    func map<Child>(_ transform: @escaping @MainActor @Sendable (Child) -> Action) -> Send<Child> {
        let deliver = self.deliver
        return Send<Child> { action in deliver(transform(action)) }
    }
}
