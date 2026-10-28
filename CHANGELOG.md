# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-28

A rewrite on the Observation framework. The sources on `main` since
June 2026 were a one-line `ObservableObject` store and unrelated stubs, and the README
described APIs that did not exist. Nothing from 1.x is kept; every API in the README now exists,
compiles and is tested.

### Added

- `Reducer`, `Reduce`, `CombinedReducer` and `Scope`: a feature's logic as a synchronous
  function of state and action that returns an `Effect`; child features run on part of the
  parent's state.
- `Effect` (`none`, `send`, `run` with or without an id and `cancelInFlight`, `cancel(id:)`,
  `merge`, `map`) and `Send`, which ignores actions once its task is cancelled.
- `Store`, which implements `Observable` and tracks reads of `Equatable` stored properties one
  by one, `scope(state:action:)`, `StoreTask` (`finish()`, `cancel()`) and `StoreIssue` for
  unhandled effect errors and runaway `Effect.send` loops (type names only, never values).
- SwiftUI bindings: `binding(_:send:)`, `binding(_:dismiss:)` for sheets and other optional
  presentations, `isPresented(_:dismiss:)` for alerts, and `send(_:animation:)`.
- Persistence: `StateStorage` with `FileStorage`, `UserDefaultsStorage` and `InMemoryStorage`;
  `PersistenceKey` with a format version, a size limit (1 MiB by default), name validation and
  migration; `PersistenceError`; and `Reducer.persisting(_:to:in:debounce:clock:flush:onError:)`,
  which writes changes off the main actor, in order.
- `SwiftUIStateManagementTesting`, a second library with `TestStore` for exhaustive tests of
  state changes and received actions, and `TestClock`. Failures go to Swift Testing or XCTest.
- DocC catalogs with seven articles, among them "How observation works" and "Choosing an
  approach", which compares plain `@Observable` models, this package and The Composable
  Architecture.
- `Examples/StateDemo`, an iOS and macOS app with todos (persistence, a restored navigation
  stack, a sheet, an alert and deep links), a debounced search, the quick start counter and a
  screen that shows per-property observation. The README samples live in its
  `ReadmeSamples.swift`, which the test suite compiles and runs.
- CI through the shared workflows of `muhittincamdali/.github`: `swift test` on macOS, builds
  for iOS, macOS, tvOS, watchOS and visionOS, tests on an iOS simulator, the example app,
  DocC, link, hygiene and translation checks.

### Changed

- Requires Swift 6.2 (Xcode 26) and the Swift 6 language mode; minimum platforms are iOS 17,
  macOS 14, tvOS 17, watchOS 10 and visionOS 1 (the first releases with Observation).

### Removed

- The 1.x store (`ObservableObject` with `@Published`), `TimeTravelPlugin`, and the
  `CircuitBreaker`, `RetryPolicy`, `ErrorHandler`, `EventBus` and `MetricsCollector` stubs.
  For retries and circuit breaking in effects, see
  [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency).
- CocoaPods support (`SwiftUIStateManagement.podspec`) and the SwiftLint configuration that no
  workflow ran.

## [1.0.0] - 2026-02-03

First tagged version: a Swift 5.7 `ObservableObject` store with reducers, middleware, a
`ViewStore` and a `TestStore`. It is superseded by the rewrite above.

[Unreleased]: https://github.com/muhittincamdali/SwiftUI-State-Management/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/SwiftUI-State-Management/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/SwiftUI-State-Management/releases/tag/v1.0.0
