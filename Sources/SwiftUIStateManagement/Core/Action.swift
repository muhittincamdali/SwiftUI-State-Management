import Foundation

// MARK: - ActionProtocol

/// A protocol that all actions should conform to for enhanced debugging
/// and logging capabilities.
///
/// While not strictly required (the Store works with any type),
/// conforming to `ActionProtocol` enables richer dev tools output.
public protocol ActionProtocol {
    /// A human-readable description of the action for logging purposes.
    var debugDescription: String { get }
}

// MARK: - Default Implementation

extension ActionProtocol {
    /// Default implementation uses reflection to provide a description.
    public var debugDescription: String {
        String(describing: self)
    }
}

// MARK: - IdentifiableAction

/// An action that carries an identifier, useful for effect cancellation
/// and tracking purposes.
public protocol IdentifiableAction: ActionProtocol {
    /// A unique identifier for this action instance.
    var actionID: String { get }
}

extension IdentifiableAction {
    public var actionID: String {
        UUID().uuidString
    }
}

// MARK: - BindingAction

/// A convenience action type for two-way binding updates from SwiftUI views.
///
/// Usage:
/// ```swift
/// case binding(BindingAction<State>)
/// ```
public struct BindingAction<Root> {
    /// The key path being updated.
    public let keyPath: PartialKeyPath<Root>

    /// The new value to set (type-erased).
    let valueErased: Any

    /// Creates a binding action for a specific key path and value.
    public static func set<Value>(
        _ keyPath: WritableKeyPath<Root, Value>,
        _ value: Value
    ) -> BindingAction<Root> {
        BindingAction(keyPath: keyPath, valueErased: value)
    }

    /// Applies the binding to the given root, mutating the value at the key path.
    public func apply(to root: inout Root) {
        guard let kp = keyPath as? WritableKeyPath<Root, Any> else { return }
        root[keyPath: kp] = valueErased
    }
}
