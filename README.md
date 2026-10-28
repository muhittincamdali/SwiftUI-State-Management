<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

SwiftUI State Management is a small Swift 6 package for unidirectional state in SwiftUI apps on
iOS 17 and later. A feature is a reducer: a value with a `State`, an `Action` and one method
that changes the state and returns the asynchronous work to start. A `Store` runs it on the main
actor and implements `Observable`, so views read it like an `@Observable` model, and it tracks
reads per property without macros. Navigation is state, persistence is one reducer modifier,
and `TestStore` checks every state change and every action an effect sends. It has no
dependencies.

## Highlights

- **Unidirectional flow on Observation** — views read `store.count` and call
  `store.send(.incrementTapped)`; the reducer is the only place the state changes. A read of an
  `Equatable` stored property is tracked on its own, so a view that shows `count` does not
  update when `title` changes.
- **Effects you can cancel** — `.run` starts a task on the main actor; label it with an id to
  cancel it, or let `cancelInFlight` keep only the newest one. A cancelled effect cannot send
  stale results, and the store cancels everything when it goes away.
- **Navigation as state** — `NavigationStack` paths, sheets, alerts and enum destinations
  through bindings that send actions, so deep links and tests need no view.
- **Persistence** — `persisting(\.items, to: .todos, in: storage)` saves part of the state after
  each change, debounced and flushed on demand, off the main actor and in order. Keys are
  versioned, size-limited and validated, so a name cannot leave the storage's directory.
- **Exhaustive tests** — `TestStore` fails with a line-by-line difference when a state change,
  a received action or a leftover effect differs from what the test says; `TestClock` ends a
  debounce without waiting.
- **Honest about the alternatives** — the [Choosing an approach](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  guide says when plain `@Observable` models are enough and when
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
  is the better choice.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…** and enter the repository URL:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Until 2.0.0 is released, set **Dependency Rule** to **Branch** and enter `main`: the default rule
picks the latest release, 1.0.0, which still has the old API.

**2. Import the module**

```swift
import SwiftUIStateManagement
```

**3. Use it**

Describe the feature, show it, and create the store
([ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)):

```swift
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
```

`NumberFacts` stands for your service: a struct with an async `fact(Int)` closure, so tests can pass
a fake. A version that needs no network:

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

Create the store once, where the screen's lifetime begins:

```swift
@main
struct CounterApp: App {
    @State private var store = Store(initialState: Counter.State(), reducer: Counter(facts: .local))

    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
        }
    }
}
```

## Installation

### Swift Package Manager

In Xcode, choose **File › Add Package Dependencies…**, enter the repository URL, and add
`SwiftUIStateManagement` to your app target and `SwiftUIStateManagementTesting` to your test
target:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Until 2.0.0 is released, set **Dependency Rule** to **Branch** and enter `main`: the default rule
picks the latest release, 1.0.0, which still has the old API.

Or add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-State-Management.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftUIStateManagement", package: "SwiftUI-State-Management")
    ]),
    .testTarget(name: "YourAppTests", dependencies: [
        "YourApp",
        .product(name: "SwiftUIStateManagementTesting", package: "SwiftUI-State-Management")
    ])
]
```

## Usage

The samples below are copied from
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift), which the example
app builds and the test suite runs.

### Effects and cancellation

A search that runs only once the user has stopped typing for 300 ms: each keystroke cancels the
waiting search through `cancelInFlight`, and clearing the field cancels it outright. The clock
is a dependency, so tests can pass a `TestClock`.

```swift
struct Search: Reducer {
    struct State: Equatable {
        var query = ""
        var results: [String] = []
        var isSearching = false
    }

    enum Action: Equatable {
        case queryChanged(String)
        case resultsLoaded([String])
        case searchFailed
    }

    enum CancelID { case search }

    let search: @Sendable (String) async throws -> [String]
    let clock: any Clock<Duration>

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .queryChanged(let query):
            state.query = query
            guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                state.results = []
                state.isSearching = false
                return .cancel(id: CancelID.search)
            }
            state.isSearching = true
            // A new keystroke cancels the waiting search: only the last query runs.
            return .run(id: CancelID.search, cancelInFlight: true) { [search, clock] send in
                try await clock.sleep(for: .milliseconds(300))
                send(.resultsLoaded(try await search(query)))
            } catch: { _, send in
                send(.searchFailed)
            }
        case .resultsLoaded(let results):
            state.isSearching = false
            state.results = results
            return .none
        case .searchFailed:
            state.isSearching = false
            state.results = []
            return .none
        }
    }
}
```

In the view, `store.binding(\.query, send: Search.Action.queryChanged)` connects a text field.

### Navigation state

The stack is an array in the state and the sheet is an optional. `binding(_:send:)` turns the
array into the `NavigationStack` path, and `binding(_:dismiss:)` sends `newContactDismissed`
when the user swipes the sheet down:

```swift
struct ContactsView: View {
    let store: Store<Contacts.State, Contacts.Action>

