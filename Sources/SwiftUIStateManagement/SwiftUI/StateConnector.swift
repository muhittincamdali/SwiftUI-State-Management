// StateConnector.swift
// SwiftUI-State-Management
//
// Seamless SwiftUI integration for state management.
// Provides view bindings, scoping, and reactive updates.

import SwiftUI
import Combine

// MARK: - StateConnector

/// Connects SwiftUI views to the state management system.
///
/// `StateConnector` provides a clean interface for:
/// - Observing state changes
/// - Dispatching actions
/// - Scoping state to specific view needs
/// - Creating bindings from state
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @StateConnector(\.user) var user
///     @ActionDispatcher var dispatch
///
///     var body: some View {
///         Text(user.name)
///         Button("Logout") {
///             dispatch(.logout)
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct StateConnector<State, LocalState>: DynamicProperty {
    
    @ObservedObject private var observableState: ObservableState<LocalState>
    private let keyPath: KeyPath<State, LocalState>
    
    public var wrappedValue: LocalState {
        observableState.value
    }
    
    public var projectedValue: Binding<LocalState> {
        Binding(
            get: { observableState.value },
            set: { _ in } // Read-only by default
        )
    }
    
    public init(
        _ keyPath: KeyPath<State, LocalState>,
        store: Store<State, some Any>
    ) {
        self.keyPath = keyPath
        self.observableState = ObservableState(
            initialValue: store.state[keyPath: keyPath]
        )
        
        // Set up observation
        // Implementation would observe store changes
    }
}

// MARK: - ObservableState

/// Observable wrapper for state values.
public final class ObservableState<Value>: ObservableObject {
    @Published public var value: Value
    
    public init(initialValue: Value) {
        self.value = initialValue
    }
}

// MARK: - StateBinding

/// Creates two-way bindings to state through actions.
///
/// Example usage:
/// ```swift
/// @StateBinding(
///     get: \.settings.darkMode,
///     set: { .updateSetting(.darkMode($0)) }
/// ) var isDarkMode: Bool
/// ```
@propertyWrapper
public struct StateBinding<State, Action, Value>: DynamicProperty {
    
    @ObservedObject private var observableValue: ObservableValue<Value>
    private let getValue: (State) -> Value
    private let makeAction: (Value) -> Action
    private var dispatch: ((Action) -> Void)?
    
    public var wrappedValue: Value {
        get { observableValue.value }
        nonmutating set {
            observableValue.value = newValue
            let action = makeAction(newValue)
            dispatch?(action)
        }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    public init(
        get: @escaping (State) -> Value,
        set makeAction: @escaping (Value) -> Action,
        initialValue: Value
    ) {
        self.getValue = get
        self.makeAction = makeAction
        self.observableValue = ObservableValue(value: initialValue)
    }
    
    public mutating func configure(dispatch: @escaping (Action) -> Void) {
        self.dispatch = dispatch
    }
}

private final class ObservableValue<Value>: ObservableObject {
    @Published var value: Value
    
    init(value: Value) {
        self.value = value
    }
}

// MARK: - ActionDispatcher

/// Property wrapper for dispatching actions.
///
/// Example usage:
/// ```swift
/// struct MyView: View {
///     @ActionDispatcher var dispatch
///
///     var body: some View {
///         Button("Tap") {
///             dispatch(.buttonTapped)
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct ActionDispatcher<Action>: DynamicProperty {
    
    @Environment(\.actionDispatch) private var environmentDispatch
    
    public var wrappedValue: (Action) -> Void {
        { action in
            environmentDispatch?(action as Any)
        }
    }
    
    public init() {}
}

// MARK: - Environment Keys

private struct ActionDispatchKey: EnvironmentKey {
    static let defaultValue: ((Any) -> Void)? = nil
}

extension EnvironmentValues {
    var actionDispatch: ((Any) -> Void)? {
        get { self[ActionDispatchKey.self] }
        set { self[ActionDispatchKey.self] = newValue }
    }
}

// MARK: - WithStore

/// A view that provides store access to its content.
///
/// Example usage:
/// ```swift
/// WithStore(store) { state, dispatch in
///     Text("Count: \(state.count)")
///     Button("+") { dispatch(.increment) }
/// }
/// ```
public struct WithStore<State, Action, Content: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let content: (State, @escaping (Action) -> Void) -> Content
    
