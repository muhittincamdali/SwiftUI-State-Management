# Navigation state

Drive navigation stacks, sheets and alerts from state, handle deep links, and restore the
screen the user left.

## Overview

Navigation is state like any other: an array for a `NavigationStack`, an optional for a sheet
or an alert. The reducer pushes, presents and dismisses by changing that state, and the view
turns it into bindings with `binding(_:send:)`,
``Store/binding(_:dismiss:)`` and ``Store/isPresented(_:dismiss:)``. Because everything is
state, deep links and tests need no view.

### Stacks

Keep the stack as an array of `Hashable` values and send an action when SwiftUI changes it,
for example when the user taps the back button:

```swift
struct State: Equatable {
    var contacts: [Contact] = []
    var path: [Contact.ID] = []
}

enum Action: Equatable {
    case pathChanged([Contact.ID])
    case contactTapped(Contact.ID)
    // ...
}

// In the reducer:
case .pathChanged(let path):
    state.path = path
case .contactTapped(let id):
    state.path.append(id)
```

```swift
NavigationStack(path: store.binding(\.path, send: Contacts.Action.pathChanged)) {
    List(store.contacts) { contact in
        Button(contact.name) { store.send(.contactTapped(contact.id)) }
    }
    .navigationDestination(for: Contacts.Contact.ID.self) { id in
        ContactView(store: store, id: id)
    }
}
```

For screens of different types on one stack, use an enum with a case per screen as the element
type.

### Sheets, popovers and full-screen covers

Present with optional state. The reducer sets it to show the sheet and to `nil` to dismiss it.
When the user swipes the sheet down, SwiftUI writes `nil` to the binding and the store receives
the `dismiss` action:

```swift
.sheet(item: store.binding(\.newContact, dismiss: .newContactDismissed)) { _ in
    NewContactForm(store: store)
}
```

The item must be `Identifiable`. Writes other than `nil` are ignored, and `dismiss` is not sent
when the state is already `nil`.

### Alerts and confirmation dialogs

``Store/isPresented(_:dismiss:)`` gives the `Bool` binding that `alert` and
`confirmationDialog` take, `true` while the optional state holds a value:

```swift
.alert(
    "Delete \(store.clearConfirmation?.count ?? 0) completed todos?",
    isPresented: store.isPresented(\.clearConfirmation, dismiss: .clearCompletedDismissed)
) {
    Button("Delete", role: .destructive) { store.send(.clearCompletedConfirmed) }
}
```

### One destination out of several

When a screen can present one of several things, model them as an enum and present each case
through an optional computed property:

```swift
enum Destination: Equatable {
    case editor(Editor)
    case share(ShareSheet)

    var editor: Editor? {
        if case .editor(let editor) = self { editor } else { nil }
    }
}

.sheet(item: store.binding(\.destination?.editor, dismiss: .destinationDismissed)) { editor in
    EditorView(editor: editor)
}
```

The enum makes it impossible to show two destinations at once.

### Deep links

A deep link is an action. Validate the URL in the reducer and change the navigation state:

```swift
case .openURL(let url):
    // statedemo://todos/<id> opens a todo; anything else is ignored.
    guard let id = TodoLink.todoID(in: url), state.todo(id) != nil else { return .none }
    state.filter = .all
    state.path = [id]
```

```swift
.onOpenURL { url in store.send(.openURL(url)) }
```

Treat every URL as untrusted input: accept only the scheme, host and path shape you expect,
check that the item exists, and cap the depth of the stack you build from it. The example
app's `TodoLink` and `Todos` show this, with tests for links that must be ignored.

### Restoring the screen the user left

Save the stack with ``Reducer/persisting(_:to:in:debounce:clock:flush:onError:)`` and
validate it when you load it: drop ids whose items no longer exist and cap the depth.

```swift
static func restored(items: [Todo], path: [Todo.ID]) -> State {
    let ids = Set(items.map(\.id))
    return State(items: items, path: Array(path.filter(ids.contains).prefix(maximumPathDepth)))
}
```

See <doc:PersistingState> for saving and loading.

### Testing navigation

Navigation changes are state changes, so a `TestStore` checks them like any other:

```swift
await store.send(.contactTapped(1)) { $0.path = [1] }
await store.send(.pathChanged([])) { $0.path = [] }
await store.send(.addTapped) { $0.newContact = Contacts.NewContact(id: 2) }
await store.send(.newContactDismissed) { $0.newContact = nil }
```
