# Persisting state

Save part of a feature's state to disk after each change and load it at launch, with versions,
size limits and validation.

## Overview

Persistence has three parts: a ``PersistenceKey`` that names a value, a ``StateStorage`` that
holds bytes, and ``Reducer/persisting(_:to:in:debounce:clock:flush:onError:)``, which saves the
value after each action that changes it.

### Name the value

```swift
extension PersistenceKey where Value == [Todo] {
    static let todos = PersistenceKey("todos", version: 1)
}
```

A key name is 1 to 128 characters from `A-Z`, `a-z`, `0-9`, `.`, `_` and `-`, and does not start
with a dot. The value is stored as JSON in an envelope that records the version:

```json
{
    "value": [
        { "id": "…", "isDone": false, "notes": "", "title": "Buy oat milk" }
    ],
    "version": 1
}
```

### Choose a storage

| Storage               | Use it for                                                                   |
| --------------------- | ---------------------------------------------------------------------------- |
| ``FileStorage``         | Lists, documents, anything that grows. One file per key, written atomically. |
| ``UserDefaultsStorage`` | Small settings, or values shared with a widget through an app group suite.   |
| ``InMemoryStorage``     | Tests and SwiftUI previews.                                                  |

```swift
let storage = try FileStorage.applicationSupport(subdirectory: "State")
```

### Load at launch, save on change

Load the saved value when you create the store, and let the reducer save the changes:

```swift
let items = (try? storage.load(.todos)) ?? []
let store = Store(
    initialState: Todos.State(items: items),
    reducer: Todos(makeID: UUID.init)
        .persisting(\.items, to: .todos, in: storage, debounce: .seconds(1))
)
```

The reducer compares the value before and after each action with `==` and saves only when it
changed, so `==` must compare every property that is saved. A type whose `==` compares only an
`id` is not written when only its other properties change.
Saving is an effect: it encodes and writes off the main actor. Writes for the same key keep
their order, so a slow write can never replace a newer value with an older one.

### Debounce and flush

With a `debounce`, a burst of changes, such as typing in a text field, is written once, after
the value has stopped changing for that long. A pending write would be lost if the app were
terminated in the meantime, so pass `flush` to write at once on the action your app sends when
its scene moves to the background:

```swift
.persisting(\.items, to: .todos, in: storage, debounce: .seconds(1), flush: { $0 == .movedToBackground })
```

```swift
.onChange(of: scenePhase) { _, phase in
    if phase == .background { store.send(.movedToBackground) }
}
```

SwiftUI apps run on the scene-based life cycle, and `scenePhase` is the place to react to it.

### Failures

``StateStorage/load(_:)`` returns `nil` when nothing is saved and throws a
``PersistenceError`` when the data cannot be used:

| Error                                                | Cause                                        |
| ---------------------------------------------------- | -------------------------------------------- |
| ``PersistenceError/invalidKey(_:)``                    | The name or the size limit is not valid.     |
| ``PersistenceError/tooLarge(byteCount:limit:)``        | The saved data is over the key's `maxBytes`. |
| ``PersistenceError/versionMismatch(stored:expected:)`` | Another version, and no `migrate` closure.   |
| ``PersistenceError/corrupted``                         | Not an envelope, or it does not decode.      |

Decide what a failure means for each value; for most, starting from the default is right:
`(try? storage.load(.todos)) ?? []`.

A failed save becomes the action you return from `onError`, or a ``StoreIssue`` when you pass
none.

### Change the format

When a new version of your app changes `Value` so that old data no longer decodes, raise the
version and convert the old data:

```swift
static let settings = PersistenceKey<Settings>("settings", version: 2) { storedVersion, json in
    let old = try JSONDecoder().decode(SettingsV1.self, from: json)
    return Settings(showsCompleted: old.showsDone)
}
```

### Limits and validation

- Each key has a size limit, 1 MiB by default. ``FileStorage`` checks the file size before
  reading and reads at most `maxBytes + 1` bytes, so a damaged or replaced file cannot make the
  app read a huge file into memory. A value over the limit is never written.
- Names are checked by the key and again by ``FileStorage``, so no name, including one built
  from user input, can reach a file outside the storage's directory.
- Validate what you load as you would validate input: the example app drops saved navigation
  ids whose todo no longer exists and caps the stack depth.

Files written by ``FileStorage`` on iOS, iPadOS, tvOS, watchOS and visionOS use the
`completeUntilFirstUserAuthentication` data protection class. Do not store secrets in a state
storage; use the keychain for passwords and tokens.
