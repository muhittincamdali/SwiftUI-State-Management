# Migration Guide: From TCA to SwiftUI State Management

This guide helps you migrate from The Composable Architecture (TCA) to SwiftUI State Management. Both libraries share similar concepts, making migration straightforward.

## Overview

| TCA | SwiftUI State Management |
|-----|--------------------------|
| `Reducer` | `Reducer` |
| `Effect` | `Effect` |
| `Store` | `Store` |
| `ViewStore` | Direct `@ObservedObject` on Store |
| `ReducerProtocol` | `Feature` protocol |
| `@Dependency` | `Dependencies` |
| `TestStore` | `TestStore` |

## Key Differences

### 1. Simpler API

**TCA:**
```swift
@Reducer
struct Feature {
    struct State: Equatable {
        var count = 0
    }
    
    enum Action {
        case increment
        case decrement
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
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
}
```

**SwiftUI State Management:**
```swift
struct AppState: Equatable {
    var count = 0
}

enum AppAction {
    case increment
    case decrement
}

let appReducer = Reducer<AppState, AppAction> { state, action in
    switch action {
    case .increment:
        state.count += 1
        return .none
    case .decrement:
        state.count -= 1
        return .none
    }
}
```

### 2. No ViewStore Required

**TCA:**
```swift
struct CounterView: View {
    let store: StoreOf<Counter>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("\(viewStore.count)")
                Button("+") { viewStore.send(.increment) }
            }
        }
    }
}
```

**SwiftUI State Management:**
```swift
struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack {
            Text("\(store.state.count)")
            Button("+") { store.send(.increment) }
        }
    }
}
```

### 3. Effects Migration

**TCA:**
```swift
case .fetchUser:
    return .run { send in
        let user = try await apiClient.fetchUser()
        await send(.userLoaded(user))
    }
```

**SwiftUI State Management:**
```swift
case .fetchUser:
    return .task {
        let user = try await apiClient.fetchUser()
        return .userLoaded(user)
    }
```

### 4. Effect Cancellation

**TCA:**
```swift
case .search(let query):
    return .run { send in
        let results = try await api.search(query)
        await send(.searchResults(results))
    }
    .cancellable(id: CancelID.search)

case .cancelSearch:
    return .cancel(id: CancelID.search)
```

**SwiftUI State Management:**
```swift
case .search(let query):
    return .task(id: "search") {
        let results = try await api.search(query)
        return .searchResults(results)
    }

case .cancelSearch:
    return .cancel(id: "search")
```

### 5. Debouncing

**TCA:**
```swift
case .textChanged(let text):
    return .run { send in
        try await clock.sleep(for: .milliseconds(300))
        await send(.search(text))
    }
    .cancellable(id: CancelID.debounce)
```

**SwiftUI State Management:**
```swift
case .textChanged(let text):
    return .debounce(
        duration: 0.3,
        id: "search-debounce",
        effect: .task { .search(text) }
    )
```

## Step-by-Step Migration

### Step 1: Replace Reducer Definition

```swift
// Before (TCA)
@Reducer
struct Feature {
    struct State: Equatable { ... }
    enum Action { ... }
    var body: some ReducerOf<Self> {
        Reduce { state, action in ... }
    }
}

// After
struct FeatureState: Equatable { ... }
enum FeatureAction { ... }

let featureReducer = Reducer<FeatureState, FeatureAction> { state, action in
    ...
}
```

### Step 2: Replace Store Creation

```swift
// Before (TCA)
let store = Store(initialState: Feature.State()) {
    Feature()
}

// After
let store = Store(
    initialState: FeatureState(),
    reducer: featureReducer
)
```

### Step 3: Update Views

```swift
// Before (TCA)
WithViewStore(store, observe: { $0 }) { viewStore in
    Text("\(viewStore.count)")
    Button("Increment") { viewStore.send(.increment) }
}

// After
Text("\(store.state.count)")
Button("Increment") { store.send(.increment) }
```

### Step 4: Migrate Effects

```swift
// Before (TCA)
return .run { send in
    let data = try await api.fetch()
    await send(.dataLoaded(data))
}

// After
return .task {
    let data = try await api.fetch()
    return .dataLoaded(data)
}
```

### Step 5: Update Tests

```swift
// Before (TCA)
@MainActor
func testIncrement() async {
    let store = TestStore(initialState: Feature.State()) {
        Feature()
    }
    
    await store.send(.increment) {
        $0.count = 1
    }
}

// After
@MainActor
func testIncrement() async {
    let store = TestStore(
        initialState: FeatureState(count: 0),
        reducer: featureReducer
    )
    
    await store.send(.increment) {
        $0.count = 1
    }
}
```

## Feature Comparison

| Feature | TCA | SwiftUI SM |
|---------|-----|------------|
| Unidirectional data flow | ✅ | ✅ |
| Type-safe state | ✅ | ✅ |
| Effect system | ✅ | ✅ |
| Cancellation | ✅ | ✅ |
| Debounce/Throttle | Via Clock | Built-in |
| Test support | ✅ | ✅ |
| Time-travel debugging | Via Instruments | Built-in |
| State diff viewer | ❌ | ✅ |
| Visual debugger | ❌ | ✅ |
| Performance monitoring | ❌ | ✅ |
| Middleware system | Via Higher-order reducers | Built-in |
| Learning curve | Steep | Gentle |
| Boilerplate | More | Less |

## Why Migrate?

### 1. Simpler API
- No ViewStore ceremony
- Direct store access in views
- Less boilerplate code

### 2. Built-in DevTools
- Visual state debugger
- State diff viewer
- Performance monitoring
- Time-travel built into Store

### 3. Better Performance
- Lighter weight implementation
- No observation overhead
- Efficient state updates

### 4. Easier Testing
- Same testing patterns as TCA
- Built-in snapshot support
- Simpler test setup

### 5. Gradual Migration
- Can coexist with TCA
- Migrate one feature at a time
- Similar concepts make it easy

## Common Patterns

### Binding to State

**TCA:**
```swift
TextField("Name", text: viewStore.binding(
    get: \.name,
    send: Feature.Action.nameChanged
))
```

**SwiftUI State Management:**
```swift
TextField("Name", text: store.binding(
    get: \.name,
    send: { .nameChanged($0) }
))
```

### Child Features

**TCA:**
```swift
Scope(state: \.child, action: \.child) {
    ChildFeature()
}
```

**SwiftUI State Management:**
```swift
let childStore = store.scope(
    state: { $0.child },
    action: { .child($0) }
)
```

### Composition

**TCA:**
```swift
var body: some ReducerOf<Self> {
    Scope(state: \.feature1, action: \.feature1) { Feature1() }
    Scope(state: \.feature2, action: \.feature2) { Feature2() }
    Reduce { state, action in ... }
}
```

**SwiftUI State Management:**
```swift
let appReducer = Reducer<AppState, AppAction>.combine(
    feature1Reducer.pullback(state: \.feature1, action: /AppAction.feature1),
    feature2Reducer.pullback(state: \.feature2, action: /AppAction.feature2),
    Reducer { state, action in ... }
)
```

## Need Help?

- [Documentation](../README.md)
- [Examples](../Examples/)
- [GitHub Issues](https://github.com/muhittinpalamutcu/SwiftUI-State-Management/issues)
