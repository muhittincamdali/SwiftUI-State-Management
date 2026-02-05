import Foundation

// MARK: - State Diff

/// Represents a difference between two states.
/// Provides detailed comparison for debugging state changes.
public struct StateDiff: CustomStringConvertible, Sendable {
    
    /// The type of change detected.
    public enum ChangeType: String, Sendable {
        case added = "+"
        case removed = "-"
        case modified = "~"
        case unchanged = "="
    }
    
    /// A single property change.
    public struct PropertyChange: Identifiable, Sendable {
        public let id = UUID()
        public let keyPath: String
        public let changeType: ChangeType
        public let oldValue: String?
        public let newValue: String?
        public let depth: Int
        
        public var formattedChange: String {
            switch changeType {
            case .added:
                return "\(changeType.rawValue) \(keyPath): \(newValue ?? "nil")"
            case .removed:
                return "\(changeType.rawValue) \(keyPath): \(oldValue ?? "nil")"
            case .modified:
                return "\(changeType.rawValue) \(keyPath): \(oldValue ?? "nil") → \(newValue ?? "nil")"
            case .unchanged:
                return "\(changeType.rawValue) \(keyPath): \(newValue ?? "nil")"
            }
        }
    }
    
    /// All property changes detected.
    public let changes: [PropertyChange]
    
    /// Whether any changes were detected.
    public var hasChanges: Bool {
        !changes.isEmpty && changes.contains { $0.changeType != .unchanged }
    }
    
    /// Number of modified properties.
    public var modifiedCount: Int {
        changes.filter { $0.changeType == .modified }.count
    }
    
    /// Number of added properties.
    public var addedCount: Int {
        changes.filter { $0.changeType == .added }.count
    }
    
    /// Number of removed properties.
    public var removedCount: Int {
        changes.filter { $0.changeType == .removed }.count
    }
    
    public var description: String {
        guard hasChanges else { return "No changes" }
        
        return changes
            .filter { $0.changeType != .unchanged }
            .map { change in
                let indent = String(repeating: "  ", count: change.depth)
                return "\(indent)\(change.formattedChange)"
            }
            .joined(separator: "\n")
    }
    
    /// Creates a diff summary string.
    public var summary: String {
        guard hasChanges else { return "No changes" }
        
        var parts: [String] = []
        if addedCount > 0 { parts.append("+\(addedCount)") }
        if removedCount > 0 { parts.append("-\(removedCount)") }
        if modifiedCount > 0 { parts.append("~\(modifiedCount)") }
        
        return parts.joined(separator: " ")
    }
}

// MARK: - State Differ

/// Configuration for state diffing behavior.
public struct DiffConfiguration: Sendable {
    /// Maximum depth to traverse nested types.
    public var maxDepth: Int = 10
    
    /// Whether to include unchanged properties in the diff.
    public var includeUnchanged: Bool = false
    
    /// Property names to exclude from diffing.
    public var excludedProperties: Set<String> = []
    
    public static let `default` = DiffConfiguration()
    
    public static let verbose = DiffConfiguration(
        maxDepth: 20,
        includeUnchanged: true
    )
    
    public init(
        maxDepth: Int = 10,
        includeUnchanged: Bool = false,
        excludedProperties: Set<String> = []
    ) {
        self.maxDepth = maxDepth
        self.includeUnchanged = includeUnchanged
        self.excludedProperties = excludedProperties
    }
}

/// Computes diffs between state values using reflection.
public struct StateDiffer<State> {
    
    /// Configuration type alias for backwards compatibility.
    public typealias Configuration = DiffConfiguration
    
    private let configuration: Configuration
    
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    /// Computes the diff between two states.
    ///
    /// - Parameters:
    ///   - oldState: The previous state.
    ///   - newState: The current state.
    /// - Returns: A StateDiff describing all changes.
    public func diff(from oldState: State, to newState: State) -> StateDiff {
        var changes: [StateDiff.PropertyChange] = []
        diffValue(
            label: "root",
            old: oldState,
            new: newState,
            depth: 0,
            changes: &changes
        )
        return StateDiff(changes: changes)
    }
    
