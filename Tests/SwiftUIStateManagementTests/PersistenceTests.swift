import Foundation
import Testing
@testable import SwiftUIStateManagement

/// A fresh directory for one test, removed when the value is deallocated.
final class TemporaryDirectory {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appending(path: "SwiftUIStateManagementTests-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}

private struct Note: Codable, Equatable, Sendable {
    var text: String
}

private struct NoteV1: Codable {
    var body: String
}

@Suite("Persistence")
struct PersistenceTests {
    private static let note = PersistenceKey<Note>("note")

    @Test("Saved values load back from every storage", arguments: [StorageKind.memory, .file, .userDefaults])
    func roundTrip(kind: StorageKind) throws {
        let directory = try TemporaryDirectory()
        let storage = try kind.make(in: directory)
        #expect(try storage.load(Self.note) == nil)
        try storage.save(Note(text: "hello"), for: Self.note)
        #expect(try storage.load(Self.note) == Note(text: "hello"))
        try storage.save(Note(text: "again"), for: Self.note)
        #expect(try storage.load(Self.note) == Note(text: "again"))
        try storage.remove(Self.note)
        #expect(try storage.load(Self.note) == nil)
        try storage.remove(Self.note)
    }

    @Test(
        "Names that could leave the directory or are not plain file names are rejected",
        arguments: ["", "../escape", "a/b", "a\\b", ".hidden", "..", "name\u{0}", "çay", String(repeating: "a", count: 129)]
    )
    func invalidNames(name: String) throws {
        let directory = try TemporaryDirectory()
        let storage = FileStorage(directory: directory.url)
        let key = PersistenceKey<Note>(name)
        #expect(throws: PersistenceError.self) { try storage.save(Note(text: "x"), for: key) }
        #expect(throws: PersistenceError.self) { try storage.load(key) }
        #expect(throws: PersistenceError.self) { try storage.setData(Data("x".utf8), forKey: name) }
        #expect(throws: PersistenceError.self) { try storage.data(forKey: name, maxBytes: 10) }
        let parent = directory.url.deletingLastPathComponent()
        #expect(!FileManager.default.fileExists(atPath: parent.appending(path: "escape.json").path))
    }

    @Test("Valid names include letters, digits, dots, dashes and underscores")
    func validNames() throws {
        let directory = try TemporaryDirectory()
        let storage = FileStorage(directory: directory.url)
        for name in ["a", "todo-path", "v2.settings", "A_B", String(repeating: "z", count: 128)] {
            try storage.save(Note(text: name), for: PersistenceKey(name))
            #expect(try storage.load(PersistenceKey<Note>(name)) == Note(text: name))
        }
    }

    @Test("A value larger than the limit is not written")
    func saveTooLarge() throws {
        let storage = InMemoryStorage()
        let key = PersistenceKey<Note>("note", maxBytes: 32)
        #expect(throws: PersistenceError.tooLarge(byteCount: 63, limit: 32)) {
            try storage.save(Note(text: String(repeating: "x", count: 30)), for: key)
        }
        #expect(storage.keys.isEmpty)
    }

    @Test("A stored file larger than the limit is refused before it is read")
    func loadTooLarge() throws {
        let directory = try TemporaryDirectory()
        let storage = FileStorage(directory: directory.url)
        try Data(repeating: 0x20, count: 10_000).write(to: directory.url.appending(path: "big.json"))
        #expect(throws: PersistenceError.tooLarge(byteCount: 10_000, limit: 100)) {
            try storage.load(PersistenceKey<Note>("big", maxBytes: 100))
        }
    }

    @Test("Limits at the edges of Int do not trap", arguments: [Int.max, 1])
    func extremeLimits(maxBytes: Int) throws {
        let directory = try TemporaryDirectory()
        let storage = FileStorage(directory: directory.url)
        try Data("{}".utf8).write(to: directory.url.appending(path: "edge.json"))
        if maxBytes == 1 {
            #expect(throws: PersistenceError.tooLarge(byteCount: 2, limit: 1)) {
                try storage.data(forKey: "edge", maxBytes: maxBytes)
            }
        } else {
            #expect(try storage.data(forKey: "edge", maxBytes: maxBytes) == Data("{}".utf8))
        }
    }

    @Test("A limit of zero or less is an invalid key", arguments: [0, -1, Int.min])
    func invalidLimits(maxBytes: Int) throws {
        let directory = try TemporaryDirectory()
        let key = PersistenceKey<Note>("note", maxBytes: maxBytes)
        #expect(throws: PersistenceError.self) { try InMemoryStorage().save(Note(text: ""), for: key) }
        #expect(throws: PersistenceError.self) { try FileStorage(directory: directory.url).data(forKey: "note", maxBytes: maxBytes) }
    }

    @Test("Data that is not an envelope, or does not decode, is reported as corrupted")
    func corrupted() throws {
        let storage = InMemoryStorage()
        for bytes in ["not json", "[]", #"{"version":"1"}"#, #"{"version":1,"value":{"other":1}}"#, ""] {
            try storage.setData(Data(bytes.utf8), forKey: "note")
            #expect(throws: PersistenceError.corrupted) { try storage.load(Self.note) }
        }
    }

    @Test("Data from another version is a mismatch without a migration")
    func versionMismatch() throws {
        let storage = InMemoryStorage()
        try storage.save(NoteV1(body: "old"), for: PersistenceKey("note", version: 1))
        #expect(throws: PersistenceError.versionMismatch(stored: 1, expected: 2)) {
            try storage.load(PersistenceKey<Note>("note", version: 2))
        }
    }

    @Test("A migration receives the old version and the old value's JSON")
    func migration() throws {
        let storage = InMemoryStorage()
        try storage.save(NoteV1(body: "old text"), for: PersistenceKey("note", version: 1))
        let key = PersistenceKey<Note>("note", version: 2) { version, json in
            #expect(version == 1)
            return Note(text: try JSONDecoder().decode(NoteV1.self, from: json).body)
        }
        #expect(try storage.load(key) == Note(text: "old text"))
    }

    @Test("The saved file is an envelope with the version and sorted keys")
    func fileFormat() throws {
        let directory = try TemporaryDirectory()
        try FileStorage(directory: directory.url).save(Note(text: "a"), for: PersistenceKey("note", version: 3))
        let text = try String(contentsOf: directory.url.appending(path: "note.json"), encoding: .utf8)
        #expect(text == #"{"value":{"text":"a"},"version":3}"#)
    }

    @Test("A suite name that UserDefaults refuses gives no storage")
    func refusedSuite() {
        #expect(UserDefaultsStorage(suiteName: "NSGlobalDomain") == nil)
    }
}

enum StorageKind: CustomTestStringConvertible, Sendable {
    case memory, file, userDefaults

    var testDescription: String {
        switch self {
        case .memory: "InMemoryStorage"
        case .file: "FileStorage"
        case .userDefaults: "UserDefaultsStorage"
        }
    }

    func make(in directory: TemporaryDirectory) throws -> any StateStorage {
        switch self {
        case .memory:
            InMemoryStorage()
        case .file:
            FileStorage(directory: directory.url)
        case .userDefaults:
            try #require(UserDefaultsStorage(suiteName: "SwiftUIStateManagementTests", prefix: "\(UUID().uuidString)."))
        }
    }
}
