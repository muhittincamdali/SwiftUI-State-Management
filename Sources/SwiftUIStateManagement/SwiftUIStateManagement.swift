// SwiftUI State Management
// Copyright (c) 2024 Muhittin Palamutcu
// MIT License

/// # SwiftUI State Management
///
/// A lightweight, TCA-inspired state management library for SwiftUI.
/// Provides unidirectional data flow, effects, middleware, and powerful debugging tools.
///
/// ## Quick Start
///
/// ```swift
/// // 1. Define your state
/// struct AppState: Equatable {
///     var count = 0
///     var isLoading = false
/// }
///
/// // 2. Define your actions
/// enum AppAction {
///     case increment
///     case decrement
///     case loadData
///     case dataLoaded(Result<Data, Error>)
/// }
///
/// // 3. Create a reducer
/// let appReducer = Reducer<AppState, AppAction> { state, action in
///     switch action {
///     case .increment:
///         state.count += 1
///         return .none
///
///     case .decrement:
///         state.count -= 1
///         return .none
///
///     case .loadData:
///         state.isLoading = true
///         return .task {
///             let data = try await api.fetchData()
///             return .dataLoaded(.success(data))
///         }
///
///     case .dataLoaded(let result):
///         state.isLoading = false
///         // Handle result...
///         return .none
///     }
/// }
///
/// // 4. Create the store
/// let store = Store(
///     initialState: AppState(),
///     reducer: appReducer
/// )
///
/// // 5. Use in SwiftUI
/// struct ContentView: View {
///     @ObservedObject var store: Store<AppState, AppAction>
///
///     var body: some View {
///         VStack {
///             Text("Count: \(store.state.count)")
///             Button("+") { store.send(.increment) }
///             Button("-") { store.send(.decrement) }
///         }
///     }
/// }
/// ```
///
/// ## Features
///
/// - **Unidirectional Data Flow**: State → View → Action → Reducer
/// - **Type-Safe**: Compile-time guarantees for state and actions
/// - **Effects**: Async side effects with cancellation support
/// - **Middleware**: Intercept and transform actions
/// - **Time-Travel Debugging**: Step through state history
/// - **Performance Monitoring**: Track reducer and effect performance
/// - **Visual Debugger**: SwiftUI-based debugging overlay
/// - **Testing**: Comprehensive test utilities
///
/// ## Documentation
///
/// - [README](https://github.com/muhittinpalamutcu/SwiftUI-State-Management)
/// - [TCA Migration Guide](Documentation/TCA_MIGRATION.md)
/// - [Examples](Examples/)

// MARK: - Core

@_exported import Foundation
@_exported import SwiftUI
@_exported import Combine

// MARK: - Public API

// Core Types
public typealias ReducerOf<S, A> = Reducer<S, A>
public typealias StoreOf<S, A> = Store<S, A>
public typealias EffectOf<A> = Effect<A>
public typealias MiddlewareOf<S, A> = AnyMiddleware<S, A>

// MARK: - Version

/// The current version of SwiftUI State Management.
public let version = "2.0.0"

/// Build information.
public struct BuildInfo {
    public static let version = "2.0.0"
    public static let buildDate = "2024"
    public static let minimumSwiftVersion = "5.7"
    public static let minimumPlatforms = "iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0"
}
