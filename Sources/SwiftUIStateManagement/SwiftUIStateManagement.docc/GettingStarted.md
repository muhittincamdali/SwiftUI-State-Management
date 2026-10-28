# Getting started

Build a feature with a reducer, show it with a store, and load data with an effect.

## Overview

This article builds the counter of the example app: a stepper and a button that loads a fact
about the current number from a service.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/SwiftUI-State-Management.git`, and add the
`SwiftUIStateManagement` library to your app target. Add `SwiftUIStateManagementTesting` to
your test target.

### Describe the feature

A feature is a ``Reducer``. Its `State` holds everything the screen shows, its `Action` lists
everything that can happen, and its dependencies are ordinary stored properties:

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
}

extension NumberFacts {
    /// Works out a fact on the device after a short pause, so the demo needs no network.
    static let local = NumberFacts { number in
        try await Task.sleep(for: .milliseconds(400))
        return number.isMultiple(of: 2) ? "\(number) is even." : "\(number) is odd."
    }
}

struct Counter: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoadingFact = false
    }

    enum Action: Equatable {
        case incrementTapped
        case decrementTapped
        case factTapped
        case factLoaded(String)
        case factFailed
    }

    let facts: NumberFacts

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .incrementTapped:
            state.count += 1
            state.fact = nil
            return .none
        case .decrementTapped:
            state.count -= 1
            state.fact = nil
            return .none
        case .factTapped:
            state.isLoadingFact = true
            return .run { [facts, count = state.count] send in
                send(.factLoaded(try await facts.fact(count)))
            } catch: { _, send in
                send(.factFailed)
            }
        case .factLoaded(let fact):
            state.isLoadingFact = false
            state.fact = fact
            return .none
        case .factFailed:
            state.isLoadingFact = false
            state.fact = "No fact this time."
            return .none
        }
    }
}
```

`reduce(into:action:)` runs synchronously on the main actor. It changes the state and returns
what to do next: ``Effect/none`` for nothing, or ``Effect/run(priority:operation:catch:)`` for
asynchronous work whose result comes back as another action. Capture what the effect needs
(`[facts, count = state.count]`); the effect cannot read the state later.

### Show it

Create a ``Store`` with the initial state and the reducer, and read the state through it.
Views change state only by sending actions:

```swift
struct CounterView: View {
    let store: Store<Counter.State, Counter.Action>

    var body: some View {
        Form {
            Stepper("Count: \(store.count)") {
                store.send(.incrementTapped)
            } onDecrement: {
                store.send(.decrementTapped)
            }
            Button("Tell me a fact") { store.send(.factTapped) }
                .disabled(store.isLoadingFact)
            if let fact = store.fact {
                Text(fact)
            }
        }
    }
}

@main
struct CounterApp: App {
    @State private var store = Store(
        initialState: Counter.State(),
        reducer: Counter(facts: .local)
    )

    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
        }
    }
}
```

Keep the store in `@State` (or in an `@Observable` model that the app owns) so that it lives as
long as the scene. A store cancels its running effects when it is deallocated.

### Controls that write values

Text fields, toggles and pickers need a `Binding`. `binding(_:send:)`
reads a value and turns each write into an action:

```swift
TextField("Search", text: store.binding(\.query, send: Search.Action.queryChanged))
```

### Split a large feature

A parent feature can run a child's reducer on part of its state with ``Scope`` and
``Reducer/combined(with:)``, and give the child view a store for that part with
`scope(state:action:)`:

```swift
SettingsView(store: store.scope(state: \.settings, action: AppAction.settings))
```

### Next steps

- <doc:EffectsAndCancellation> covers identifiers, cancellation, debouncing and clocks.
- <doc:NavigationState> drives `NavigationStack`, sheets and alerts from state.
- <doc:PersistingState> saves state to disk.
- <doc:TestingFeatures> tests the counter, including its effect.
