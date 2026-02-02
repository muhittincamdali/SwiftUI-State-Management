# SwiftUIStateManagement

[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2015%20|%20macOS%2012-blue.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A lightweight, composable state management library for SwiftUI applications. Inspired by Redux and TCA patterns but designed to be simpler and more pragmatic.

---

## Features

- **Observable Store** — `@Published` state with automatic SwiftUI updates
- **Pure Reducers** — Predictable state transitions with no side effects
- **Async Effects** — First-class support for async/await side effects
- **Middleware Pipeline** — Intercept and transform actions before they reach reducers
- **Scoped Stores** — Derive child stores for modular architecture
- **ViewStore Bindings** — Two-way bindings from store properties to SwiftUI views
- **Time-Travel Debugging** — Step forward and backward through state history
- **State Logging** — Console logging for every action and state transition
- **TestStore** — Dedicated testing utilities for verifying state logic

---

## Architecture

```
┌─────────────┐     ┌────────────┐     ┌──────────┐
│    View      │────▶│   Action   │────▶│Middleware │
└─────────────┘     └────────────┘     └──────────┘
      ▲                                      │
      │                                      ▼
┌─────────────┐     ┌────────────┐     ┌──────────┐
│  ViewStore   │◀────│   State    │◀────│ Reducer  │
└─────────────┘     └────────────┘     └──────────┘
                                             │
                                             ▼
                                       ┌──────────┐
                                       │  Effect   │
                                       └──────────┘
```

---

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-State-Management.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and paste the repository URL.

---

## Quick Start

### 1. Define State and Actions

```swift
struct CounterState: Equatable {
    var count: Int = 0
    var isLoading: Bool = false
}

enum CounterAction: Equatable {
    case increment
    case decrement
    case setLoading(Bool)
    case fetchComplete(Int)
}
```

### 2. Create a Reducer

```swift
let counterReducer = Reducer<CounterState, CounterAction> { state, action in
    switch action {
    case .increment:
        state.count += 1
        return .none

    case .decrement:
        state.count -= 1
        return .none

    case .setLoading(let loading):
        state.isLoading = loading
        return .none

    case .fetchComplete(let value):
        state.count = value
        state.isLoading = false
        return .none
    }
}
```

### 3. Build the Store

```swift
let store = Store(
    initialState: CounterState(),
    reducer: counterReducer,
    middleware: [LoggingMiddleware()]
)
```

### 4. Connect to SwiftUI

```swift
struct CounterView: View {
    @ObservedObject var store: Store<CounterState, CounterAction>

    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(store.state.count)")
                .font(.largeTitle)

            HStack(spacing: 40) {
                Button("−") { store.send(.decrement) }
                Button("+") { store.send(.increment) }
            }
            .font(.title)
        }
    }
}
```

---

## Advanced Usage

### Effects

Effects let you perform async work and feed actions back into the store:

```swift
let counterReducer = Reducer<CounterState, CounterAction> { state, action in
    switch action {
    case .fetchRandom:
        state.isLoading = true
        return Effect {
            let value = try await APIClient.fetchRandom()
            return .fetchComplete(value)
        }

    default:
        return .none
    }
}
```

### Middleware

Middleware intercepts actions before they reach the reducer:

```swift
struct AnalyticsMiddleware<State, Action>: Middleware {
    func handle(action: Action, state: State, next: @escaping (Action) -> Void) {
        Analytics.track(String(describing: action))
        next(action)
    }
}
```

### Scoped Stores

Break down large states into smaller, focused stores:

```swift
struct AppState: Equatable {
    var counter: CounterState = .init()
    var profile: ProfileState = .init()
}

let counterScope = store.scope(
    state: \.counter,
    action: AppAction.counter
)
```

### ViewStore Bindings

Create two-way bindings for form inputs:

```swift
struct SettingsView: View {
    @ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>

    var body: some View {
        Toggle(
            "Dark Mode",
            isOn: viewStore.binding(
                get: \.isDarkMode,
                send: SettingsAction.toggleDarkMode
            )
        )
    }
}
```

### Time-Travel Debugging

Step through state history during development:

```swift
#if DEBUG
let debugger = TimeTravelDebugger(store: store)
debugger.stepBack()
debugger.stepForward()
debugger.jumpTo(index: 5)
print(debugger.history) // All recorded states
#endif
```

---

## Testing

Use `TestStore` to verify your state logic:

```swift
func testIncrement() async {
    let testStore = TestStore(
        initialState: CounterState(),
        reducer: counterReducer
    )

    await testStore.send(.increment) {
        $0.count = 1
    }

    await testStore.send(.decrement) {
        $0.count = 0
    }
}
```

---

## API Reference

### Core Types

| Type | Description |
|------|-------------|
| `Store<State, Action>` | Observable container that holds state and dispatches actions |
| `Reducer<State, Action>` | Pure function `(inout State, Action) -> Effect<Action>` |
| `Effect<Action>` | Async side effect that can produce new actions |
| `Middleware<State, Action>` | Intercepts actions in the dispatch pipeline |
| `Scope<ParentState, ChildState, ParentAction, ChildAction>` | Derives child stores |

### Binding Types

| Type | Description |
|------|-------------|
| `ViewStore<State, Action>` | Wrapper providing SwiftUI bindings |
| `StoreView<State, Action, Content>` | Convenience view with built-in store observation |

### DevTools

| Type | Description |
|------|-------------|
| `StateLogger` | Logs all actions and state changes to console |
| `TimeTravelDebugger` | Records and navigates state history |

### Testing

| Type | Description |
|------|-------------|
| `TestStore<State, Action>` | Assertion-friendly store for unit tests |

---

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.7+
- Xcode 14.0+

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-feature`)
3. Write tests for your changes
4. Ensure all tests pass
5. Submit a pull request

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgments

Built with inspiration from composable architecture patterns and real-world production needs. Designed to strike the right balance between simplicity and power for SwiftUI apps.
