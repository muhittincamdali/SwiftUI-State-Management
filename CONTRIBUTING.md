# Contributing to SwiftUI State Management

Thank you for helping. This guide covers what you need to build, test and change the package.

## Ground rules

- Be kind; the [code of conduct](CODE_OF_CONDUCT.md) applies everywhere in the project.
- Report security problems privately, as described in [SECURITY.md](SECURITY.md).
- Open an issue before a large change, so we can agree on the API first.

## Set up

You need Xcode 26 or later (Swift 6.2).

```sh
git clone https://github.com/muhittincamdali/SwiftUI-State-Management.git
cd SwiftUI-State-Management
swift build
swift test
```

Open `Package.swift` in Xcode to work on the library, and
`Examples/StateDemo/StateDemo.xcodeproj` to run the example app.

## Checks to run before a pull request

```sh
swift test
swift test --sanitize=thread
xcodebuild test -scheme SwiftUIStateManagement-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild docbuild -scheme SwiftUIStateManagement-Package -destination 'generic/platform=macOS'
xcodebuild build -project Examples/StateDemo/StateDemo.xcodeproj \
  -scheme StateDemo -destination 'generic/platform=iOS Simulator'
```

CI runs the same steps, builds for tvOS, watchOS and visionOS, and checks links.

## Writing code

- Everything compiles in the Swift 6 language mode without warnings. Reducers, the store and
  effect operations are main-actor isolated; keep it that way.
- The observation rules in `RootCore` are the heart of the package: a key path may only be
  compared on an old state when `MemoryLayout<State>.offset(of:)` says it is a chain of stored
  properties. Add a test in `ObservationTests` for any change there.
- Input from outside the app (saved data, URLs, sizes) is validated and rejected with an error,
  not trapped on. Put a limit on anything that can grow with input.
- Document every public symbol; `xcodebuild docbuild` must report no warnings.

## Writing tests

- Use Swift Testing. Drive time with `TestClock` and `waitForSleepers()`, never with
  `Task.sleep` on the real clock.
- Test features with `TestStore`, and test that `TestStore` itself fails where it should with
  `withKnownIssue`.
- Test the edge cases: cancellation before and during an effect, empty and oversized input,
  values at the limits of `Int`, and state that shrinks while a view observes it.

## README samples

The README's code comes from `Examples/StateDemo/StateDemo/ReadmeSamples.swift`, which the
tests compile through a symbolic link. Change the sample there first, then copy it into the
README. Regenerate the screenshots with `scripts/capture-example-screens.sh` when a demo screen
changes.

## Commits and pull requests

- Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`,
  `test:`, `ci:`), one change per commit, with a body that says why.
- Add a line to the `Unreleased` section of [CHANGELOG.md](CHANGELOG.md) for every change a
  user would notice.
