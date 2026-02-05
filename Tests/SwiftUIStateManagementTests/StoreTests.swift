import XCTest
@testable import SwiftUIStateManagement

// MARK: - Test State & Actions

struct TestState: Equatable {
    var count = 0
    var name = ""
    var isLoading = false
    var items: [String] = []
}

enum TestAction: Equatable {
    case increment
    case decrement
    case setName(String)
    case setLoading(Bool)
    case addItem(String)
    case removeItem(Int)
    case reset
    case fetchItems
    case itemsLoaded([String])
    case delayed
    case asyncAction
}

// MARK: - Test Reducer

let testReducer = Reducer<TestState, TestAction> { state, action in
    switch action {
    case .increment:
        state.count += 1
        return .none
        
    case .decrement:
        state.count -= 1
        return .none
        
    case .setName(let name):
        state.name = name
        return .none
        
    case .setLoading(let loading):
        state.isLoading = loading
        return .none
        
    case .addItem(let item):
        state.items.append(item)
        return .none
        
    case .removeItem(let index):
        guard index < state.items.count else { return .none }
        state.items.remove(at: index)
        return .none
        
    case .reset:
        state = TestState()
        return .none
        
    case .fetchItems:
        state.isLoading = true
        return .task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            return .itemsLoaded(["A", "B", "C"])
        }
        
    case .itemsLoaded(let items):
        state.isLoading = false
        state.items = items
        return .none
        
    case .delayed:
        return .delay(0.1, action: .increment)
        
    case .asyncAction:
        return .fireAndForget {
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }
}

// MARK: - Store Tests

@MainActor
final class StoreTests: XCTestCase {
    
    // MARK: - Basic Tests
    
    func testInitialState() async {
        let store = Store(
            initialState: TestState(count: 5),
            reducer: testReducer
        )
        
        XCTAssertEqual(store.state.count, 5)
        XCTAssertEqual(store.state.name, "")
        XCTAssertFalse(store.state.isLoading)
    }
    
    func testSendAction() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        store.send(.increment)
        XCTAssertEqual(store.state.count, 1)
        
        store.send(.increment)
        XCTAssertEqual(store.state.count, 2)
        
        store.send(.decrement)
        XCTAssertEqual(store.state.count, 1)
    }
    
    func testMultipleActions() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        store.send(.increment, .increment, .increment)
        XCTAssertEqual(store.state.count, 3)
    }
    
    func testStateReset() async {
        let store = Store(
            initialState: TestState(count: 10, name: "Test"),
            reducer: testReducer
        )
        
        store.send(.reset)
        XCTAssertEqual(store.state.count, 0)
        XCTAssertEqual(store.state.name, "")
    }
    
    // MARK: - Effect Tests
    
    func testAsyncEffect() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        store.send(.fetchItems)
        XCTAssertTrue(store.state.isLoading)
        
        // Wait for effect to complete
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.items, ["A", "B", "C"])
    }
    
    func testFireAndForgetEffect() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        store.send(.asyncAction)
        
        // Effect should run but not change state
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(store.state.count, 0)
    }
    
    func testDelayedEffect() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        store.send(.delayed)
        XCTAssertEqual(store.state.count, 0) // Not yet incremented
        
        try? await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(store.state.count, 1) // Now incremented
    }
    
    // MARK: - Time Travel Tests
    
    func testTimeTravel() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer,
            configuration: .debug
        )
        
        store.send(.increment)
        store.send(.increment)
        store.send(.increment)
        
        XCTAssertEqual(store.state.count, 3)
        XCTAssertEqual(store.historyCount, 4) // Initial + 3 actions
        
        store.stepBack()
        XCTAssertEqual(store.state.count, 2)
        
        store.stepBack()
        XCTAssertEqual(store.state.count, 1)
        
        store.stepForward()
        XCTAssertEqual(store.state.count, 2)
        
        store.goToStart()
        XCTAssertEqual(store.state.count, 0)
        
        store.goToEnd()
        XCTAssertEqual(store.state.count, 3)
    }
    
    // MARK: - Binding Tests
    
    func testBinding() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        let binding = store.binding(
            get: \.name,
            send: { .setName($0) }
        )
        
        binding.wrappedValue = "Hello"
        XCTAssertEqual(store.state.name, "Hello")
    }
    
    // MARK: - Scope Tests
    
    func testScope() async {
        let store = Store(
            initialState: TestState(count: 5),
            reducer: testReducer
        )
        
        let scopedStore = store.scope(state: \.count)
        XCTAssertEqual(scopedStore.state, 5)
        
        store.send(.increment)
        XCTAssertEqual(scopedStore.state, 6)
    }
    
    // MARK: - Dispatch Count Tests
    
    func testDispatchCount() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer
        )
        
        XCTAssertEqual(store.dispatchCount, 0)
        
        store.send(.increment)
        XCTAssertEqual(store.dispatchCount, 1)
        
        store.send(.decrement)
        XCTAssertEqual(store.dispatchCount, 2)
    }
}

