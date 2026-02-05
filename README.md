<p align="center">
  <img src="Assets/banner.png" alt="SwiftUI State Management" width="100%"/>
</p>

<h1 align="center">SwiftUI State Management</h1>

<p align="center">
  <strong>🚀 The most powerful and developer-friendly state management for SwiftUI</strong>
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138.svg?style=flat&logo=swift" alt="Swift 5.9+"/></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-15.0+-007AFF.svg?style=flat&logo=apple" alt="iOS 15.0+"/></a>
  <a href="https://developer.apple.com/macos/"><img src="https://img.shields.io/badge/macOS-12.0+-007AFF.svg?style=flat&logo=apple" alt="macOS 12.0+"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License"/></a>
  <img src="https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat&logo=swift" alt="SPM Compatible"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#comparison">TCA Comparison</a>
</p>

---

## Why SwiftUI State Management?

Building complex SwiftUI apps requires **predictable state management**. SwiftUI's built-in tools (`@State`, `@ObservedObject`) work for simple cases but fall short for:

- 🔄 **Complex state flows** across multiple screens
- 🧪 **Testing** state changes in isolation
- 🐛 **Debugging** what caused a state change
- 📦 **Sharing state** between unrelated views
- ⚡ **Async operations** with proper cancellation

**SwiftUI State Management** solves all of these with a clean, minimal API inspired by Redux and TCA — but without the boilerplate.

## Features

<table>
<tr>
<td width="50%">

### 🎯 Core Features
- **Unidirectional Data Flow** — State → View → Action → Reducer
- **Type-Safe** — Compile-time guarantees
- **Effects System** — Async operations with cancellation
- **Middleware Pipeline** — Intercept and transform actions
- **State Scoping** — Child state isolation
- **Combine Integration** — Works with publishers

</td>
<td width="50%">

### 🛠 DevTools
- **Visual State Debugger** — Inspect state in real-time
- **Time-Travel Debugging** — Step through state history
- **State Diff Viewer** — See exactly what changed
- **Performance Monitor** — Track slow reducers
- **Action Recording** — Replay action sequences
- **Export/Import** — Save and restore state

</td>
</tr>
</table>

## TCA Comparison

| Feature | TCA | SwiftUI SM | Advantage |
|---------|-----|------------|-----------|
| **API Complexity** | Complex macros | Simple structs | ✅ Easier to learn |
| **ViewStore** | Required wrapper | Direct access | ✅ Less boilerplate |
| **Built-in Debugger** | ❌ External tools | ✅ Visual overlay | ✅ Instant debugging |
| **State Diff** | ❌ No | ✅ Built-in | ✅ See changes |
| **Performance Monitor** | ❌ Manual | ✅ Automatic | ✅ Find bottlenecks |
| **Time Travel** | Via Instruments | ✅ Built-in UI | ✅ Direct control |
| **Learning Curve** | Steep | Gentle | ✅ Faster onboarding |
| **Migration** | Breaking changes | Stable API | ✅ Less maintenance |

> **Coming from TCA?** Check our [Migration Guide](Documentation/TCA_MIGRATION.md)

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittinpalamutcu/SwiftUI-State-Management.git", from: "2.0.0")
]
```

## Quick Start

### 1️⃣ Define State & Actions

```swift
struct AppState: Equatable {
    var count = 0
    var isLoading = false
    var error: String?
}

enum AppAction: Equatable {
    case increment
    case decrement
    case fetchData
    case dataLoaded(Result<[Item], Error>)
}
```

### 2️⃣ Create Reducer

```swift
let appReducer = Reducer<AppState, AppAction> { state, action in
    switch action {
    case .increment:
        state.count += 1
        return .none
        
    case .decrement:
        state.count -= 1
        return .none
        
    case .fetchData:
        state.isLoading = true
        return .task {
            do {
                let items = try await API.fetchItems()
                return .dataLoaded(.success(items))
            } catch {
                return .dataLoaded(.failure(error))
            }
        }
        
    case .dataLoaded(let result):
        state.isLoading = false
        switch result {
        case .success: break
        case .failure(let error):
            state.error = error.localizedDescription
        }
        return .none
    }
}
```

### 3️⃣ Create Store

```swift
let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    middleware: [
        AnyMiddleware(LoggingMiddleware()),
    ],
    configuration: .debug  // Enables time-travel
)
```

### 4️⃣ Use in SwiftUI

```swift
struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Count: \(store.state.count)")
                .font(.largeTitle)
            
            HStack(spacing: 40) {
                Button("−") { store.send(.decrement) }
                Button("+") { store.send(.increment) }
            }
            .font(.title)
            
            if store.state.isLoading {
                ProgressView()
            }
            
            Button("Fetch Data") {
                store.send(.fetchData)
            }
            .disabled(store.state.isLoading)
        }
        .debuggerOverlay(store: store)  // 🐛 Visual debugger!
    }
}
```

## Effects

Effects handle async operations and side effects:

```swift
// Simple async task
return .task {
    let data = try await api.fetch()
    return .dataLoaded(data)
}

