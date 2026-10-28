import os

/// A problem the store noticed while running your feature: a programming mistake rather than an
/// error the user can see.
///
/// A ``Store`` hands each issue to the handler you pass to its initializer. Without one, the
/// issue is written to the unified log as a fault. A ``StoreIssue`` never holds the values of your
/// state, actions or errors, only their type names, so passing it to a log or analytics service
/// does not leak user data.
public struct StoreIssue: Sendable, Equatable, CustomStringConvertible {
    /// What went wrong.
    public enum Kind: Sendable, Equatable {
        /// An effect operation threw an error and the effect has no `catch` handler.
        /// `errorType` is the error's type name.
        case unhandledEffectError(errorType: String)
        /// One call to `send` led to more than `limit` actions sent with ``Effect/send(_:)``
        /// before it returned, which almost always means two actions send each other forever.
        /// The store dropped the remaining actions.
        case synchronousActionLimitExceeded(limit: Int)
    }

    /// What went wrong.
    public let kind: Kind
    /// The type name of the action that was being processed, such as `Counter.Action`.
    public let actionType: String

    /// Creates an issue. The store creates issues; create one yourself only in tests.
    public init(kind: Kind, actionType: String) {
        self.kind = kind
        self.actionType = actionType
    }

    public var description: String {
        switch kind {
        case .unhandledEffectError(let errorType):
            "An effect started for \(actionType) threw \(errorType) and has no catch handler. "
                + "Pass catch: to Effect.run to turn the error into an action."
        case .synchronousActionLimitExceeded(let limit):
            "Processing one \(actionType) sent more than \(limit) actions with Effect.send; "
                + "the remaining actions were dropped. Check for actions that send each other."
        }
    }

    static func typeName(of value: Any) -> String {
        typeName(type(of: value))
    }

    /// The qualified name of `type`. Swift names a type declared inside a function
    /// `(unknown context at $<address>)`; the address is replaced, so it never reaches a log.
    static func typeName(_ type: Any.Type) -> String {
        removingAddresses(from: String(reflecting: type))
    }

    static func removingAddresses(from text: String) -> String {
        text.replacing(/\(unknown context at \$[0-9a-fA-F]+\)/, with: "(unknown context)")
    }

    /// The line ``logToUnifiedLog(_:)`` writes; it is public in the log, so it holds no address.
    static func logMessage(for issue: StoreIssue) -> String {
        removingAddresses(from: issue.description)
    }

    /// Writes `issue` to the unified log as a fault, under the subsystem `SwiftUIStateManagement`
    /// and the category `Store`. This is what a store does when you pass no `onIssue` handler.
    @MainActor
    public static func logToUnifiedLog(_ issue: StoreIssue) {
        logger.fault("\(logMessage(for: issue), privacy: .public)")
    }

    private static let logger = Logger(subsystem: "SwiftUIStateManagement", category: "Store")
}
