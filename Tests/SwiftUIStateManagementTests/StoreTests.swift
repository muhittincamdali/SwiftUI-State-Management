//
//  StoreTests.swift
//  SwiftUIStateManagement
//
//  Comprehensive test suite for the state management framework.
//
//  Created by Muhittin Camdali
//  Copyright © 2025 All rights reserved.
//

import XCTest
import Combine
@testable import SwiftUIStateManagement

// MARK: - Test State & Actions

/// Test state with various property types for comprehensive testing
struct TestState: Equatable, Codable {
    var count: Int = 0
    var text: String = ""
    var isLoading: Bool = false
    var items: [String] = []
    var optionalValue: Int? = nil
    var nestedState: NestedTestState = NestedTestState()
    var errorMessage: String? = nil
    var history: [Int] = []
}

/// Nested state for testing scoped reducers
struct NestedTestState: Equatable, Codable {
    var value: Int = 0
    var name: String = ""
}

/// Test actions covering all common patterns
enum TestAction: Equatable {
    // Basic operations
    case increment
    case decrement
    case incrementBy(Int)
    case decrementBy(Int)
    case set(Int)
    case reset
    
    // Text operations
    case setText(String)
    case appendText(String)
    case clearText
    
    // Loading state
    case setLoading(Bool)
    case startLoading
    case stopLoading
    
    // Collection operations
    case addItem(String)
    case removeItem(at: Int)
    case clearItems
    case setItems([String])
    
    // Optional value
    case setOptionalValue(Int?)
    
    // Nested state
    case setNestedValue(Int)
    case setNestedName(String)
    
    // Error handling
    case setError(String?)
    case dismissError
    
    // History
    case recordValue
    case clearHistory
    
    // Async simulation
    case delayedIncrement
    case delayedIncrementComplete
    
    // Effect-producing actions
    case loadData
    case loadDataSuccess([String])
    case loadDataFailure(String)
}

// MARK: - Test Reducer

/// Comprehensive test reducer with effect handling
struct TestReducer: Reducer {
    typealias State = TestState
    typealias ActionType = TestAction
    
    func reduce(state: inout TestState, action: TestAction) -> Effect<TestAction> {
        switch action {
        // MARK: - Basic Operations
        case .increment:
            state.count += 1
            return .none
            
        case .decrement:
            state.count -= 1
            return .none
            
        case .incrementBy(let amount):
            state.count += amount
            return .none
            
        case .decrementBy(let amount):
            state.count -= amount
            return .none
            
        case .set(let value):
            state.count = value
            return .none
            
        case .reset:
            state = TestState()
            return .none
            
        // MARK: - Text Operations
        case .setText(let text):
            state.text = text
            return .none
            
        case .appendText(let text):
            state.text += text
            return .none
            
        case .clearText:
            state.text = ""
            return .none
            
        // MARK: - Loading State
        case .setLoading(let loading):
            state.isLoading = loading
            return .none
            
        case .startLoading:
            state.isLoading = true
            return .none
            
        case .stopLoading:
            state.isLoading = false
            return .none
            
        // MARK: - Collection Operations
        case .addItem(let item):
            state.items.append(item)
            return .none
            
        case .removeItem(let index):
            guard index >= 0 && index < state.items.count else { return .none }
            state.items.remove(at: index)
            return .none
            
        case .clearItems:
            state.items.removeAll()
            return .none
            
        case .setItems(let items):
            state.items = items
            return .none
            
        // MARK: - Optional Value
        case .setOptionalValue(let value):
            state.optionalValue = value
            return .none
            
        // MARK: - Nested State
        case .setNestedValue(let value):
            state.nestedState.value = value
            return .none
            
        case .setNestedName(let name):
            state.nestedState.name = name
            return .none
            
        // MARK: - Error Handling
        case .setError(let error):
            state.errorMessage = error
            return .none
            
        case .dismissError:
            state.errorMessage = nil
            return .none
            
        // MARK: - History
        case .recordValue:
            state.history.append(state.count)
            return .none
            
        case .clearHistory:
            state.history.removeAll()
            return .none
            
        // MARK: - Async Simulation
        case .delayedIncrement:
            state.isLoading = true
            return Effect.send(.delayedIncrementComplete)
            
        case .delayedIncrementComplete:
            state.count += 1
            state.isLoading = false
            return .none
            
        // MARK: - Effect-Producing Actions
        case .loadData:
            state.isLoading = true
            return .none
            
        case .loadDataSuccess(let items):
            state.items = items
            state.isLoading = false
            return .none
            
        case .loadDataFailure(let error):
            state.errorMessage = error
            state.isLoading = false
            return .none
        }
    }
}