// MARK: - Reducer Tests

final class ReducerTests: XCTestCase {
    
    func testReducerCombine() {
        var state = TestState()
        
        let reducer1 = Reducer<TestState, TestAction> { state, action in
            if case .increment = action {
                state.count += 1
            }
            return .none
        }
        
        let reducer2 = Reducer<TestState, TestAction> { state, action in
            if case .increment = action {
                state.name = "Incremented"
            }
            return .none
        }
        
        let combined = Reducer.combine(reducer1, reducer2)
        _ = combined.reduce(&state, .increment)
        
        XCTAssertEqual(state.count, 1)
        XCTAssertEqual(state.name, "Incremented")
    }
    
    func testReducerFilter() {
        var state = TestState()
        
        let filteredReducer = testReducer.filter { action in
            if case .decrement = action { return false }
            return true
        }
        
        _ = filteredReducer.reduce(&state, .increment)
        XCTAssertEqual(state.count, 1)
        
        _ = filteredReducer.reduce(&state, .decrement)
        XCTAssertEqual(state.count, 1) // Decrement was filtered
    }
    
    func testReducerWhen() {
        var state = TestState(count: 10)
        
        let conditionalReducer = testReducer.when { $0.count < 5 }
        
        _ = conditionalReducer.reduce(&state, .increment)
        XCTAssertEqual(state.count, 10) // Not processed, count >= 5
        
        state.count = 3
        _ = conditionalReducer.reduce(&state, .increment)
        XCTAssertEqual(state.count, 4) // Processed, count < 5
    }
}

// MARK: - Effect Tests

final class EffectTests: XCTestCase {
    
    func testEffectNone() {
        let effect = Effect<TestAction>.none
        if case .none = effect.kind {
            // Expected
        } else {
            XCTFail("Expected none effect")
        }
    }
    
    func testEffectTask() async throws {
        var result: TestAction?
        
        let effect = Effect<TestAction>.task {
            return .increment
        }
        
        if case .task(let work) = effect.kind {
            result = try await work()
        }
        
        XCTAssertEqual(result, .increment)
    }
    
    func testEffectMerge() {
        let effect1 = Effect<TestAction>.send(.increment)
        let effect2 = Effect<TestAction>.send(.decrement)
        
        let merged = Effect.merge(effect1, effect2)
        
        if case .combine(let effects) = merged.kind {
            XCTAssertEqual(effects.count, 2)
        } else {
            XCTFail("Expected combined effect")
        }
    }
    
    func testEffectMap() async throws {
        enum LocalAction {
            case local
        }
        
        enum ParentAction {
            case child(LocalAction)
        }
        
        let localEffect = Effect<LocalAction>.send(.local)
        let parentEffect = localEffect.map { ParentAction.child($0) }
        
        if case .task(let work) = parentEffect.kind {
            let action = try await work()
            if case .child(.local) = action {
                // Expected
            } else {
                XCTFail("Expected mapped action")
            }
        }
    }
}

// MARK: - State Diff Tests

final class StateDiffTests: XCTestCase {
    
    func testStateDiff() {
        let differ = StateDiffer<TestState>()
        
        let oldState = TestState(count: 0, name: "Old")
        let newState = TestState(count: 1, name: "New")
        
        let diff = differ.diff(from: oldState, to: newState)
        
        XCTAssertTrue(diff.hasChanges)
        XCTAssertEqual(diff.modifiedCount, 2) // count and name changed
    }
    
