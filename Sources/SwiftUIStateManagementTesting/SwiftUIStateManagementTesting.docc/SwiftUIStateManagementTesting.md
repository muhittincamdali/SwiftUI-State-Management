# ``SwiftUIStateManagementTesting``

Exhaustive tests for reducers and their effects, and a clock that tests control.

## Overview

Add this library to your test target. ``TestStore`` runs a reducer and fails the test when a
state change or an action sent by an effect differs from what the test describes. ``TestClock``
lets a test end a debounce, a timeout or a retry delay without waiting.

```swift
@MainActor
@Test func loadsAFact() async {
    let store = TestStore(
        initialState: Counter.State(),
        reducer: Counter(facts: NumberFacts { "\($0) is a good number." })
    )
    await store.send(.factTapped) { $0.isLoadingFact = true }
    await store.receive(.factLoaded("0 is a good number.")) {
        $0.isLoadingFact = false
        $0.fact = "0 is a good number."
    }
}
```

Failures are recorded with Swift Testing when a Swift Testing test is running, and with
`XCTFail` in an XCTest test case.

## Topics

### Testing a feature

- ``TestStore``

### Controlling time

- ``TestClock``
