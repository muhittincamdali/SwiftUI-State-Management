import SwiftUI

/// Main entry point for the SwiftUI State Management toolkit.
public enum StateManagement {
    public static let version = "2.0.0"
}

/// A high-integrity, thread-safe Store for state management.
@MainActor
public final class Store<State: Sendable, Action: Sendable>: ObservableObject {
    @Published public private(set) var state: State
    private let reducer: @Sendable (inout State, Action) -> Void
    
    public init(initialState: State, reducer: @escaping @Sendable (inout State, Action) -> Void) {
        self.state = initialState
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        reducer(&state, action)
    }
}
