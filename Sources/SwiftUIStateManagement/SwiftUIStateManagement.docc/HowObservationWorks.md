# How observation works

Which reads make a view update, and how to keep updates small.

## Overview

``Store`` conforms to `Observable` and keeps its own `ObservationRegistrar`, so SwiftUI tracks
the reads a view's body makes through a store the same way it tracks reads of an
`@Observable` class. What differs is the granularity: the state is a value, and the store
decides which part of it a read refers to.

### Reads that are tracked on their own

A read through the store's dynamic members, `store.count`, is tracked for that property alone
when two conditions hold:

- The value's type is `Equatable`, so the store can tell whether it changed.
- The key path is a chain of stored properties of the state struct. The store checks this with
  `MemoryLayout<State>.offset(of:)`, which returns a value only for stored properties.

After each action the store compares, for every tracked key path, the value before and after,
and notifies only the key paths whose values changed. A view that reads `store.count` is not
updated when an action changes only `title`.

### Reads that are tracked as the whole state

These reads are tracked as a read of the whole state, and update on every change:

- ``Store/state``, as in `store.state.count`.
- A computed property, as in `store.isValid`. The store does not evaluate computed properties
  on an old state, because they may not be valid there.
- A subscript or optional chain in the key path, as in `store[dynamicMember: \.items[3]]`. An
  array subscript on an old state could be out of range.
- A value whose type is not `Equatable`.

`store.profile.name` reads `store.profile` and then `name` on the returned value: it is tracked
as a read of `profile`. To track `name` alone, give the child view a scoped store:

```swift
ProfileView(store: store.scope(state: \.profile, action: AppAction.profile))
// In ProfileView, store.name is tracked on its own.
```

### Actions that change nothing

When `State` is `Equatable` and an action leaves it unchanged, the store notifies no one. When
`State` is not `Equatable`, every action notifies the readers of ``Store/state``, but tracked
properties are still compared one by one.

### Keeping updates small

- Make `State` and the types inside it `Equatable`.
- Read the properties a view shows (`store.items`), not ``Store/state``.
- Give child views scoped stores, or pass them plain values.
- Prefer stored properties for values that many views read; compute derived values in the
  reducer when they are expensive or read often.

The tracked key paths are kept in a dictionary that only ever holds chains of stored
properties, so its size is bounded by the shape of the state type, however often views read.
The example app's **Observation** screen shows two cards that each read one property; tapping
one card runs only that card's body.