// MARK: - Store Tests

final class StoreTests: XCTestCase {
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        XCTAssertEqual(store.state.count, 0)
        XCTAssertEqual(store.state.text, "")
        XCTAssertFalse(store.state.isLoading)
        XCTAssertTrue(store.state.items.isEmpty)
        XCTAssertNil(store.state.optionalValue)
    }
    
    func testInitialStateWithCustomValues() {
        let customState = TestState(
            count: 10,
            text: "initial",
            isLoading: true,
            items: ["a", "b", "c"]
        )
        let store = Store(initialState: customState, reducer: TestReducer())
        XCTAssertEqual(store.state.count, 10)
        XCTAssertEqual(store.state.text, "initial")
        XCTAssertTrue(store.state.isLoading)
        XCTAssertEqual(store.state.items, ["a", "b", "c"])
    }
    
    // MARK: - Basic Action Tests
    
    func testIncrement() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        XCTAssertEqual(store.state.count, 1)
    }
    
    func testDecrement() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.decrement)
        XCTAssertEqual(store.state.count, -1)
    }
    
    func testIncrementBy() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.incrementBy(5))
        XCTAssertEqual(store.state.count, 5)
    }
    
    func testDecrementBy() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.decrementBy(3))
        XCTAssertEqual(store.state.count, -3)
    }
    
    func testSetValue() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.set(42))
        XCTAssertEqual(store.state.count, 42)
    }
    
    func testMultipleActions() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.increment)
        store.send(.increment)
        store.send(.decrement)
        XCTAssertEqual(store.state.count, 2)
    }
    
    func testComplexActionSequence() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.set(10))
        store.send(.incrementBy(5))
        store.send(.decrementBy(3))
        store.send(.increment)
        store.send(.decrement)
        XCTAssertEqual(store.state.count, 12)
    }
    
    // MARK: - Text Operation Tests
    
    func testSetText() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setText("hello"))
        XCTAssertEqual(store.state.text, "hello")
    }
    
    func testAppendText() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setText("hello"))
        store.send(.appendText(" world"))
        XCTAssertEqual(store.state.text, "hello world")
    }
    
    func testClearText() {
        let store = Store(initialState: TestState(text: "some text"), reducer: TestReducer())
        store.send(.clearText)
        XCTAssertEqual(store.state.text, "")
    }
    
    // MARK: - Loading State Tests
    
    func testSetLoading() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setLoading(true))
        XCTAssertTrue(store.state.isLoading)
        store.send(.setLoading(false))
        XCTAssertFalse(store.state.isLoading)
    }
    
    func testStartStopLoading() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.startLoading)
        XCTAssertTrue(store.state.isLoading)
        store.send(.stopLoading)
        XCTAssertFalse(store.state.isLoading)
    }
    
    // MARK: - Collection Operation Tests
    
    func testAddItem() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.addItem("first"))
        store.send(.addItem("second"))
        XCTAssertEqual(store.state.items, ["first", "second"])
    }
    
    func testRemoveItem() {
        let store = Store(initialState: TestState(items: ["a", "b", "c"]), reducer: TestReducer())
        store.send(.removeItem(at: 1))
        XCTAssertEqual(store.state.items, ["a", "c"])
    }
    
    func testRemoveItemOutOfBounds() {
        let store = Store(initialState: TestState(items: ["a", "b"]), reducer: TestReducer())
        store.send(.removeItem(at: 10))
        XCTAssertEqual(store.state.items, ["a", "b"])
    }
    
    func testRemoveItemNegativeIndex() {
        let store = Store(initialState: TestState(items: ["a", "b"]), reducer: TestReducer())
        store.send(.removeItem(at: -1))
        XCTAssertEqual(store.state.items, ["a", "b"])
    }
    
    func testClearItems() {
        let store = Store(initialState: TestState(items: ["a", "b", "c"]), reducer: TestReducer())
        store.send(.clearItems)
        XCTAssertTrue(store.state.items.isEmpty)
    }
    
    func testSetItems() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setItems(["x", "y", "z"]))
        XCTAssertEqual(store.state.items, ["x", "y", "z"])
    }
    
    // MARK: - Optional Value Tests
    
    func testSetOptionalValue() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setOptionalValue(42))
        XCTAssertEqual(store.state.optionalValue, 42)
    }
    
    func testClearOptionalValue() {
        let store = Store(initialState: TestState(optionalValue: 42), reducer: TestReducer())
        store.send(.setOptionalValue(nil))
        XCTAssertNil(store.state.optionalValue)
    }
    
    // MARK: - Nested State Tests
    
    func testSetNestedValue() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setNestedValue(100))
        XCTAssertEqual(store.state.nestedState.value, 100)
    }
    
    func testSetNestedName() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setNestedName("nested"))
        XCTAssertEqual(store.state.nestedState.name, "nested")
    }
    
    // MARK: - Error Handling Tests
    
    func testSetError() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setError("Something went wrong"))
        XCTAssertEqual(store.state.errorMessage, "Something went wrong")
    }
    
    func testDismissError() {
        let store = Store(initialState: TestState(errorMessage: "Error"), reducer: TestReducer())
        store.send(.dismissError)
        XCTAssertNil(store.state.errorMessage)
    }
    
    // MARK: - History Tests
    
    func testRecordValue() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.recordValue)
        store.send(.incrementBy(5))
        store.send(.recordValue)
        XCTAssertEqual(store.state.history, [1, 6])
    }
    
    func testClearHistory() {
        let store = Store(initialState: TestState(history: [1, 2, 3]), reducer: TestReducer())
        store.send(.clearHistory)
        XCTAssertTrue(store.state.history.isEmpty)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.setText("modified"))
        store.send(.addItem("item"))
        store.send(.setNestedValue(50))
        store.send(.reset)
        XCTAssertEqual(store.state, TestState())
    }
    
    // MARK: - Effect Tests
    
    func testDelayedIncrement() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.delayedIncrement)
        // Effect should be processed
        XCTAssertEqual(store.state.count, 1)
        XCTAssertFalse(store.state.isLoading)
    }
    
    // MARK: - Value Access Tests
    
    func testValueAccess() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.increment)
        XCTAssertEqual(store.value(\.count), 2)
    }
    
    func testNestedValueAccess() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.setNestedValue(77))
        XCTAssertEqual(store.value(\.nestedState.value), 77)
    }
    
    // MARK: - Dispatch Count Tests
    
    func testDispatchCount() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.decrement)
        store.send(.increment)
        XCTAssertEqual(store.dispatchCount, 3)
    }
    
    func testDispatchCountAfterReset() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.increment)
        store.send(.increment)
        store.send(.reset)
        XCTAssertEqual(store.dispatchCount, 3)
    }
    
    // MARK: - Middleware Tests
    
    func testMiddlewareInterception() {
        var loggedActions: [String] = []
        let logger = AnyMiddleware<TestState, TestAction> { action, _, next in
            loggedActions.append(String(describing: action))
            next(action)
        }
        
        let store = Store(
            initialState: TestState(),
            reducer: TestReducer(),
            middleware: [logger]
        )
        
        store.send(.increment)
        store.send(.setText("test"))
        
        XCTAssertEqual(loggedActions.count, 2)
        XCTAssertTrue(loggedActions[0].contains("increment"))
        XCTAssertTrue(loggedActions[1].contains("setText"))
    }
    
    func testMiddlewareBlocksAction() {
        let blocker = AnyMiddleware<TestState, TestAction> { action, _, next in
            // Block increment actions
            if case .increment = action {
                return
            }
            next(action)
        }
        
        let store = Store(
            initialState: TestState(),
            reducer: TestReducer(),
            middleware: [blocker]
        )
        
        store.send(.increment)
        XCTAssertEqual(store.state.count, 0) // Should not increment
        
        store.send(.decrement)
        XCTAssertEqual(store.state.count, -1) // Should decrement
    }
    
    func testMultipleMiddleware() {
        var order: [String] = []
        
        let first = AnyMiddleware<TestState, TestAction> { action, _, next in
            order.append("first-before")
            next(action)
            order.append("first-after")
        }
        
        let second = AnyMiddleware<TestState, TestAction> { action, _, next in
            order.append("second-before")
            next(action)
            order.append("second-after")
        }
        
        let store = Store(
            initialState: TestState(),
            reducer: TestReducer(),
            middleware: [first, second]
        )
        
        store.send(.increment)
        
        XCTAssertEqual(order, [
            "first-before",
            "second-before",
            "second-after",
            "first-after"
        ])
    }
    
    func testMiddlewareAccessesState() {
        var capturedState: TestState?
        
        let stateReader = AnyMiddleware<TestState, TestAction> { action, getState, next in
            capturedState = getState()
            next(action)
        }
        
        let store = Store(
            initialState: TestState(count: 42),
            reducer: TestReducer(),
            middleware: [stateReader]
        )
        
        store.send(.increment)
        
        XCTAssertEqual(capturedState?.count, 42)
    }
    
    // MARK: - Reducer Combination Tests
    
    func testReducerCombination() {
        var sideEffectExecuted = false
        
        let sideEffectReducer = Reducer<TestState, TestAction> { state, action in
            if case .increment = action {
                sideEffectExecuted = true
            }
            return .none
        }
        
        let combined = TestReducer().combined(with: sideEffectReducer)
        var state = TestState()
        _ = combined.reduce(&state, .increment)
        
        XCTAssertEqual(state.count, 1)
        XCTAssertTrue(sideEffectExecuted)
    }
    
    // MARK: - State Observation Tests
    
    func testStatePublisher() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        var receivedStates: [TestState] = []
        
        store.statePublisher
            .sink { receivedStates.append($0) }
            .store(in: &cancellables)
        
        store.send(.increment)
        store.send(.setText("hello"))
        
        XCTAssertEqual(receivedStates.count, 3) // Initial + 2 updates
        XCTAssertEqual(receivedStates[1].count, 1)
        XCTAssertEqual(receivedStates[2].text, "hello")
    }
    
    func testActionPublisher() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        var receivedActions: [TestAction] = []
        
        store.actionPublisher
            .sink { receivedActions.append($0) }
            .store(in: &cancellables)
        
        store.send(.increment)
        store.send(.decrement)
        
        XCTAssertEqual(receivedActions.count, 2)
        XCTAssertEqual(receivedActions[0], .increment)
        XCTAssertEqual(receivedActions[1], .decrement)
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentActions() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        let expectation = self.expectation(description: "Concurrent actions")
        let iterations = 1000
        var completedOperations = 0
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        for _ in 0..<iterations {
            queue.async {
                store.send(.increment)
                DispatchQueue.main.async {
                    completedOperations += 1
                    if completedOperations == iterations {
                        expectation.fulfill()
                    }
                }
            }
        }
        
        waitForExpectations(timeout: 5.0)
        XCTAssertEqual(store.state.count, iterations)
    }
}