    private func diffValue(
        label: String,
        old: Any,
        new: Any,
        depth: Int,
        changes: inout [StateDiff.PropertyChange]
    ) {
        guard depth < configuration.maxDepth else { return }
        guard !configuration.excludedProperties.contains(label) else { return }
        
        let oldMirror = Mirror(reflecting: old)
        let newMirror = Mirror(reflecting: new)
        
        // Handle simple types
        if oldMirror.children.isEmpty && newMirror.children.isEmpty {
            let oldStr = String(describing: old)
            let newStr = String(describing: new)
            
            if oldStr != newStr {
                changes.append(StateDiff.PropertyChange(
                    keyPath: label,
                    changeType: .modified,
                    oldValue: oldStr,
                    newValue: newStr,
                    depth: depth
                ))
            } else if configuration.includeUnchanged {
                changes.append(StateDiff.PropertyChange(
                    keyPath: label,
                    changeType: .unchanged,
                    oldValue: oldStr,
                    newValue: newStr,
                    depth: depth
                ))
            }
            return
        }
        
        // Handle collections
        if let oldArray = old as? [Any], let newArray = new as? [Any] {
            diffArrays(label: label, old: oldArray, new: newArray, depth: depth, changes: &changes)
            return
        }
        
        // Handle dictionaries
        if let oldDict = old as? [AnyHashable: Any], let newDict = new as? [AnyHashable: Any] {
            diffDictionaries(label: label, old: oldDict, new: newDict, depth: depth, changes: &changes)
            return
        }
        
        // Handle optionals
        if let oldOptional = unwrapOptional(old), let newOptional = unwrapOptional(new) {
            switch (oldOptional, newOptional) {
            case (.none, .none):
                if configuration.includeUnchanged {
                    changes.append(StateDiff.PropertyChange(
                        keyPath: label,
                        changeType: .unchanged,
                        oldValue: "nil",
                        newValue: "nil",
                        depth: depth
                    ))
                }
            case (.none, .some(let newVal)):
                changes.append(StateDiff.PropertyChange(
                    keyPath: label,
                    changeType: .added,
                    oldValue: nil,
                    newValue: String(describing: newVal),
                    depth: depth
                ))
            case (.some(let oldVal), .none):
                changes.append(StateDiff.PropertyChange(
                    keyPath: label,
                    changeType: .removed,
                    oldValue: String(describing: oldVal),
                    newValue: nil,
                    depth: depth
                ))
            case (.some(let oldVal), .some(let newVal)):
                diffValue(label: label, old: oldVal, new: newVal, depth: depth, changes: &changes)
            }
            return
        }
        
        // Handle complex types with children
        let oldChildren = Dictionary(uniqueKeysWithValues: oldMirror.children.compactMap { child -> (String, Any)? in
            guard let label = child.label else { return nil }
            return (label, child.value)
        })
        
        let newChildren = Dictionary(uniqueKeysWithValues: newMirror.children.compactMap { child -> (String, Any)? in
            guard let label = child.label else { return nil }
            return (label, child.value)
        })
        
        let allKeys = Set(oldChildren.keys).union(Set(newChildren.keys))
        
        for key in allKeys.sorted() {
            let childLabel = depth == 0 ? key : "\(label).\(key)"
            
            switch (oldChildren[key], newChildren[key]) {
            case (.none, .some(let newVal)):
                changes.append(StateDiff.PropertyChange(
                    keyPath: childLabel,
                    changeType: .added,
                    oldValue: nil,
                    newValue: String(describing: newVal),
                    depth: depth + 1
                ))
                
            case (.some(let oldVal), .none):
                changes.append(StateDiff.PropertyChange(
                    keyPath: childLabel,
                    changeType: .removed,
                    oldValue: String(describing: oldVal),
                    newValue: nil,
                    depth: depth + 1
                ))
                
            case (.some(let oldVal), .some(let newVal)):
                diffValue(
                    label: childLabel,
                    old: oldVal,
                    new: newVal,
                    depth: depth + 1,
                    changes: &changes
                )
                
            case (.none, .none):
                break
            }
        }
    }
    