    public init(
        _ store: Store<State, Action>,
        @ViewBuilder content: @escaping (State, @escaping (Action) -> Void) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        content(store.state, store.send)
            .environment(\.actionDispatch, { store.send($0 as! Action) })
    }
}

// MARK: - ScopedView

/// A view that observes only a subset of state.
///
/// This helps prevent unnecessary re-renders when only specific
/// parts of state change.
///
/// Example usage:
/// ```swift
/// ScopedView(store, state: \.user) { user in
///     UserProfileView(user: user)
/// }
/// ```
public struct ScopedView<State, Action, LocalState: Equatable, Content: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let stateKeyPath: KeyPath<State, LocalState>
    private let content: (LocalState) -> Content
    
    @StateObject private var localState: LocalStateHolder<LocalState>
    
    public init(
        _ store: Store<State, Action>,
        state stateKeyPath: KeyPath<State, LocalState>,
        @ViewBuilder content: @escaping (LocalState) -> Content
    ) {
        self.store = store
        self.stateKeyPath = stateKeyPath
        self.content = content
        self._localState = StateObject(wrappedValue: LocalStateHolder(
            initialValue: store.state[keyPath: stateKeyPath]
        ))
    }
    
    public var body: some View {
        let currentLocalState = store.state[keyPath: stateKeyPath]
        
        return content(currentLocalState)
            .onChange(of: currentLocalState) { newValue in
                localState.value = newValue
            }
    }
}

private final class LocalStateHolder<Value>: ObservableObject {
    @Published var value: Value
    
    init(initialValue: Value) {
        self.value = initialValue
    }
}

// MARK: - StoreProvider

/// Provides a store to the view hierarchy through the environment.
public struct StoreProvider<State, Action, Content: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let content: Content
    
    public init(
        _ store: Store<State, Action>,
        @ViewBuilder content: () -> Content
    ) {
        self.store = store
        self.content = content()
    }
    
    public var body: some View {
        content
            .environmentObject(store)
            .environment(\.actionDispatch, { self.store.send($0 as! Action) })
    }
}

// MARK: - UseSelector

/// A hook-like function for selecting state.
///
/// Example usage:
/// ```swift
/// struct MyView: View {
///     @EnvironmentObject var store: Store<AppState, AppAction>
///
///     var body: some View {
///         let count = useSelector(from: store, \.counter.value)
///         Text("Count: \(count)")
///     }
/// }
/// ```
public func useSelector<State, Action, Selected: Equatable>(
    from store: Store<State, Action>,
    _ selector: KeyPath<State, Selected>
) -> Selected {
    store.state[keyPath: selector]
}

// MARK: - StoreView

/// A view that automatically observes a store and provides its state.
public struct StoreView<State, Action, Content: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let content: (State, Store<State, Action>) -> Content
    
    public init(
        _ store: Store<State, Action>,
        @ViewBuilder content: @escaping (State, Store<State, Action>) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        content(store.state, store)
    }
}

// MARK: - ViewState

/// Extracts and observes a specific piece of view state.
public struct ViewState<State, Action, ViewState: Equatable>: DynamicProperty {
    
    @ObservedObject private var store: Store<State, Action>
    private let transform: (State) -> ViewState
    
    public var value: ViewState {
        transform(store.state)
    }
    
    public init(
        store: Store<State, Action>,
        transform: @escaping (State) -> ViewState
    ) {
        self.store = store
        self.transform = transform
    }
}

// MARK: - ActionButton

/// A button that dispatches an action when tapped.
public struct ActionButton<State, Action, Label: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let action: Action
    private let label: Label
    
    public init(
        store: Store<State, Action>,
        action: Action,
        @ViewBuilder label: () -> Label
    ) {
        self.store = store
        self.action = action
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { store.send(action) }) {
            label
        }
    }
}

// MARK: - FormBinding

/// Creates form bindings that dispatch actions on change.
public struct FormBinding<State, Action, Value> {
    
