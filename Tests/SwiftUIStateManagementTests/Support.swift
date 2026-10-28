import Foundation
import Observation
import os
@testable import SwiftUIStateManagement

/// Counts calls from closures that may run on any thread.
final class CallCounter: Sendable {
    private let value = OSAllocatedUnfairLock(initialState: 0)

    var count: Int { value.withLock { $0 } }

    func increment() {
        value.withLock { $0 += 1 }
    }
}

/// Collects values from any thread.
final class Collected<Value: Sendable>: Sendable {
    private let storage = OSAllocatedUnfairLock<[Value]>(initialState: [])

    var values: [Value] { storage.withLock { $0 } }

    func append(_ value: Value) {
        storage.withLock { $0.append(value) }
    }
}

/// Registers an observation of whatever `read` reads, and counts how often it is invalidated.
@MainActor
func observationCount(of read: @escaping @MainActor () -> Void) -> CallCounter {
    let counter = CallCounter()
    func track() {
        withObservationTracking {
            read()
        } onChange: {
            counter.increment()
        }
    }
    track()
    return counter
}

/// An error with a payload that must never appear in a `StoreIssue`.
struct SecretError: Error, Equatable {
    let secret: String
}

/// A small feature with a stored property per kind of value the tests read.
struct Profile: Reducer {
    struct Address: Equatable {
        var city = "Istanbul"
        var street = "Main"
    }

    struct State: Equatable {
        var count = 0
        var title = "Profile"
        var address = Address()
        var tags: [String] = ["a", "b", "c"]
        var nonEquatable = NotEquatable()
        var doubled: Int { count * 2 }

        static func == (lhs: State, rhs: State) -> Bool {
            lhs.count == rhs.count && lhs.title == rhs.title && lhs.address == rhs.address
                && lhs.tags == rhs.tags && lhs.nonEquatable.value == rhs.nonEquatable.value
        }
    }

    struct NotEquatable {
        var value = 0
    }

    enum Action: Equatable {
        case setCount(Int)
        case setTitle(String)
        case setCity(String)
        case setStreet(String)
        case setTags([String])
        case setNonEquatable(Int)
        case noop
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .setCount(let count): state.count = count
        case .setTitle(let title): state.title = title
        case .setCity(let city): state.address.city = city
        case .setStreet(let street): state.address.street = street
        case .setTags(let tags): state.tags = tags
        case .setNonEquatable(let value): state.nonEquatable.value = value
        case .noop: break
        }
        return .none
    }
}