// MARK: - Effect Tests

final class EffectTests: XCTestCase {
    
    func testNoneEffect() {
        let effect: Effect<TestAction> = .none
        XCTAssertTrue(effect.isEmpty)
    }
    
    func testSendEffect() {
        let effect: Effect<TestAction> = .send(.increment)
        XCTAssertFalse(effect.isEmpty)
    }
    
    func testMergeEffects() {
        let effect1: Effect<TestAction> = .send(.increment)
        let effect2: Effect<TestAction> = .send(.decrement)
        let merged = Effect.merge([effect1, effect2])
        XCTAssertFalse(merged.isEmpty)
    }
    
    func testConcatenateEffects() {
        let effect1: Effect<TestAction> = .send(.increment)
        let effect2: Effect<TestAction> = .send(.decrement)
        let concatenated = Effect.concatenate([effect1, effect2])
        XCTAssertFalse(concatenated.isEmpty)
    }
    
    func testMapEffect() {
        enum OtherAction: Equatable {
            case mapped(TestAction)
        }
        
        let effect: Effect<TestAction> = .send(.increment)
        let mapped: Effect<OtherAction> = effect.map { .mapped($0) }
        XCTAssertFalse(mapped.isEmpty)
    }
}

// MARK: - Reducer Tests

final class ReducerTests: XCTestCase {
    