    var body: some View {
        NavigationStack(path: store.binding(\.path, send: Contacts.Action.pathChanged)) {
            List(store.contacts) { contact in
                Button(contact.name) { store.send(.contactTapped(contact.id)) }
            }
            .navigationDestination(for: Contacts.Contact.ID.self) { id in
                Text(store.contacts.first { $0.id == id }?.name ?? "Deleted")
            }
            .toolbar {
                Button("Add") { store.send(.addTapped) }
            }
            .sheet(item: store.binding(\.newContact, dismiss: .newContactDismissed)) { _ in
                Form {
                    TextField("Name", text: store.binding(\.newContactName, send: Contacts.Action.newContactNameChanged))
                    Button("Save") { store.send(.saveTapped) }
                }
            }
        }
    }
}
```

`isPresented(_:dismiss:)` does the same for alerts and confirmation dialogs. The
[Navigation state](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
guide covers enum destinations, deep links and restoring the stack at launch.

### Persistence

Load the saved value when you create the store, and let `persisting(_:to:in:)` save each
change:

```swift
extension PersistenceKey where Value == Settings {
    static let settings = PersistenceKey("settings", version: 1)
}

@MainActor
func makeSettingsStore(storage: some StateStorage) -> Store<SettingsFeature.State, SettingsFeature.Action> {
    let saved = (try? storage.load(.settings)) ?? Settings()
    return Store(
        initialState: SettingsFeature.State(settings: saved),
        reducer: SettingsFeature().persisting(\.settings, to: .settings, in: storage)
    )
}
```

Pass `try FileStorage.applicationSupport()` in the app and an `InMemoryStorage` in tests and
previews. Saved data carries its version; a key can migrate older data, and a stored file larger
than the key's limit (1 MiB by default) is refused before it is read.

### Testing

`TestStore` checks each state change and each action an effect sends back. This test from
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) types
two letters and checks that only the second query is searched:

```swift
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
```

`Collected` is a small lock-protected array in the test target. The test fails if the reducer
changes the state in another way, if another action arrives, or if an effect is still running
when the test ends.

## Demo

The [StateDemo](Examples/StateDemo) app runs each topic with the real library, on iOS and
macOS. The screenshots come from the macOS build of the app, which plays each scenario with the
same actions a user would send, captured by
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) (its `ios` mode
captures the same scenarios on an iPhone simulator):

| Todos | Todo opened by a deep link | Debounced search | Per-property observation |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Todos screen: a filter, five todos, two of them done"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="Detail screen of the todo 'Review the pull request', opened by a statedemo:// link"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Search screen: results for 'Swift' after four keystrokes"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Observation screen: the left card's body ran four times, the right card's twice"></picture> |

To run it, open `StateDemo.xcodeproj` in [Examples/StateDemo](Examples/StateDemo) with Xcode
26 or later, choose an iPhone simulator or **My Mac**, and press **Run**.
[Examples/README.md](Examples/README.md) describes each screen.

## Documentation

Reference documentation and articles:

- [SwiftUIStateManagement reference](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [SwiftUIStateManagementTesting reference](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Getting started](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [How observation works](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Choosing an approach](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Guides

- [Getting started](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — a feature, its view and the app that owns the store.
- [How observation works](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — which reads update a view, and how to keep updates small.
- [Effects and cancellation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — errors, identifiers, debouncing, effects tied to a view, clocks.
- [Navigation state](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — stacks, sheets, alerts, enum destinations, deep links and restoration.
- [Persisting state](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — keys, storages, debounce and flush, migrations and limits.
- [Testing features](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock`, and tests with the real store.
- [Choosing an approach](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — plain `@Observable` models, this package, or The Composable Architecture.

## Requirements

| Platform | Minimum version |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Toolchain | Swift 6.2 · Xcode 26+ |

The minimums are the first releases with the Observation framework. CI builds every platform
and runs the tests on macOS and an iOS simulator.

## Architecture

Two libraries:

| Library | Types |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, the bindings, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Design decisions:

- **Value state, one registrar.** The state is a struct. The store keeps it behind an
  `ObservationRegistrar` and registers each read of an `Equatable` stored property under its
  own key path (the store's state key path with the property's path appended). After an action
  it compares those properties and notifies only the ones that changed. Key paths that are not
  a chain of stored properties fall back to the whole state, so the store never evaluates a
  subscript or computed property on an old state.
- **Main actor throughout.** Reducers, the store and effect operations run on the main actor,
  which matches SwiftUI and keeps `Send` free of `Sendable` requirements on actions. Slow work
  belongs in the clients your effects await.
- **Dependencies are stored properties.** A reducer's API client or clock is passed to its
  initializer; there is no global container to configure.
- **Problems are reported, not trapped.** An effect error without a handler or a runaway
  `Effect.send` loop becomes a `StoreIssue` (type names only, never values) and a test failure
  under `TestStore`. Persistence rejects invalid names and sizes with errors.

### How it compares

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
is the established library for this style and offers far more: macros that remove boilerplate
and track nested state, a dependency system, navigation tools for stacks and tree-based
presentation, shared state, non-exhaustive testing, and a large community. Use TCA when your
app has many features that share state or dependencies, or when your team knows it. Use this
package when you want the same unidirectional shape with a surface small enough to read in an
afternoon, no dependencies and no macros. Plain `@Observable` models remain the simplest choice
for small screens. The [Choosing an approach](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
guide compares the three in detail.

## Roadmap

- Stack navigation of child features: a parent that holds a stack of child states and routes
  each child's actions by element id.
- Non-exhaustive `TestStore` mode, for integration tests that check only some changes.
- Linux support for the reducer, effect and persistence layers, which need no SwiftUI.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
