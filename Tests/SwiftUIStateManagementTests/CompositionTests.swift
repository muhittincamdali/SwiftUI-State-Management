import Testing
@testable import SwiftUIStateManagement
import SwiftUIStateManagementTesting

/// A parent feature that runs `Counter` on part of its state.
struct Dashboard: Reducer {
    struct State: Equatable {
        var counter = Counter.State()
        var events: [String] = []
    }

    enum Action: Equatable {
        case counter(Counter.Action)
        case resetTapped
    }

    let facts: NumberFacts

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .counter(.incrementTapped):
                state.events.append("parent saw increment")
            case .resetTapped:
                state.counter = Counter.State()
            case .counter:
                break
            }
            return .none
        }
        .combined(with: Scope(
            state: \.counter,
            action: { if case .counter(let action) = $0 { action } else { nil } },
            embed: Action.counter,
            child: Counter(facts: facts)
        ))
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        body.reduce(into: &state, action: action)
    }
}

@Suite("Composition")
@MainActor
struct CompositionTests {
    @Test("Scope runs the child on its state and wraps the child's effects in parent actions")
    func scopeRunsChild() async {
        let store = TestStore(
            initialState: Dashboard.State(),
            reducer: Dashboard(facts: NumberFacts { "\($0) from the child" })
        )
        await store.send(.counter(.incrementTapped)) {
            $0.events = ["parent saw increment"]
            $0.counter.count = 1
        }
        await store.send(.counter(.factTapped)) { $0.counter.isLoadingFact = true }
        await store.receive(.counter(.factLoaded("1 from the child"))) {
            $0.counter.isLoadingFact = false
            $0.counter.fact = "1 from the child"
        }
        await store.send(.resetTapped) { $0.counter = Counter.State() }
    }

    @Test("Scope ignores parent actions that are not the child's")
    func scopeIgnoresOtherActions() {
        let scope = Scope<Dashboard.State, Dashboard.Action, Counter>(
            state: \.counter,
            action: { if case .counter(let action) = $0 { action } else { nil } },
            embed: Dashboard.Action.counter,
            child: Counter(facts: .local)
        )
        var state = Dashboard.State()
        let effect = scope.reduce(into: &state, action: .resetTapped)
        #expect(effect.operations.isEmpty)
        #expect(state == Dashboard.State())
    }

    @Test("A child store from scope sends through the parent and reads the parent's state")
    func scopedStore() {
        let store = Store(initialState: Dashboard.State(), reducer: Dashboard(facts: .local))
        let counter = store.scope(state: \.counter, action: Dashboard.Action.counter)
        counter.send(.incrementTapped)
        #expect(counter.count == 1)
        #expect(store.events == ["parent saw increment"])
    }

    @Test("merge keeps the order of immediate actions; map wraps them")
    func mergeAndMap() {
        let effect = Effect<Counter.Action>.merge(.send(.incrementTapped), .none, .send(.decrementTapped))
            .map(Dashboard.Action.counter)
        let sent = effect.operations.compactMap { operation -> Dashboard.Action? in
            if case .send(let action) = operation { action } else { nil }
        }
        #expect(sent == [.counter(.incrementTapped), .counter(.decrementTapped)])
    }
}