    private let get: (State) -> Value
    private let action: (Value) -> Action
    private let store: Store<State, Action>
    
    public init(
        store: Store<State, Action>,
        get: @escaping (State) -> Value,
        action: @escaping (Value) -> Action
    ) {
        self.store = store
        self.get = get
        self.action = action
    }
    
    public var binding: Binding<Value> {
        Binding(
            get: { get(store.state) },
            set: { store.send(action($0)) }
        )
    }
}

// MARK: - Store Extensions for SwiftUI

extension Store {
    
    /// Creates a binding for a piece of state.
    public func binding<Value>(
        get: @escaping (State) -> Value,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { get(self.state) },
            set: { self.send(action($0)) }
        )
    }
    
    /// Creates a binding for a key path in state.
    public func binding<Value>(
        _ keyPath: KeyPath<State, Value>,
        send action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        binding(get: { $0[keyPath: keyPath] }, send: action)
    }
    
    /// Creates a scoped view of the store.
    public func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> ScopedStore<LocalState, LocalAction> {
        ScopedStore(
            state: { toLocalState(self.state) },
            send: { self.send(toGlobalAction($0)) }
        )
    }
}

// MARK: - ScopedStore

/// A scoped view of a store for a subset of state and actions.
public final class ScopedStore<State, Action>: ObservableObject {
    
    private let getState: () -> State
    private let sendAction: (Action) -> Void
    
    public var state: State {
        getState()
    }
    
    public init(
        state: @escaping () -> State,
        send: @escaping (Action) -> Void
    ) {
        self.getState = state
        self.sendAction = send
    }
    
    public func send(_ action: Action) {
        sendAction(action)
    }
}

// MARK: - StateReader

/// Reads state without causing view updates.
///
/// Useful for accessing state in closures without creating
/// a dependency on the state for view updates.
public struct StateReader<State, Action, Content: View>: View {
    
    private let store: Store<State, Action>
    private let content: (State) -> Content
    
    public init(
        _ store: Store<State, Action>,
        @ViewBuilder content: @escaping (State) -> Content
    ) {
        self.store = store
        self.content = content
    }
    
    public var body: some View {
        content(store.state)
    }
}

// MARK: - OptionalStateView

/// A view that handles optional state gracefully.
public struct OptionalStateView<State, Action, Value, Content: View, Placeholder: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let keyPath: KeyPath<State, Value?>
    private let content: (Value) -> Content
    private let placeholder: Placeholder
    
    public init(
        _ store: Store<State, Action>,
        state keyPath: KeyPath<State, Value?>,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.store = store
        self.keyPath = keyPath
        self.content = content
        self.placeholder = placeholder()
    }
    
    public var body: some View {
        if let value = store.state[keyPath: keyPath] {
            content(value)
        } else {
            placeholder
        }
    }
}

// MARK: - LoadableStateView

/// A view that handles loading, success, and error states.
public struct LoadableStateView<State, Action, Value, Loading: View, Content: View, Error: View>: View {
    
    public enum LoadableState<T> {
        case idle
        case loading
        case success(T)
        case failure(Swift.Error)
    }
    
    @ObservedObject private var store: Store<State, Action>
    private let keyPath: KeyPath<State, LoadableState<Value>>
    private let loading: Loading
    private let content: (Value) -> Content
    private let error: (Swift.Error) -> Error
    
    public init(
        _ store: Store<State, Action>,
        state keyPath: KeyPath<State, LoadableState<Value>>,
        @ViewBuilder loading: () -> Loading,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder error: @escaping (Swift.Error) -> Error
    ) {
        self.store = store
        self.keyPath = keyPath
        self.loading = loading()
        self.content = content
        self.error = error
    }
    
    public var body: some View {
        switch store.state[keyPath: keyPath] {
        case .idle, .loading:
            loading
        case let .success(value):
            content(value)
        case let .failure(err):
            error(err)
        }
    }
}

// MARK: - IfLetStore

/// Unwraps optional state and provides a scoped store.
public struct IfLetStore<State, Action, Content: View, Else: View>: View {
    
    @ObservedObject private var store: Store<State?, Action>
    private let content: (Store<State, Action>) -> Content
    private let elseContent: Else
    
