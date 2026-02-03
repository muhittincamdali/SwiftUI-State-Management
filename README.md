<div align="center">

# 🔄 SwiftUI-State-Management

**Lightweight TCA-inspired state management for SwiftUI**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🔄 **Unidirectional** — Predictable state flow
- 🧪 **Testable** — Easy to test reducers
- 📦 **Lightweight** — Simpler than TCA
- ⚡ **Performance** — Optimized re-renders
- 🔌 **Effects** — Side effect handling

---

## 🚀 Quick Start

```swift
import SwiftUIStateManagement

struct CounterState: StateType {
    var count = 0
}

enum CounterAction {
    case increment, decrement
}

let counterReducer = Reducer<CounterState, CounterAction> { state, action in
    switch action {
    case .increment: state.count += 1
    case .decrement: state.count -= 1
    }
    return .none
}

struct CounterView: View {
    @StateObject var store = Store(CounterState(), counterReducer)
    
    var body: some View {
        VStack {
            Text("\(store.state.count)")
            Button("+") { store.send(.increment) }
        }
    }
}
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