    func testReducerPurity() {
        let reducer = TestReducer()
        var state1 = TestState()
        var state2 = TestState()
        
        _ = reducer.reduce(&state1, .increment)
        _ = reducer.reduce(&state2, .increment)
        
        XCTAssertEqual(state1, state2)
    }
    
    func testReducerDoesNotMutateUnrelatedState() {
        let reducer = TestReducer()
        var state = TestState(text: "unchanged", items: ["preserved"])
        
        _ = reducer.reduce(&state, .increment)
        
        XCTAssertEqual(state.text, "unchanged")
        XCTAssertEqual(state.items, ["preserved"])
    }
    
    func testOptionalReducer() {
        struct OptionalState: Equatable {
            var child: TestState?
        }
        
        let childReducer = TestReducer()
        
        // Test that optional reducer properly handles nil state
        var state = OptionalState(child: nil)
        // When child is nil, no action should modify it
        XCTAssertNil(state.child)
        
        // When child exists, actions should work
        state.child = TestState()
        if var child = state.child {
            _ = childReducer.reduce(&child, .increment)
            state.child = child
        }
        XCTAssertEqual(state.child?.count, 1)
    }
}

// MARK: - Scope Tests

final class ScopeTests: XCTestCase {
    
    struct ParentState: Equatable {
        var child: TestState = TestState()
        var parentValue: Int = 0
    }
    
