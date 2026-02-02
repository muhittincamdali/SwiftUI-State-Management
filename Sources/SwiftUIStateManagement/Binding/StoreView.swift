import SwiftUI

// MARK: - StoreView

/// A convenience SwiftUI view that automatically creates and manages
/// a `ViewStore` from a `Store`, reducing boilerplate in view code.
///
/// Usage:
/// ```swift
/// StoreView(store: appStore) { viewStore in
///     VStack {
///         Text(viewStore.state.title)
///         Button("Tap") { viewStore.send(.tapped) }
///     }
/// }
/// ```
public struct StoreView<State, Action, Content: View>: View {

    // MARK: - Properties

    @ObservedObject private var viewStore: ViewStore<State, Action>

    /// The content builder closure.
    private let content: (ViewStore<State, Action>) -> Content

    // MARK: - Initialization

    /// Creates a StoreView with a store and content builder.
    ///
    /// - Parameters:
    ///   - store: The backing store.
    ///   - content: A closure building the view with access to the ViewStore.
    public init(
        store: Store<State, Action>,
        @ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
    ) {
        self.viewStore = ViewStore(store)
        self.content = content
    }

    /// Creates a StoreView with a scoped store.
    public init(
        scopedStore: ScopedStore<State, Action>,
        @ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
    ) {
        self.viewStore = ViewStore(scopedStore)
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        content(viewStore)
    }
}

// MARK: - Previews Helper

#if DEBUG
extension StoreView {
    /// Creates a StoreView with a static state for SwiftUI previews.
    public static func preview(
        state: State,
        @ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
    ) -> some View where State: Equatable {
        let store = Store(
            initialState: state,
            reducer: Reducer { _, _ in .none }
        )
        return StoreView(store: store, content: content)
    }
}
#endif
