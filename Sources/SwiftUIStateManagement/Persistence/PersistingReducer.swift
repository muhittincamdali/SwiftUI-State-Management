extension Reducer {
    /// Returns a reducer that saves the value at `keyPath` to `storage` whenever an action
    /// changes it.
    ///
    /// Load the saved value yourself when you create the store, and let this reducer write the
    /// changes:
    ///
    /// ```swift
    /// let storage = try FileStorage.applicationSupport()
    /// let saved = (try? storage.load(.todos)) ?? []
    /// let store = Store(
    ///     initialState: Todos.State(items: saved),
    ///     reducer: Todos().persisting(\.items, to: .todos, in: storage, debounce: .seconds(1))
    /// )
    /// ```
    ///
    /// Saving is an effect: it runs after the reducer, off the main actor, and never blocks the
    /// UI. With a `debounce`, a burst of changes is written once, after the value has stopped
    /// changing for that long. Writes for the same key never overtake each other: an older value
    /// is never written after a newer one.
    ///
    /// - Parameters:
    ///   - keyPath: The part of the state to save. Its value must be `Codable` and `Equatable`;
    ///     the reducer saves when the value after an action differs from the value before. `==`
    ///     must compare every property that is encoded: a change that `==` does not see, such as
    ///     a new title for an item that compares by `id` only, is not written.
    ///   - key: The name, version and size limit of the saved value.
    ///   - storage: Where to save.
    ///   - debounce: How long the value must stay unchanged before it is written. `.zero`
    ///     writes after every change.
    ///   - clock: The clock that measures `debounce`; pass a test clock in tests.
    ///   - flush: Returns `true` for actions after which the current value must be written at
    ///     once, cancelling a pending debounced write; for example the action your app sends when
    ///     its scene moves to the background.
    ///   - onError: Turns a failed write into an action. Without it the store reports a
    ///     ``StoreIssue``.
    public func persisting<Value: Codable & Equatable & Sendable>(
        _ keyPath: KeyPath<State, Value>,
        to key: PersistenceKey<Value>,
        in storage: some StateStorage,
        debounce: Duration = .zero,
        clock: some Clock<Duration> = ContinuousClock(),
        flush: ((Action) -> Bool)? = nil,
        onError: (@MainActor @Sendable (any Error) -> Action)? = nil
    ) -> PersistingReducer<Self, Value> {
        PersistingReducer(
            base: self,
            keyPath: keyPath,
            key: key,
            storage: storage,
            debounce: debounce,
            clock: clock,
            flush: flush,
            onError: onError
        )
    }
}

/// A reducer that saves part of its state after each change. Made by
/// ``Reducer/persisting(_:to:in:debounce:clock:flush:onError:)``.
public struct PersistingReducer<Base: Reducer, Value: Codable & Equatable & Sendable>: Reducer {
    let base: Base
    let keyPath: KeyPath<Base.State, Value>
    let key: PersistenceKey<Value>
    let debounce: Duration
    let clock: any Clock<Duration>
    let flush: ((Base.Action) -> Bool)?
    let onError: (@MainActor @Sendable (any Error) -> Base.Action)?
    private let writer: PersistenceWriter<Value>
    private let sequence = WriteSequence()

    init(
        base: Base,
        keyPath: KeyPath<Base.State, Value>,
        key: PersistenceKey<Value>,
        storage: some StateStorage,
        debounce: Duration,
        clock: some Clock<Duration>,
        flush: ((Base.Action) -> Bool)?,
        onError: (@MainActor @Sendable (any Error) -> Base.Action)?
    ) {
        self.base = base
        self.keyPath = keyPath
        self.key = key
        self.debounce = max(debounce, .zero)
        self.clock = clock
        self.flush = flush
        self.onError = onError
        self.writer = PersistenceWriter(key: key, storage: storage)
    }

    @MainActor
    public func reduce(into state: inout Base.State, action: Base.Action) -> Effect<Base.Action> {
        let before = state[keyPath: keyPath]
        let effect = base.reduce(into: &state, action: action)
        let after = state[keyPath: keyPath]
        let flushNow = flush?(action) ?? false
        guard flushNow || before != after else { return effect }
        return effect.merge(with: save(after, waiting: flushNow ? .zero : debounce))
    }

    @MainActor
    private func save(_ value: Value, waiting delay: Duration) -> Effect<Base.Action> {
        let number = sequence.next()
        let writer = self.writer
        let clock = self.clock
        // Without an onError handler, a failed write is an unhandled effect error, which the
        // store reports as a StoreIssue.
        var handler: (@MainActor @Sendable (any Error, Send<Base.Action>) -> Void)?
        if let onError {
            handler = { error, send in send(onError(error)) }
        }
        return .run(
            id: PersistenceEffectID(name: key.name),
            cancelInFlight: true,
            operation: { _ in
                if delay > .zero {
                    try await clock.sleep(for: delay)
                }
                try await writer.write(value, sequence: number)
            },
            catch: handler
        )
    }
}

/// Writes values for one key in the order of their sequence numbers, off the main actor. A
/// write that arrives after a newer one has started is skipped.
actor PersistenceWriter<Value: Codable & Sendable> {
    private let key: PersistenceKey<Value>
    private let storage: any StateStorage
    private var newestSequence: UInt64 = 0

    init(key: PersistenceKey<Value>, storage: some StateStorage) {
        self.key = key
        self.storage = storage
    }

    func write(_ value: Value, sequence: UInt64) throws {
        guard sequence > newestSequence else { return }
        newestSequence = sequence
        try storage.save(value, for: key)
    }
}

/// Numbers the saves of one persisting reducer, on the main actor.
@MainActor
final class WriteSequence {
    private var last: UInt64 = 0

    nonisolated init() {}

    func next() -> UInt64 {
        last &+= 1
        return last
    }
}

struct PersistenceEffectID: Hashable, Sendable {
    let name: String
}