    enum ParentAction: Equatable {
        case child(TestAction)
        case incrementParent
    }
    
    func testScopedStore() {
        let parentReducer = Reducer<ParentState, ParentAction> { state, action in
            switch action {
            case .child(let childAction):
                let childReducer = TestReducer()
                return childReducer.reduce(&state.child, childAction).map { ParentAction.child($0) }
            case .incrementParent:
                state.parentValue += 1
                return .none
            }
        }
        
        let store = Store(initialState: ParentState(), reducer: parentReducer)
        
        store.send(.child(.increment))
        XCTAssertEqual(store.state.child.count, 1)
        XCTAssertEqual(store.state.parentValue, 0)
        
        store.send(.incrementParent)
        XCTAssertEqual(store.state.child.count, 1)
        XCTAssertEqual(store.state.parentValue, 1)
    }
}

// MARK: - Performance Tests

final class PerformanceTests: XCTestCase {
    
    func testActionDispatchPerformance() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        
        measure {
            for _ in 0..<10000 {
                store.send(.increment)
            }
        }
    }
    
    func testStateAccessPerformance() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        store.send(.set(42))
        
        measure {
            for _ in 0..<100000 {
                _ = store.state.count
            }
        }
    }
    
    func testMiddlewareOverhead() {
        let noopMiddleware = AnyMiddleware<TestState, TestAction> { action, _, next in
            next(action)
        }
        
        let store = Store(
            initialState: TestState(),
            reducer: TestReducer(),
            middleware: [noopMiddleware, noopMiddleware, noopMiddleware]
        )
        
        measure {
            for _ in 0..<10000 {
                store.send(.increment)
            }
        }
    }
}

// MARK: - Integration Tests

final class IntegrationTests: XCTestCase {
    
    func testTypicalUserFlow() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        
        // User starts loading
        store.send(.startLoading)
        XCTAssertTrue(store.state.isLoading)
        
        // Data arrives
        store.send(.loadDataSuccess(["item1", "item2", "item3"]))
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.items.count, 3)
        
        // User adds an item
        store.send(.addItem("item4"))
        XCTAssertEqual(store.state.items.count, 4)
        
        // User removes an item
        store.send(.removeItem(at: 0))
        XCTAssertEqual(store.state.items, ["item2", "item3", "item4"])
    }
    
    func testErrorHandlingFlow() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        
        // Start loading
        store.send(.startLoading)
        XCTAssertTrue(store.state.isLoading)
        
        // Error occurs
        store.send(.loadDataFailure("Network error"))
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.errorMessage, "Network error")
        
        // User dismisses error
        store.send(.dismissError)
        XCTAssertNil(store.state.errorMessage)
    }
    
    func testComplexStateManipulation() {
        let store = Store(initialState: TestState(), reducer: TestReducer())
        
        // Complex sequence of operations
        store.send(.setText("Hello"))
        store.send(.increment)
        store.send(.recordValue)
        store.send(.addItem("A"))
        store.send(.incrementBy(9))
        store.send(.recordValue)
        store.send(.appendText(" World"))
        store.send(.addItem("B"))
        store.send(.setNestedValue(42))
        store.send(.setOptionalValue(100))
        
        XCTAssertEqual(store.state.count, 10)
        XCTAssertEqual(store.state.text, "Hello World")
        XCTAssertEqual(store.state.history, [1, 10])
        XCTAssertEqual(store.state.items, ["A", "B"])
        XCTAssertEqual(store.state.nestedState.value, 42)
        XCTAssertEqual(store.state.optionalValue, 100)
    }
}
