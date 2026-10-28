import Foundation
import Testing
import SwiftUIStateManagement
import SwiftUIStateManagementTesting

/// Tests the README samples in ReadmeSamples.swift; the README quotes some of these tests.
@Suite("README samples")
@MainActor
struct ReadmeSamplesTests {
    @Test("Counter: counting and loading a fact")
    func counter() async {
        let store = TestStore(
            initialState: Counter.State(),
            reducer: Counter(facts: NumberFacts { "\($0) is a good number." })
        )
        await store.send(.incrementTapped) { $0.count = 1 }
        await store.send(.factTapped) { $0.isLoadingFact = true }
        await store.receive(.factLoaded("1 is a good number.")) {
            $0.isLoadingFact = false
            $0.fact = "1 is a good number."
        }
    }

    @Test("Counter: a failing service ends the loading state")
    func counterFailure() async {
        struct Offline: Error {}
        let store = TestStore(
            initialState: Counter.State(),
            reducer: Counter(facts: NumberFacts { _ in throw Offline() })
        )
        await store.send(.factTapped) { $0.isLoadingFact = true }
        await store.receive(.factFailed) {
            $0.isLoadingFact = false
            $0.fact = "No fact this time."
        }
    }

    @Test("Search: only the last query of a burst is searched")
    func searchDebounces() async {
        let clock = TestClock()
        let searched = Collected<String>()
        let store = TestStore(
            initialState: Search.State(),
            reducer: Search(
                search: { query in
                    searched.append(query)
                    return ["\(query) result"]
                },
                clock: clock
            )
        )
        await store.send(.queryChanged("s")) {
            $0.query = "s"
            $0.isSearching = true
        }
        await store.send(.queryChanged("sw")) { $0.query = "sw" }
        await clock.waitForSleepers()
        clock.advance(by: .milliseconds(300))
        await store.receive(.resultsLoaded(["sw result"])) {
            $0.isSearching = false
            $0.results = ["sw result"]
        }
        #expect(searched.values == ["sw"])
    }

    @Test("Search: clearing the query cancels the pending search")
    func searchCancels() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: Search.State(),
            reducer: Search(search: { _ in ["never"] }, clock: clock)
        )
        await store.send(.queryChanged("swift")) {
            $0.query = "swift"
            $0.isSearching = true
        }
        await clock.waitForSleepers()
        await store.send(.queryChanged("")) {
            $0.query = ""
            $0.isSearching = false
        }
        await store.finish()
        #expect(clock.sleeperCount == 0)
    }

    @Test("Contacts: pushing, adding through the sheet, and dismissing it")
    func contacts() async {
        let store = TestStore(
            initialState: Contacts.State(contacts: [Contacts.Contact(id: 1, name: "Ada")]),
            reducer: Contacts()
        )
        await store.send(.contactTapped(1)) { $0.path = [1] }
        await store.send(.pathChanged([])) { $0.path = [] }
        await store.send(.addTapped) { $0.newContact = Contacts.NewContact(id: 2) }
        await store.send(.saveTapped)
        await store.send(.newContactNameChanged("Grace")) { $0.newContact?.name = "Grace" }
        await store.send(.saveTapped) {
            $0.contacts.append(Contacts.Contact(id: 2, name: "Grace"))
            $0.newContact = nil
        }
        await store.send(.addTapped) { $0.newContact = Contacts.NewContact(id: 3) }
        await store.send(.newContactDismissed) { $0.newContact = nil }
    }

    @Test("Settings: changes are saved and restored")
    func settings() async throws {
        let storage = InMemoryStorage()
        let store = makeSettingsStore(storage: storage)
        await store.send(.showsCompletedToggled(false)).finish()
        #expect(try storage.load(.settings) == Settings(showsCompleted: false))
        #expect(makeSettingsStore(storage: storage).settings.showsCompleted == false)
    }
}