    func testStateDiffNoChanges() {
        let differ = StateDiffer<TestState>()
        
        let state = TestState(count: 5)
        let diff = differ.diff(from: state, to: state)
        
        XCTAssertFalse(diff.hasChanges)
    }
}

// MARK: - TestStore Tests

@MainActor
final class TestStoreTests: XCTestCase {
    
    func testBasicTestStore() async {
        let store = TestStore(
            initialState: TestState(count: 0),
            reducer: testReducer
        )
        
        await store.send(.increment) {
            $0.count = 1
        }
        
        await store.send(.increment) {
            $0.count = 2
        }
        
        store.assert(\.count, equals: 2)
    }
    
    func testTestStoreWithEffect() async {
        let store = TestStore(
            initialState: TestState(),
            reducer: testReducer
        )
        
        await store.send(.fetchItems) {
            $0.isLoading = true
        }
        
        await store.receive(.itemsLoaded(["A", "B", "C"])) {
            $0.isLoading = false
            $0.items = ["A", "B", "C"]
        }
    }
}

// MARK: - Middleware Tests

final class MiddlewareTests: XCTestCase {
    
    @MainActor
    func testLoggingMiddleware() async {
        let store = Store(
            initialState: TestState(),
            reducer: testReducer,
            middleware: [
                AnyMiddleware(LoggingMiddleware<TestState, TestAction>())
            ]
        )
        
        store.send(.increment)
        XCTAssertEqual(store.state.count, 1)
    }
    
    @MainActor
    func testValidationMiddleware() async {
        var rejectedCount = 0
        
        let validationMiddleware = ValidationMiddleware<TestState, TestAction>(
            validate: { action, _ in
                if case .decrement = action {
                    return .invalid("Decrement not allowed")
                }
                return .valid
            },
            onInvalid: { _, _ in
                rejectedCount += 1
            }
        )
        
        let store = Store(
            initialState: TestState(count: 5),
            reducer: testReducer,
            middleware: [AnyMiddleware(validationMiddleware)]
        )
        
        store.send(.increment)
        XCTAssertEqual(store.state.count, 6)
        
        store.send(.decrement)
        XCTAssertEqual(store.state.count, 6) // Blocked
        XCTAssertEqual(rejectedCount, 1)
    }
    
    @MainActor
    func testRecordingMiddleware() async {
        let recorder = RecordingMiddleware<TestState, TestAction>()
        
        let store = Store(
            initialState: TestState(),
            reducer: testReducer,
            middleware: [AnyMiddleware(recorder)]
        )
        
        store.send(.increment)
        store.send(.setName("Test"))
        store.send(.decrement)
        
        XCTAssertEqual(recorder.records.count, 3)
        XCTAssertEqual(recorder.records[0].action, .increment)
        XCTAssertEqual(recorder.records[1].action, .setName("Test"))
        XCTAssertEqual(recorder.records[2].action, .decrement)
    }
}

// MARK: - IdentifiedArray Tests

final class IdentifiedArrayTests: XCTestCase {
    
    struct Item: Identifiable, Equatable {
        let id: Int
        var name: String
    }
    
    func testIdentifiedArrayBasic() {
        var array = IdentifiedArray<Int, Item>([
            Item(id: 1, name: "One"),
            Item(id: 2, name: "Two")
        ])
        
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array[id: 1]?.name, "One")
        XCTAssertEqual(array[id: 2]?.name, "Two")
        
        array[id: 1]?.name = "Updated"
        XCTAssertEqual(array[id: 1]?.name, "Updated")
    }
    
    func testIdentifiedArrayAppend() {
        var array = IdentifiedArray<Int, Item>()
        
        array.append(Item(id: 1, name: "First"))
        array.append(Item(id: 2, name: "Second"))
        
        XCTAssertEqual(array.count, 2)
        XCTAssertEqual(array[0].name, "First")
        XCTAssertEqual(array[1].name, "Second")
    }
    
    func testIdentifiedArrayRemove() {
        var array = IdentifiedArray<Int, Item>([
            Item(id: 1, name: "One"),
            Item(id: 2, name: "Two"),
            Item(id: 3, name: "Three")
        ])
        
        array.remove(id: 2)
        
        XCTAssertEqual(array.count, 2)
        XCTAssertNil(array[id: 2])
    }
}
