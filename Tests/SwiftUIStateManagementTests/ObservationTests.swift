import Observation
import Testing
@testable import SwiftUIStateManagement

@Suite("Observation")
@MainActor
struct ObservationTests {
    private func makeStore() -> Store<Profile.State, Profile.Action> {
        Store(initialState: Profile.State(), reducer: Profile())
    }

    @Test("A read of one property is not invalidated by a change to another")
    func fieldLevel() {
        let store = makeStore()
        let countReads = observationCount { _ = store.count }
        let titleReads = observationCount { _ = store.title }

        store.send(.setTitle("New title"))
        #expect(countReads.count == 0)
        #expect(titleReads.count == 1)

        store.send(.setCount(1))
        #expect(countReads.count == 1)
    }

    @Test("store.address.city observes address; a scoped store observes city on its own")
    func nested() {
        let store = makeStore()
        let addressReads = observationCount { _ = store.address.city }
        let address = store.scope(state: \.address, action: { (city: String) in Profile.Action.setCity(city) })
        let cityReads = observationCount { _ = address.city }

        store.send(.setStreet("Second"))
        #expect(addressReads.count == 1)
        #expect(cityReads.count == 0)

        store.send(.setCity("Ankara"))
        #expect(cityReads.count == 1)
    }

    @Test("Reading state observes every change")
    func wholeState() {
        let store = makeStore()
        let reads = observationCount { _ = store.state.count }
        store.send(.setTitle("Other"))
        #expect(reads.count == 1)
    }

    @Test("A computed property falls back to observing the whole state")
    func computedProperty() {
        let store = makeStore()
        let reads = observationCount { _ = store.doubled }
        store.send(.setTitle("Other"))
        #expect(reads.count == 1)
    }

    @Test("A value that is not Equatable falls back to observing the whole state")
    func nonEquatableValue() {
        let store = makeStore()
        let reads = observationCount { _ = store.nonEquatable }
        store.send(.setCount(5))
        #expect(reads.count == 1)
    }

    @Test("A send that leaves an Equatable state unchanged notifies no one")
    func unchangedState() {
        let store = makeStore()
        let wholeReads = observationCount { _ = store.state }
        let countReads = observationCount { _ = store.count }
        store.send(.noop)
        store.send(.setCount(0))
        #expect(wholeReads.count == 0)
        #expect(countReads.count == 0)
    }

    @Test("A subscript key path is never compared on an old state, so a shrinking array cannot trap")
    func subscriptKeyPathIsSafe() throws {
        let store = makeStore()
        let core = try #require(store.core as? RootCore<Profile>)
        let reads = observationCount { _ = store[dynamicMember: \.tags[2]] }
        #expect(core.observedMemberCount == 0)

        store.send(.setTags(["only one"]))
        #expect(reads.count == 1)
        #expect(store.tags == ["only one"])
    }

    @Test("Tracked key paths are bounded by the shape of the state, not by how often views read")
    func trackedKeyPathsAreBounded() throws {
        let store = makeStore()
        let core = try #require(store.core as? RootCore<Profile>)
        for index in 0..<1_000 {
            _ = store[dynamicMember: \.tags[index % 3]]
            _ = store.count
            _ = store.address.city
        }
        #expect(core.observedMemberCount == 2)
    }

    @Test("A scoped store observes only its part of the parent state")
    func scopedObservation() {
        let store = makeStore()
        let address = store.scope(state: \.address, action: { (city: String) in Profile.Action.setCity(city) })
        let cityReads = observationCount { _ = address.city }
        let scopeReads = observationCount { _ = address.state }

        store.send(.setCount(3))
        #expect(cityReads.count == 0)
        #expect(scopeReads.count == 0)

        address.send("Izmir")
        #expect(cityReads.count == 1)
        #expect(scopeReads.count == 1)
        #expect(store.address.city == "Izmir")
    }

    @Test("An observer that sends during a change has its action processed after the current one")
    func reentrantSend() {
        let store = makeStore()
        withObservationTracking {
            _ = store.count
        } onChange: {
            MainActor.assumeIsolated {
                store.send(.setTitle("Changed by observer"))
            }
        }
        store.send(.setCount(1))
        #expect(store.count == 1)
        #expect(store.title == "Changed by observer")
    }
}
