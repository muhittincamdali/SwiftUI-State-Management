import Foundation

/// Names a value that is saved to a ``StateStorage``, with the format version and the size
/// limit that apply to it.
///
/// ```swift
/// extension PersistenceKey where Value == Settings {
///     static let settings = PersistenceKey("settings", version: 1)
/// }
///
/// let saved = try storage.load(.settings)    // Settings?, nil when nothing is saved
/// try storage.save(settings, for: .settings)
/// ```
///
/// The value is stored as JSON in an envelope that records `version`. When you change `Value` in
/// a way that old data no longer decodes, raise `version` and pass `migrate` to convert the old
/// data, or leave `migrate` out to treat the old data as a mismatch.
public struct PersistenceKey<Value: Codable & Sendable>: Sendable {
    /// The name under which the value is stored: 1 to 128 ASCII letters, digits, `.`, `_` or
    /// `-`, not starting with `.`.
    public let name: String
    /// The format version written with the value.
    public let version: Int
    /// The largest encoded size, in bytes, that ``StateStorage/load(_:)`` reads and
    /// ``StateStorage/save(_:for:)`` writes. Must be greater than zero.
    public let maxBytes: Int
    /// Converts data saved with an older `version` into a value: receives the old version and
    /// the JSON of the old value.
    public let migrate: (@Sendable (_ storedVersion: Int, _ json: Data) throws -> Value)?

    /// The default for ``maxBytes``: 1 MiB.
    public static var defaultMaxBytes: Int { 1_048_576 }

    /// Creates a key.
    ///
    /// The name and limit are checked when the key is used, so an invalid key makes `load` and
    /// `save` throw ``PersistenceError/invalidKey(_:)`` instead of stopping the app.
    public init(
        _ name: String,
        version: Int = 1,
        maxBytes: Int = defaultMaxBytes,
        migrate: (@Sendable (_ storedVersion: Int, _ json: Data) throws -> Value)? = nil
    ) {
        self.name = name
        self.version = version
        self.maxBytes = maxBytes
        self.migrate = migrate
    }

    /// Throws ``PersistenceError/invalidKey(_:)`` when the name or the limit is not valid.
    func validate() throws {
        guard Self.isValidName(name) else {
            throw PersistenceError.invalidKey("The name must be 1 to 128 characters from A-Z, a-z, 0-9, '.', '_' and '-', not starting with '.'.")
        }
        guard maxBytes > 0 else {
            throw PersistenceError.invalidKey("maxBytes must be greater than zero.")
        }
    }

    static func isValidName(_ name: String) -> Bool {
        let bytes = Array(name.utf8)
        guard (1...128).contains(bytes.count), bytes.first != UInt8(ascii: ".") else { return false }
        return bytes.allSatisfy { byte in
            switch byte {
            case UInt8(ascii: "a")...UInt8(ascii: "z"),
                 UInt8(ascii: "A")...UInt8(ascii: "Z"),
                 UInt8(ascii: "0")...UInt8(ascii: "9"),
                 UInt8(ascii: "."), UInt8(ascii: "_"), UInt8(ascii: "-"):
                true
            default:
                false
            }
        }
    }
}

/// An error from loading or saving a persisted value.
public enum PersistenceError: Error, Equatable, Sendable {
    /// The key's name or limit is not valid; the string says why.
    case invalidKey(String)
    /// The stored or encoded value is larger than the key's ``PersistenceKey/maxBytes``.
    case tooLarge(byteCount: Int, limit: Int)
    /// The stored data was written with another version and the key has no `migrate` closure.
    case versionMismatch(stored: Int, expected: Int)
    /// The stored data is not a valid envelope or does not decode as the value's type.
    case corrupted
}