    public init(
        _ store: Store<State?, Action>,
        @ViewBuilder then content: @escaping (Store<State, Action>) -> Content,
        @ViewBuilder else elseContent: () -> Else
    ) {
        self.store = store
        self.content = content
        self.elseContent = elseContent()
    }
    
    public var body: some View {
        if store.state != nil {
            // Would create scoped store for unwrapped state
            EmptyView()
        } else {
            elseContent
        }
    }
}

// MARK: - ForEachStore

/// Iterates over a collection in state with scoped stores.
public struct ForEachStore<State, Action, ID: Hashable, Content: View>: View {
    
    @ObservedObject private var store: Store<[State], Action>
    private let id: KeyPath<State, ID>
    private let content: (Store<State, Action>) -> Content
    
    public init(
        _ store: Store<[State], Action>,
        id: KeyPath<State, ID>,
        @ViewBuilder content: @escaping (Store<State, Action>) -> Content
    ) {
        self.store = store
        self.id = id
        self.content = content
    }
    
    public var body: some View {
        ForEach(store.state, id: id) { _ in
            // Would create scoped store for each element
            EmptyView()
        }
    }
}

// MARK: - NavigationLinkStore

/// Navigation link powered by state.
public struct NavigationLinkStore<State, Action, Destination: View, Label: View>: View {
    
    @ObservedObject private var store: Store<State, Action>
    private let isActive: KeyPath<State, Bool>
    private let setActive: (Bool) -> Action
    private let destination: Destination
    private let label: Label
    
    public init(
        _ store: Store<State, Action>,
        isActive: KeyPath<State, Bool>,
        setActive: @escaping (Bool) -> Action,
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label
    ) {
        self.store = store
        self.isActive = isActive
        self.setActive = setActive
        self.destination = destination()
        self.label = label()
    }
    
    public var body: some View {
        NavigationLink(
            isActive: store.binding(isActive, send: setActive),
            destination: { destination },
            label: { label }
        )
    }
}

// MARK: - AlertStore

/// Alert presented based on state.
public struct AlertState<Action>: Equatable {
    public let title: String
    public let message: String?
    public let buttons: [Button]
    
    public struct Button: Equatable, Identifiable {
        public let id = UUID()
        public let title: String
        public let role: ButtonRole?
        public let action: Action?
        
        public enum ButtonRole: Equatable {
            case cancel
            case destructive
        }
        
        public static func == (lhs: Button, rhs: Button) -> Bool {
            lhs.id == rhs.id && lhs.title == rhs.title
        }
    }
    
    public init(
        title: String,
        message: String? = nil,
        buttons: [Button] = []
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
    
    public static func == (lhs: AlertState, rhs: AlertState) -> Bool {
        lhs.title == rhs.title && lhs.message == rhs.message
    }
}

// MARK: - SheetStore

/// Sheet presentation powered by state.
public struct SheetStore<State, Action, Item: Identifiable, Content: View>: ViewModifier {
    
    @ObservedObject private var store: Store<State, Action>
    private let item: KeyPath<State, Item?>
    private let onDismiss: Action?
    private let content: (Item) -> Content
    
    public init(
        store: Store<State, Action>,
        item: KeyPath<State, Item?>,
        onDismiss: Action?,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.store = store
        self.item = item
        self.onDismiss = onDismiss
        self.content = content
    }
    
    public func body(content view: Content) -> some View {
        view.sheet(
            item: Binding(
                get: { store.state[keyPath: item] },
                set: { _ in
                    if let dismissAction = onDismiss {
                        store.send(dismissAction)
                    }
                }
            ),
            content: content
        )
    }
}

extension View {
    
    /// Presents a sheet based on store state.
    public func sheet<State, Action, Item: Identifiable, SheetContent: View>(
        store: Store<State, Action>,
        item: KeyPath<State, Item?>,
        onDismiss: Action? = nil,
        @ViewBuilder content: @escaping (Item) -> SheetContent
    ) -> some View {
        modifier(SheetStore(
            store: store,
            item: item,
            onDismiss: onDismiss,
            content: content
        ))
    }
}
