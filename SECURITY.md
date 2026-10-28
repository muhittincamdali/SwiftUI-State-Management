# Security policy

## Supported versions

Security fixes go into the latest release and the `main` branch.

## Reporting a vulnerability

Report it privately, not in a public issue: open the repository's
[Security tab](https://github.com/muhittincamdali/SwiftUI-State-Management/security) and choose
**Report a vulnerability**, or follow the other channels in the
[security policy of the muhittincamdali repositories](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).
Include a small reducer, view or test that shows the problem and the Swift and OS versions you
ran it on.

## What SwiftUIStateManagement promises

The package runs inside your app and handles only the state, actions and values you give it.
These are the properties a report can hold it to:

- It sends nothing over the network. The only thing it writes to the unified log is a
  `StoreIssue` when you pass no `onIssue` handler, and an issue holds type names only, never the
  values of your state, actions or errors.
- It writes to disk only through a `StateStorage` you create. `FileStorage` accepts key names of
  1 to 128 characters from `A-Z`, `a-z`, `0-9`, `.`, `_` and `-` that do not start with a dot,
  so no name can reach a file outside its directory; it writes atomically and, outside macOS,
  with the `completeUntilFirstUserAuthentication` protection class.
- Reading saved data is bounded: `FileStorage` checks a key's `maxBytes` (1 MiB by default)
  against the file size before reading and reads at most `maxBytes + 1` bytes, every storage
  rejects stored data over the limit, and an encoded value over the limit is never written. Data that does not decode or has another version is reported as a
  `PersistenceError`, never trusted.
- Invalid input does not stop the program: invalid key names and limits throw errors, a
  negative debounce is treated as zero, and a `TestClock` moved backwards records a test
  failure.
- Memory stays bounded: the observation table holds only chains of stored properties of the
  state type, a single `send` processes at most 10,000 actions sent with `Effect.send`, finished
  effects leave the effect table, and `TestStore` failure messages are cut to a fixed size.

State storages are not a place for secrets: keep passwords and tokens in the keychain.
