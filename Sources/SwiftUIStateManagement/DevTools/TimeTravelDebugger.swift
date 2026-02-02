import Foundation
import Combine

// MARK: - TimeTravelDebugger

/// Records every state transition and allows stepping forward/backward
/// through state history. Invaluable for debugging complex state flows.
///
/// Usage:
/// ```swift
/// let debugger = TimeTravelDebugger(store: store)
/// debugger.stepBack()
/// debugger.stepForward()
/// ```
public final class TimeTravelDebugger<State, Action> {

    // MARK: - Entry

    /// A single recorded state transition.
    public struct Entry {
        /// The action that caused this state change.
        public let action: Action

        /// The resulting state after the action was processed.
        public let state: State

        /// When this entry was recorded.
        public let timestamp: Date
    }

    // MARK: - Properties

    /// The full history of state transitions.
    public private(set) var history: [Entry] = []

    /// The current position in the history timeline.
    public private(set) var currentIndex: Int = -1

    /// Maximum number of entries to keep (prevents unbounded memory growth).
    public let maxEntries: Int

    /// The store being observed.
    private weak var store: Store<State, Action>?

    /// Whether time travel is currently active (overriding live state).
    public private(set) var isTimeTraveling: Bool = false

    // MARK: - Initialization

    /// Creates a time travel debugger attached to a store.
    ///
    /// - Parameters:
    ///   - store: The store to observe.
    ///   - maxEntries: Maximum history size (default: 100).
    public init(store: Store<State, Action>, maxEntries: Int = 100) {
        self.store = store
        self.maxEntries = maxEntries

        store.onStateChange = { [weak self] state, action in
            self?.record(state: state, action: action)
        }
    }

    // MARK: - Recording

    /// Records a new state entry.
    private func record(state: State, action: Action) {
        guard !isTimeTraveling else { return }

        let entry = Entry(
            action: action,
            state: state,
            timestamp: Date()
        )

        // If we've stepped back and new actions come in, truncate future
        if currentIndex < history.count - 1 {
            history = Array(history.prefix(currentIndex + 1))
        }

        history.append(entry)
        currentIndex = history.count - 1

        // Trim if exceeding max
        if history.count > maxEntries {
            let overflow = history.count - maxEntries
            history.removeFirst(overflow)
            currentIndex -= overflow
        }
    }

    // MARK: - Navigation

    /// Steps one state back in history.
    /// - Returns: The previous state entry, or nil if at the beginning.
    @discardableResult
    public func stepBack() -> Entry? {
        guard currentIndex > 0 else { return nil }
        isTimeTraveling = true
        currentIndex -= 1
        return history[currentIndex]
    }

    /// Steps one state forward in history.
    /// - Returns: The next state entry, or nil if at the end.
    @discardableResult
    public func stepForward() -> Entry? {
        guard currentIndex < history.count - 1 else { return nil }
        currentIndex += 1
        let entry = history[currentIndex]

        if currentIndex == history.count - 1 {
            isTimeTraveling = false
        }

        return entry
    }

    /// Jumps to a specific index in the history.
    ///
    /// - Parameter index: The target history index.
    /// - Returns: The entry at the given index, or nil if out of bounds.
    @discardableResult
    public func jumpTo(index: Int) -> Entry? {
        guard index >= 0, index < history.count else { return nil }
        isTimeTraveling = index < history.count - 1
        currentIndex = index
        return history[currentIndex]
    }

    /// Resumes live mode, jumping to the latest state.
    public func resumeLive() {
        currentIndex = history.count - 1
        isTimeTraveling = false
    }

    /// Clears all recorded history.
    public func reset() {
        history.removeAll()
        currentIndex = -1
        isTimeTraveling = false
    }

    // MARK: - Inspection

    /// Returns the current entry in the timeline.
    public var currentEntry: Entry? {
        guard currentIndex >= 0, currentIndex < history.count else { return nil }
        return history[currentIndex]
    }

    /// The total number of recorded state transitions.
    public var entryCount: Int {
        history.count
    }
}
