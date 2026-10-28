# Examples

## StateDemo

A small iOS and macOS app with one tab per topic, each built on the library in this checkout:

- **Todos** — a list saved to disk with `FileStorage` and `persisting(_:to:in:)` (debounced by
  one second, flushed when the scene moves to the background), a `NavigationStack` driven by
  an array in the state and restored at launch, a sheet for new todos, an alert before clearing
  completed todos, and deep links: `statedemo://todos/<id>` opens a todo, and every other URL is
  ignored.
- **Search** — each keystroke cancels the waiting search with `cancelInFlight`; only a query you
  stopped typing for 300 ms runs.
- **Counter** — the quick start of the README: a stepper and a fact loaded by an effect.
- **Observation** — two cards that each read one property through the store and show how often
  their body ran: tapping one card runs only that card's body.

The logic of each screen is a `Reducer` in
[ReadmeSamples.swift](StateDemo/StateDemo/ReadmeSamples.swift),
[TodosFeature.swift](StateDemo/StateDemo/TodosFeature.swift) and
[DemoScreens.swift](StateDemo/StateDemo/DemoScreens.swift). The package's test target compiles
the first two files and tests them, so the README samples are tested code.

The app uses the package from this checkout (a local package reference to `../..`), so it
always shows the current code.

Run it:

1. Open `Examples/StateDemo/StateDemo.xcodeproj` in Xcode 26 or later.
2. Choose the **StateDemo** scheme and an iPhone simulator or **My Mac** as the run destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/StateDemo
xcodebuild build -scheme StateDemo -destination 'generic/platform=iOS Simulator'
```

To try a deep link on a running simulator, copy a todo's link with **Share a link to this
todo** on its screen, or open one directly:

```sh
xcrun simctl openurl booted "statedemo://todos/6F9619FF-8B86-D011-B42D-00C04FC964F2"
```

The link above opens a todo only in the sample data that the screenshot scenarios load
(`-demo todos`); in your own data, use the link from the share button.

The project file is generated from [project.yml](StateDemo/project.yml) with XcodeGen and
committed, so XcodeGen is only needed after changing `project.yml`.
