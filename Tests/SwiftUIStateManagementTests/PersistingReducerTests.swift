import Foundation
import os
import Testing
@testable import SwiftUIStateManagement
import SwiftUIStateManagementTesting

struct WriteFailed: Error {}

/// A storage that counts writes and can be told to fail.
final class RecordingStorage: StateStorage {
    private let base = InMemoryStorage()
    private let state = OSAllocatedUnfairLock(initialState: (writes: 0, fails: false))

    var writeCount: Int { state.withLock { $0.writes } }

    func failWrites() {
        state.withLock { $0.fails = true }
    }

    func data(forKey key: String, maxBytes: Int) throws -> Data? {
        try base.data(forKey: key, maxBytes: maxBytes)
    }

    func setData(_ data: Data, forKey key: String) throws {
        let fails = state.withLock { state -> Bool in
            state.writes += 1
            return state.fails
        }
        if fails { throw WriteFailed() }
        try base.setData(data, forKey: key)
    }

    func removeData(forKey key: String) throws {
        try base.removeData(forKey: key)
    }
}

/// Polls `condition` on the main actor until it holds or a second has passed.
@MainActor
func eventually(_ condition: () -> Bool) async -> Bool {
    let deadline = ContinuousClock.now.advanced(by: .seconds(1))
    while !condition() {
        if ContinuousClock.now >= deadline { return false }
        try? await Task.sleep(for: .milliseconds(5))
    }
    return true
}

@Suite("Persisting reducer")
@MainActor
struct PersistingReducerTests {
    @Test("Each change is saved; actions that change nothing are not")
    func savesChanges() async throws {
        let storage = RecordingStorage()
        let store = makeSettingsStore(storage: storage)
        await store.send(.showsCompletedToggled(false)).finish()
        #expect(try storage.load(.settings)?.showsCompleted == false)
        await store.send(.showsCompletedToggled(false)).finish()
        #expect(storage.writeCount == 1)
    }

    @Test("A new store starts from the saved value")
    func restores() async throws {
        let storage = InMemoryStorage()
        await makeSettingsStore(storage: storage).send(.sortOrderChanged(.alphabetical)).finish()
        let reopened = makeSettingsStore(storage: storage)
        #expect(reopened.settings.sortOrder == .alphabetical)
    }

    @Test("With a debounce, a burst of changes is written once, after the quiet period")
    func debounce() async throws {
        let storage = RecordingStorage()
        let clock = TestClock()
        let store = Store(
            initialState: Todos.State(),
            reducer: Todos(makeID: UUID.init).persisting(\.items, to: .todos, in: storage, debounce: .seconds(1), clock: clock)
        )
        for title in ["a", "b", "c"] {
            store.send(.addTapped)
            store.send(.editorTitleChanged(title))
            store.send(.editorSaveTapped)
        }
        #expect(await clock.waitForSleepers(count: 1))
        clock.advance(by: .milliseconds(999))
        #expect(storage.writeCount == 0)
        clock.advance(by: .milliseconds(1))
        #expect(await eventually { storage.writeCount == 1 })
        #expect(try storage.load(.todos)?.map(\.title) == ["c", "b", "a"])
    }

    @Test("A flush action writes at once and replaces the pending debounced write")
    func flush() async throws {
        let storage = RecordingStorage()
        let clock = TestClock()
        let store = Store(
            initialState: Todos.State(),
            reducer: Todos(makeID: UUID.init).persisting(in: storage, clock: clock)
        )
        store.send(.addTapped)
        store.send(.editorTitleChanged("Buy milk"))
        store.send(.editorSaveTapped)
        await store.send(.movedToBackground).finish()
        #expect(try storage.load(.todos)?.map(\.title) == ["Buy milk"])
        #expect(clock.sleeperCount == 0)
    }

    @Test("A failed write becomes the onError action")
    func onError() async throws {
        let storage = RecordingStorage()
        storage.failWrites()
        let failures = Collected<String>()
        let reducer = Reduce<Int, String> { count, action in
            if action == "increment" { count += 1 } else { failures.append(action) }
            return .none
        }
        let store = Store(
            initialState: 0,
            reducer: reducer.persisting(\.self, to: PersistenceKey<Int>("count"), in: storage, onError: { _ in "save failed" })
        )
        await store.send("increment").finish()
        #expect(await eventually { failures.values == ["save failed"] })
    }

    @Test("Without onError, a failed write is reported as a store issue")
    func failureIssue() async throws {
        let storage = RecordingStorage()
        storage.failWrites()
        let issues = Collected<StoreIssue>()
        let store = Store(
            initialState: 0,
            reducer: Reduce<Int, Int> { count, add in count += add; return .none }
                .persisting(\.self, to: PersistenceKey<Int>("count"), in: storage),
            onIssue: { issues.append($0) }
        )
        await store.send(1).finish()
        #expect(issues.values.map(\.kind) == [.unhandledEffectError(errorType: String(reflecting: WriteFailed.self))])
    }

    @Test("An older value is never written after a newer one")
    func writesKeepTheirOrder() async throws {
        let storage = InMemoryStorage()
        let writer = PersistenceWriter(key: PersistenceKey<Int>("count"), storage: storage)
        try await writer.write(2, sequence: 2)
        try await writer.write(1, sequence: 1)
        #expect(try storage.load(PersistenceKey<Int>("count")) == 2)
    }

    @Test("A negative debounce is treated as no debounce")
    func negativeDebounce() async throws {
        let storage = InMemoryStorage()
        let store = Store(
            initialState: 0,
            reducer: Reduce<Int, Int> { count, add in count += add; return .none }
                .persisting(\.self, to: PersistenceKey<Int>("count"), in: storage, debounce: .seconds(-5))
        )
        await store.send(2).finish()
        #expect(try storage.load(PersistenceKey<Int>("count")) == 2)
    }
}