// Fire and forget
return .fireAndForget {
    await analytics.track("button_tapped")
}

// With cancellation
return .task(id: "search") {
    let results = try await api.search(query)
    return .searchResults(results)
}

// Cancel previous
return .cancel(id: "search")

// Debounce
return .debounce(duration: 0.3, id: "typing") {
    .search(query)
}

// Combine multiple
return .merge(
    .task { ... },
    .fireAndForget { ... }
)
```

## Middleware

Intercept actions before they reach the reducer:

```swift
// Built-in logging
let store = Store(
    initialState: AppState(),
    reducer: appReducer,
    middleware: [
        AnyMiddleware(LoggingMiddleware(includeState: true))
    ]
)

// Custom middleware
struct AnalyticsMiddleware: Middleware {
    let name = "Analytics"
    
    func handle(action: AppAction, state: AppState, next: (AppAction) -> Void) {
        // Track before
        Analytics.track(action)
        
        // Continue to reducer
        next(action)
        
        // Track after if needed
    }
}
```

## Visual Debugger

<p align="center">
  <img src="Assets/debugger-preview.png" alt="Visual Debugger" width="300"/>
</p>

Add a debugger overlay to any view:

```swift
.debuggerOverlay(store: store)
```

Features:
- 🔍 **State Inspector** — Browse state tree with search
- ⏮️ **Time Travel** — Step back/forward through history
- 📊 **Performance** — See action count and effect status
- 📝 **Action Log** — View all dispatched actions

## Testing

Comprehensive testing support:

```swift
@MainActor
func testIncrement() async {
    let store = TestStore(
        initialState: AppState(count: 0),
        reducer: appReducer
    )
    
    await store.send(.increment) {
        $0.count = 1
    }
    
    await store.send(.increment) {
        $0.count = 2
    }
}

@MainActor
func testFetchData() async {
    let store = TestStore(
        initialState: AppState(),
        reducer: appReducer
    )
    
    await store.send(.fetchData) {
        $0.isLoading = true
    }
    
    await store.receive(.dataLoaded(.success(mockItems))) {
        $0.isLoading = false
    }
}
```

## State Diffing

See exactly what changed:

```swift
let differ = StateDiffer<AppState>()
let diff = differ.diff(from: oldState, to: newState)

print(diff)
// Output:
// ~ count: 0 → 1
// + isLoading: true
```

## Performance Monitoring

Track reducer performance:

```swift
let monitor = PerformanceMonitor<AppState, AppAction>()
monitor.start()

// Later...
let report = PerformanceReport(from: monitor.metrics)
print("Average reducer time: \(report.averageReducerTime)ms")
print("Slow actions: \(report.slowActionCount)")
```

## Feature Composition

Compose features together:

```swift
// Child feature
let counterReducer = Reducer<CounterState, CounterAction> { ... }

// Parent composition
let appReducer = Reducer<AppState, AppAction>.combine(
    counterReducer.pullback(
        state: \.counter,
        action: { if case .counter(let a) = $0 { return a }; return nil },
        embed: AppAction.counter
    ),
    Reducer { state, action in
        // Handle app-level actions
        return .none
    }
)
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         View                                 │
│                    @ObservedObject store                     │
└──────────────────────────┬──────────────────────────────────┘
                           │ store.send(.action)
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      Middleware                              │
│              Logging → Validation → Analytics                │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                        Store                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │    State    │◄───│   Reducer   │◄───│     Action      │  │
│  └─────────────┘    └──────┬──────┘    └─────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│                    ┌─────────────┐                           │
│                    │   Effect    │──► Async Work             │
│                    └─────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

## Examples

Check the [Examples](Examples/) folder:

- **Counter** — Basic state management
- **Todo App** — CRUD operations with effects
- **Search** — Debouncing and cancellation
- **Navigation** — Multi-screen state

## Documentation

- 📖 [API Reference](Documentation/)
- 🔄 [TCA Migration Guide](Documentation/TCA_MIGRATION.md)
- 🧪 [Testing Guide](Documentation/TESTING.md)
- 🎯 [Best Practices](Documentation/BEST_PRACTICES.md)

## Requirements

- iOS 15.0+ / macOS 12.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 5.7+
- Xcode 14.0+

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<p align="center">
  <strong>Built with ❤️ for the SwiftUI community</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittinpalamutcu/SwiftUI-State-Management/stargazers">⭐ Star us on GitHub</a>
</p>
