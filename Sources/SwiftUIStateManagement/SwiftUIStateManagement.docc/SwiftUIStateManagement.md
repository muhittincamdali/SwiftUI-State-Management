# ``SwiftUIStateManagement``

Unidirectional state for SwiftUI on top of the Observation framework: stores you can test,
navigation as state, and persistence, in a small package without dependencies.

## Overview

A feature is a ``Reducer``: a value type with a `State`, an `Action` and one method that
changes the state for an action and returns an ``Effect`` for the asynchronous work. A
``Store`` runs it on the main actor and lets SwiftUI observe the result:

```swift
import SwiftUIStateManagement

struct CounterView: View {
    let store: Store<Counter.State, Counter.Action>

    var body: some View {
        Stepper("Count: \(store.count)") {
            store.send(.incrementTapped)
        } onDecrement: {
            store.send(.decrementTapped)
        }
    }
}
```

The store implements `Observable` with field-level tracking: a view that reads `store.count`
updates when `count` changes and not when another property does, without macros or a special
state type. Effects run as tasks you can cancel by identifier; navigation stacks, sheets and
alerts are optional or array state with bindings that send actions; ``Reducer/persisting(_:to:in:debounce:clock:flush:onError:)``
saves part of the state after each change. The `SwiftUIStateManagementTesting` library adds
`TestStore` and `TestClock` for exhaustive tests of state changes and effects.

The package targets iOS 17, macOS 14, tvOS 17, watchOS 10 and visionOS 1 or later, the first
releases with Observation, and builds in the Swift 6 language mode.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:HowObservationWorks>
- <doc:ChoosingAnApproach>

### Guides

- <doc:EffectsAndCancellation>
- <doc:NavigationState>
- <doc:PersistingState>
- <doc:TestingFeatures>

### Features

- ``Reducer``
- ``Reduce``
- ``Scope``
- ``CombinedReducer``

### Stores

- ``Store``
- ``StoreTask``
- ``StoreIssue``

### Effects

- ``Effect``
- ``Send``

### Persistence

- ``StateStorage``
- ``PersistenceKey``
- ``PersistenceError``
- ``FileStorage``
- ``UserDefaultsStorage``
- ``InMemoryStorage``
- ``PersistingReducer``
