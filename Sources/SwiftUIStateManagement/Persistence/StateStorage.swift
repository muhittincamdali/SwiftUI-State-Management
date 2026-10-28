import Foundation
import os

/// A place to save state between launches: files, user defaults, or memory in tests.
///
/// Conforming types store bytes under a name. ``load(_:)``, ``save(_:for:)`` and ``remove(_:)``
/// add the JSON envelope, the version check and the size limit of a ``PersistenceKey`` on top.
public protocol StateStorage: Sendable {
    /// Returns the bytes stored under `key`, or `nil` when there are none.
    ///
    /// - Throws: ``PersistenceError/tooLarge(byteCount:limit:)`` when more than `maxBytes` are
    ///   stored. Implementations should check the size before reading the bytes into memory.
    func data(forKey key: String, maxBytes: Int) throws -> Data?
    /// Stores `data` under `key`, replacing what was there.
    func setData(_ data: Data, forKey key: String) throws
    /// Removes what is stored under `key`. Does nothing when nothing is stored.
    func removeData(forKey key: String) throws
}

extension StateStorage {
    /// Loads the value saved for `key`.
    ///
    /// - Returns: The value, or `nil` when nothing is saved.
    /// - Throws: ``PersistenceError`` when the key is invalid, the saved data is larger than the
    ///   key's limit, was written with another version that the key cannot migrate, or does not
    ///   decode; or an error thrown by the key's `migrate` closure or by the storage.
    public func load<Value>(_ key: PersistenceKey<Value>) throws -> Value? {
        try key.validate()
        guard let data = try data(forKey: key.name, maxBytes: key.maxBytes) else { return nil }
        guard data.count <= key.maxBytes else {
            throw PersistenceError.tooLarge(byteCount: data.count, limit: key.maxBytes)
        }
        let storedVersion: Int
        do {
            storedVersion = try JSONDecoder().decode(EnvelopeHeader.self, from: data).version
        } catch {
            throw PersistenceError.corrupted
        }
        if storedVersion == key.version {
            do {
                return try JSONDecoder().decode(Envelope<Value>.self, from: data).value
            } catch {
                throw PersistenceError.corrupted
            }
        }
        guard let migrate = key.migrate else {
            throw PersistenceError.versionMismatch(stored: storedVersion, expected: key.version)
        }
        return try migrate(storedVersion, try Self.valueJSON(in: data))
    }

    /// Saves `value` for `key`, replacing the saved value.
    ///
    /// - Throws: ``PersistenceError/invalidKey(_:)``, ``PersistenceError/tooLarge(byteCount:limit:)``
    ///   when the encoded value is larger than the key's limit (nothing is written), an
    ///   `EncodingError`, or an error from the storage.
    public func save<Value>(_ value: Value, for key: PersistenceKey<Value>) throws {
        try key.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(Envelope(version: key.version, value: value))
        guard data.count <= key.maxBytes else {
            throw PersistenceError.tooLarge(byteCount: data.count, limit: key.maxBytes)
        }
        try setData(data, forKey: key.name)
    }

    /// Removes the value saved for `key`.
    public func remove<Value>(_ key: PersistenceKey<Value>) throws {
        try key.validate()
        try removeData(forKey: key.name)
    }

    /// The JSON of the `value` member of an envelope, for a `migrate` closure.
    private static func valueJSON(in data: Data) throws -> Data {
        guard
            let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]),
            let envelope = object as? [String: Any],
            let value = envelope["value"],
            let json = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
        else {
            throw PersistenceError.corrupted
        }
        return json
    }
}

struct Envelope<Value: Codable>: Codable {
    let version: Int
    let value: Value
}

private struct EnvelopeHeader: Decodable {
    let version: Int
}

/// Keeps values in memory, for tests and SwiftUI previews.
public final class InMemoryStorage: StateStorage {
    private let values = OSAllocatedUnfairLock(initialState: [String: Data]())

    /// Creates an empty storage.
    public init() {}

    public func data(forKey key: String, maxBytes: Int) throws -> Data? {
        guard let data = values.withLock({ $0[key] }) else { return nil }
        guard data.count <= maxBytes else {
            throw PersistenceError.tooLarge(byteCount: data.count, limit: maxBytes)
        }
        return data
    }

    public func setData(_ data: Data, forKey key: String) throws {
        values.withLock { $0[key] = data }
    }

    public func removeData(forKey key: String) throws {
        values.withLock { $0[key] = nil }
    }

    /// The names that hold a value.
    public var keys: Set<String> {
        values.withLock { Set($0.keys) }
    }
}

/// Stores values in `UserDefaults`, for small settings.
///
/// Each value is stored under `prefix` followed by the key's name. User defaults are read into
/// memory as a whole when the app starts, so keep values here small and use ``FileStorage`` for
/// lists and documents.
public struct UserDefaultsStorage: StateStorage {
    private let suiteName: String?
    /// Put in front of every key's name, so values do not collide with other defaults.
    public let prefix: String

    /// Creates a storage in the standard user defaults.
    public init(prefix: String = "state.") {
        self.suiteName = nil
        self.prefix = prefix
    }

    /// Creates a storage in the user defaults suite named `suiteName`, for example an app group
    /// shared with a widget. Returns `nil` when `UserDefaults` does not accept the name (the
    /// app's own bundle identifier and `NSGlobalDomain` are not accepted).
    public init?(suiteName: String, prefix: String = "state.") {
        guard UserDefaults(suiteName: suiteName) != nil else { return nil }
        self.suiteName = suiteName
        self.prefix = prefix
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    public func data(forKey key: String, maxBytes: Int) throws -> Data? {
        guard let data = defaults.data(forKey: prefix + key) else { return nil }
        guard data.count <= maxBytes else {
            throw PersistenceError.tooLarge(byteCount: data.count, limit: maxBytes)
        }
        return data
    }

    public func setData(_ data: Data, forKey key: String) throws {
        defaults.set(data, forKey: prefix + key)
    }

    public func removeData(forKey key: String) throws {
        defaults.removeObject(forKey: prefix + key)
    }
}
