import Foundation

// MARK: - StateLogger

/// A middleware that logs every dispatched action and the resulting state
/// to the console. Useful during development for understanding state flow.
///
/// Usage:
/// ```swift
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer,
///     middleware: [AnyMiddleware(StateLogger<AppState, AppAction>())]
/// )
/// ```
public struct StateLogger<State, Action>: MiddlewareProtocol {

    // MARK: - Configuration

    /// Whether to include state snapshots in the log output.
    public let includeState: Bool

    /// Optional label prefix for log messages.
    public let label: String

    /// Custom log handler. Defaults to `print`.
    private let logHandler: (String) -> Void

    // MARK: - Initialization

    /// Creates a state logger middleware.
    ///
    /// - Parameters:
    ///   - label: A prefix for log lines (default: "Store").
    ///   - includeState: Whether to dump the state (default: true).
    ///   - logHandler: Custom log function (default: print).
    public init(
        label: String = "Store",
        includeState: Bool = true,
        logHandler: @escaping (String) -> Void = { print($0) }
    ) {
        self.label = label
        self.includeState = includeState
        self.logHandler = logHandler
    }

    // MARK: - MiddlewareProtocol

    public func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        let timestamp = Self.formattedTimestamp()
        let actionDescription = String(describing: action)

        var output = "[\(label)] \(timestamp) → \(actionDescription)"

        if includeState {
            output += "\n  State: \(String(describing: state))"
        }

        logHandler(output)
        next(action)
    }

    // MARK: - Helpers

    private static func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
