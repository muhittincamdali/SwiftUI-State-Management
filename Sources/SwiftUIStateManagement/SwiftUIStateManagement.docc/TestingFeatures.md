# Testing features

Test reducers exhaustively with `TestStore`, control time with `TestClock`, or test with the
real store.

## Overview

The `SwiftUIStateManagementTesting` library, which you add to your test target, has two types:

- `TestStore` runs a reducer like a ``Store`` and checks every state change and every action an
  effect sends.
- `TestClock` is a `Clock` whose time moves only when the test says so.

Both work with Swift Testing and with XCTest.

### Exhaustive tests with TestStore

Send an action and describe how the state changes; receive each action that an effect sends
back, in order:

```swift
import SwiftUIStateManagementTesting
import Testing
@testable import MyApp

@MainActor
@Test func loadsAFact() async {
    let store = TestStore(
        initialState: Counter.State(),
        reducer: Counter(facts: NumberFacts { "\($0) is a good number." })
    )
    await store.send(.incrementTapped) { $0.count = 1 }
    await store.send(.factTapped) { $0.isLoadingFact = true }
    await store.receive(.factLoaded("1 is a good number.")) {
        $0.isLoadingFact = false
        $0.fact = "1 is a good number."
    }
}
```

The test fails when:

- the state changes differently from the closure (the message shows the lines that differ),
- an effect sends another action than the one you expect, or none in time,
- you send an action while received actions are still unchecked,
- the test ends with unchecked actions or effects still running,
- an effect throws an error it does not handle.

`State` must be `Equatable`. `receive(_:)` needs an `Equatable` action; use
`receive(matching:)` otherwise.

### Time

Inject a clock into features that sleep, and pass a `TestClock` in tests. Wait until the effect
has started sleeping, then move time:

```swift
let clock = TestClock()
let store = TestStore(
    initialState: Search.State(),
    reducer: Search(search: { ["\($0) result"] }, clock: clock)
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
```

`waitForSleepers()` matters because effects start in their own tasks: advancing before the
sleep has begun would move time past a deadline that does not exist yet.

### Long-living effects

An effect that never ends on its own, such as one that listens to notifications, must be
cancelled before the test ends. Cancel the ``StoreTask`` that `send` returns, send the action
that cancels it, or call `cancelInFlightEffects()`. `finish()` waits until all effects are done
and fails after its timeout.

### Testing with the real store

When you only care about the end result, use a ``Store`` and await the effects of a send:

```swift
let store = Store(initialState: Counter.State(count: 4), reducer: Counter(facts: facts))
await store.send(.factTapped).finish()
#expect(store.fact == "4 is a test number.")
```

### Testing the reducer alone

A reducer is a value with a method; call it directly to test pure logic:

```swift
var state = Todos.State()
_ = Todos(makeID: { id }).reduce(into: &state, action: .addTapped)
#expect(state.editor?.id == id)
```
