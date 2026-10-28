# Effects and cancellation

Start asynchronous work from a reducer, feed its results back, and cancel what is no longer
needed.

## Overview

A reducer cannot `await`. It returns an ``Effect``, and the store runs the effect after the
state has changed. Each ``Effect/run(priority:operation:catch:)`` becomes a task on the main
actor; its `send` function feeds actions back into the reducer.

### Kinds of effects

| Effect                                                    | What the store does                             |
| --------------------------------------------------------- | ----------------------------------------------- |
| ``Effect/none``                                             | Nothing.                                        |
| ``Effect/send(_:)``                                         | Processes the action before `send` returns.     |
| ``Effect/run(priority:operation:catch:)``                   | Starts a task.                                  |
| ``Effect/run(id:cancelInFlight:priority:operation:catch:)`` | Starts a task labelled with an identifier.      |
| ``Effect/cancel(id:)``                                      | Cancels the running tasks with that identifier. |
| ``Effect/merge(_:)-(Effect...)``                    | Runs several effects.                           |
| ``Effect/map(_:)``                                          | Wraps a child's actions in a parent's actions.  |

### Errors

An error thrown by `operation` goes to the `catch` handler, which usually sends an action:

```swift
return .run { [api] send in
    send(.itemsLoaded(try await api.items()))
} catch: { error, send in
    send(.loadFailed)
}
```

A `CancellationError`, and any error thrown after the task was cancelled, is ignored. Without a
handler the store reports a ``StoreIssue``: in an app it is written to the unified log, and in a
test with `TestStore` the test fails.

### Cancel by identifier

Label an effect with an identifier to cancel it later. Any `Hashable` and `Sendable` value
works; a private enum keeps identifiers unique to the feature:

```swift
enum CancelID { case search }

case .queryChanged(let query):
    state.query = query
    guard !query.isEmpty else {
        state.results = []
        return .cancel(id: CancelID.search)
    }
    return .run(id: CancelID.search, cancelInFlight: true) { [search, clock] send in
        try await clock.sleep(for: .milliseconds(300))
        send(.resultsLoaded(try await search(query)))
    }
```

With `cancelInFlight: true`, each keystroke cancels the previous search before starting the
new one, and the 300 ms sleep turns that into a debounce: only a query the user stopped typing
for 300 ms reaches the server.

After a task is cancelled, its ``Send`` ignores the actions it is given. A response that
arrives after the user typed again can never overwrite the newer results.

### Effects tied to a view

``Store/send(_:)`` returns a ``StoreTask``. Awaiting ``StoreTask/finish()`` in a view's `task`
ties the effect to the view: when the view disappears, SwiftUI cancels the `task`, and
`finish()` cancels the effect.

```swift
.task { await store.send(.startObservingLocation).finish() }
.refreshable { await store.send(.refresh).finish() }
```

### Clocks

Pass time-based dependencies as `any Clock<Duration>`: `ContinuousClock()` in the app and a
`TestClock` in tests, so a test of a 300 ms debounce does not wait 300 ms.

### What runs where

Operations run on the main actor, so they may read and write main-actor state of your own, but
should `await` slow work in an `actor`, a `@concurrent` function, or a client that does its
work elsewhere. Every effect is cancelled when its store is deallocated.

### Limits

A single `send` processes at most 10,000 actions sent with ``Effect/send(_:)``. Beyond that the
store drops the rest and reports
``StoreIssue/Kind/synchronousActionLimitExceeded(limit:)``: two actions that send each other
forever are a bug, and the limit turns a frozen app into a report.
