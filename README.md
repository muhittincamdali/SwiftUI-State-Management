<p align="center">
  <img src="Assets/logo.png" alt="SwiftUI State Management" width="200"/>
</p>

<h1 align="center">SwiftUI State Management</h1>

<p align="center">
  <strong>🔄 Lightweight TCA-inspired state management for SwiftUI</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS"/>
</p>

---

## Why?

TCA is powerful but complex. SwiftUI's built-in state is limited. **SwiftUI State Management** provides the best of both - unidirectional data flow with minimal boilerplate.

```swift
// Define feature
@Feature
struct Counter {
    struct State {
        var count = 0
    }
    
    enum Action {
        case increment
        case decrement
    }
    
    func reduce(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .increment:
            state.count += 1
            return .none
        case .decrement:
            state.count -= 1
            return .none
        }
    }
}

// Use in view
struct CounterView: View {
    @Store var store: Counter.Store
    
    var body: some View {
        VStack {
            Text("\(store.state.count)")
            Button("+") { store.send(.increment) }
            Button("-") { store.send(.decrement) }
        }
    }
}
```

## Features

| Feature | Description |
|---------|-------------|
| 🔄 **Unidirectional** | State → View → Action → Reducer |
| 🧪 **Testable** | Easy state & action testing |
| 🎯 **Type-Safe** | Compile-time guarantees |
| ⚡ **Effects** | Async side effects |
| 🔗 **Composition** | Combine child features |

## Effects

```swift
func reduce(state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .loadUsers:
        return .task {
            let users = try await api.fetchUsers()
            return .usersLoaded(users)
        }
    case .usersLoaded(let users):
        state.users = users
        return .none
    }
}
```

## Testing

```swift
func testIncrement() {
    let store = TestStore(Counter())
    
    store.send(.increment) {
        $0.count = 1
    }
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/SwiftUI-State-Management&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftUI-State-Management&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftUI-State-Management&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/SwiftUI-State-Management&type=Date" />
 </picture>
</a>
