# Choosing an approach

When plain `@Observable` models are enough, when this package helps, and when The Composable
Architecture is the better choice.

## Overview

There are three common ways to manage state in a SwiftUI app on iOS 17 and later. They are not
ranked; each fits a different app and team.

### Plain @Observable models

An `@Observable` class with methods that change its properties is the approach Apple's
documentation teaches. It needs no package, every Swift developer can read it, and Observation
tracks each property on its own. Choose it when screens are small, when async work is a few
`Task`s, and when the tests you need call methods and check properties.

What it does not give you: one place where every change happens, a list of the events a screen
handles, cancellation of in-flight work by identifier, and tests that fail when a change you
did not expect happens.

### This package

SwiftUIStateManagement adds those things on top of Observation with a small surface: a
``Reducer`` protocol, a ``Store``, ``Effect``, bindings for navigation, persistence, and a
`TestStore`. It has no dependencies and no macros. Dependencies are stored properties of the
reducer, passed in by whoever creates it.

Choose it when you want unidirectional flow and exhaustive tests, and want to read and debug
every line of the library you depend on.

### The Composable Architecture

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
(TCA) by Point-Free is the established library for this style. Compared with this package it
offers much more:

- Macros (`@Reducer`, `@ObservableState`, `@Presents`, `@CasePathable`) that remove the
  boilerplate this package leaves to you, such as the closure that extracts a child action in
  ``Scope``, and give field-level observation of nested state.
- A dependency system (`@Dependency`) with live, preview and test values, and a test store that
  fails when a test uses a dependency it did not override.
- Navigation tools for stacks and tree-based presentation (`StackState`, `@Presents`,
  `PresentationAction`) with dismissal from child features.
- Shared state across features and persistence strategies through Swift Sharing (`@Shared`
  with `.appStorage` and `.fileStorage`).
- Non-exhaustive testing, case key paths, identified arrays, extensive documentation, video
  series, and a large community.

The cost is a larger learning curve, a dependency on about fifteen packages including
swift-syntax for the macros, and more code generated at build time.

**Use TCA instead of this package when** your app has many features that share state or
dependencies, when your team already knows TCA, when you need its navigation or dependency
tools, or when you want a library with years of production use behind it.

### Moving between them

The shapes are close on purpose: a ``Reducer`` with `State`, `Action` and `reduce(into:action:)`,
effects with `.run`, `.send`, `.cancel(id:)`, and a `TestStore` with `send` and `receive`. A
feature written with this package moves to TCA by adding the macros and replacing stored
dependencies with `@Dependency`, and the reverse works the same way.