    private func diffArrays(
        label: String,
        old: [Any],
        new: [Any],
        depth: Int,
        changes: inout [StateDiff.PropertyChange]
    ) {
        if old.count != new.count {
            changes.append(StateDiff.PropertyChange(
                keyPath: "\(label).count",
                changeType: .modified,
                oldValue: "\(old.count)",
                newValue: "\(new.count)",
                depth: depth
            ))
        }
        
        let maxCount = max(old.count, new.count)
        for i in 0..<maxCount {
            let indexLabel = "\(label)[\(i)]"
            
            switch (i < old.count, i < new.count) {
            case (true, true):
                diffValue(
                    label: indexLabel,
                    old: old[i],
                    new: new[i],
                    depth: depth + 1,
                    changes: &changes
                )
            case (false, true):
                changes.append(StateDiff.PropertyChange(
                    keyPath: indexLabel,
                    changeType: .added,
                    oldValue: nil,
                    newValue: String(describing: new[i]),
                    depth: depth + 1
                ))
            case (true, false):
                changes.append(StateDiff.PropertyChange(
                    keyPath: indexLabel,
                    changeType: .removed,
                    oldValue: String(describing: old[i]),
                    newValue: nil,
                    depth: depth + 1
                ))
            case (false, false):
                break
            }
        }
    }
    
    private func diffDictionaries(
        label: String,
        old: [AnyHashable: Any],
        new: [AnyHashable: Any],
        depth: Int,
        changes: inout [StateDiff.PropertyChange]
    ) {
        let allKeys = Set(old.keys).union(Set(new.keys))
        
        for key in allKeys {
            let keyLabel = "\(label)[\"\(key)\"]"
            
            switch (old[key], new[key]) {
            case (.none, .some(let newVal)):
                changes.append(StateDiff.PropertyChange(
                    keyPath: keyLabel,
                    changeType: .added,
                    oldValue: nil,
                    newValue: String(describing: newVal),
                    depth: depth + 1
                ))
            case (.some(let oldVal), .none):
                changes.append(StateDiff.PropertyChange(
                    keyPath: keyLabel,
                    changeType: .removed,
                    oldValue: String(describing: oldVal),
                    newValue: nil,
                    depth: depth + 1
                ))
            case (.some(let oldVal), .some(let newVal)):
                diffValue(
                    label: keyLabel,
                    old: oldVal,
                    new: newVal,
                    depth: depth + 1,
                    changes: &changes
                )
            case (.none, .none):
                break
            }
        }
    }
    
    private enum OptionalValue {
        case none
        case some(Any)
    }
    
    private func unwrapOptional(_ value: Any) -> OptionalValue? {
        let mirror = Mirror(reflecting: value)
        guard mirror.displayStyle == .optional else { return nil }
        
        if let (_, unwrapped) = mirror.children.first {
            return .some(unwrapped)
        }
        return .none
    }
}

// MARK: - Equatable State Diff

extension StateDiffer where State: Equatable {
    /// Quick check if states are different.
    public func hasChanges(from oldState: State, to newState: State) -> Bool {
        oldState != newState
    }
}

// MARK: - JSON Diff Export

extension StateDiff {
    /// Exports the diff as JSON for external tools.
    public func toJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let exportable = changes.map { change -> [String: Any?] in
            [
                "keyPath": change.keyPath,
                "changeType": change.changeType.rawValue,
                "oldValue": change.oldValue,
                "newValue": change.newValue,
                "depth": change.depth
            ]
        }
        
        return try? JSONSerialization.data(
            withJSONObject: exportable,
            options: [.prettyPrinted, .sortedKeys]
        )
    }
}
