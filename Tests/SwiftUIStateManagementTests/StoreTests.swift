import XCTest
@testable import SwiftUIStateManagement

// MARK: - Test State & Actions

struct TestState: Equatable {
    var count: Int = 0
    var text: String = ""
    var isLoading: Bool = false
    var items: [String] = []
}

enum TestAction: Equatable {
    case increment
    case decrement
    case setText(String)
    case setLoading(Bool)
    case addItem(String)
    case reset
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

    case .setText(let text):
        state.text = text
        return .none

    case .setLoading(let loading):
        state.isLoading = loading
        return .none

    case .addItem(let item):
        state.items.append(item)
        return .none

    case .reset:
        state = TestState()
        return .none
    }
}

// MARK: - StoreTests

final class StoreTests: XCTestCase {

    func testInitialState() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        XCTAssertEqual(store.state.count, 0)
        XCTAssertEqual(store.state.text, "")
        XCTAssertFalse(store.state.isLoading)
    }

    func testIncrement() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.increment)
        XCTAssertEqual(store.state.count, 1)
    }

    func testDecrement() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.decrement)
        XCTAssertEqual(store.state.count, -1)
    }

    func testMultipleActions() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.increment)
        store.send(.increment)
        store.send(.increment)
        store.send(.decrement)
        XCTAssertEqual(store.state.count, 2)
    }

    func testSetText() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.setText("hello"))
        XCTAssertEqual(store.state.text, "hello")
    }

    func testSetLoading() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.setLoading(true))
        XCTAssertTrue(store.state.isLoading)
        store.send(.setLoading(false))
        XCTAssertFalse(store.state.isLoading)
    }

    func testAddItem() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.addItem("first"))
        store.send(.addItem("second"))
        XCTAssertEqual(store.state.items, ["first", "second"])
    }

    func testReset() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.increment)
        store.send(.setText("modified"))
        store.send(.addItem("item"))
        store.send(.reset)
        XCTAssertEqual(store.state, TestState())
    }

    func testDispatchCount() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.increment)
        store.send(.decrement)
        store.send(.increment)
        XCTAssertEqual(store.dispatchCount, 3)
    }

    func testValueAccess() {
        let store = Store(initialState: TestState(), reducer: testReducer)
        store.send(.increment)
        store.send(.increment)
        XCTAssertEqual(store.value(\.count), 2)
    }

    func testMiddleware() {
        var loggedActions: [String] = []
        let logger = AnyMiddleware<TestState, TestAction> { action, _, next in
            loggedActions.append(String(describing: action))
            next(action)
        }

        let store = Store(
            initialState: TestState(),
            reducer: testReducer,
            middleware: [logger]
        )

        store.send(.increment)
        store.send(.setText("test"))

        XCTAssertEqual(loggedActions.count, 2)
        XCTAssertEqual(store.state.count, 1)
        XCTAssertEqual(store.state.text, "test")
    }

    func testReducerCombination() {
        let loggingReducer = Reducer<TestState, TestAction> { _, _ in
            return .none
        }

        let combined = testReducer.combined(with: loggingReducer)
        var state = TestState()
        _ = combined.reduce(&state, .increment)
        XCTAssertEqual(state.count, 1)
    }
}
