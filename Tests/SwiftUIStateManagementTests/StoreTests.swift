import Foundation
import Testing
@testable import SwiftUIStateManagement
import SwiftUIStateManagementTesting

/// A feature whose actions start the different kinds of effects.
struct Jobs: Reducer {
    struct State: Equatable {
        var log: [String] = []
    }

    enum Action: Equatable {
        case start(String)
        case startTracked(String, cancelInFlight: Bool)
        case cancelTracked
        case finished(String)
        case chain(Int)
        case loopForever
        case fail
        case failHandled
        case handled(String)
        case sendTwice
    }

    enum CancelID { case tracked }

    let gate: Gate

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .start(let name):
            state.log.append("start \(name)")
            return .run { [gate] send in
                await gate.wait()
                send(.finished(name))
            }
        case .startTracked(let name, let cancelInFlight):
            state.log.append("start \(name)")
            return .run(id: CancelID.tracked, cancelInFlight: cancelInFlight) { [gate] send in
                await gate.wait()
                send(.finished(name))
            }
        case .cancelTracked:
            return .cancel(id: CancelID.tracked)
        case .finished(let name):
            state.log.append("finished \(name)")
            return .none
        case .chain(let remaining):
            state.log.append("chain \(remaining)")
            return remaining > 0 ? .send(.chain(remaining - 1)) : .none
        case .loopForever:
            return .send(.loopForever)
        case .fail:
            return .run { _ in throw SecretError(secret: "token=abc123") }
        case .failHandled:
            return .run { _ in
                throw SecretError(secret: "boom")
            } catch: { error, send in
                send(.handled((error as? SecretError)?.secret ?? "?"))
            }
        case .handled(let message):
            state.log.append("handled \(message)")
            return .none
        case .sendTwice:
            return .merge(.send(.finished("one")), .send(.finished("two")))
        }
    }
}

/// Holds effects until the test opens it. Cancelling a waiting task ends its wait.
final class Gate: Sendable {
    private let clock = TestClock()

    func wait() async {
        try? await clock.sleep(for: .seconds(1))
    }

    func open() {
        clock.advance(by: .seconds(1))
    }

    func waitForWaiters(_ count: Int) async {
        await clock.waitForSleepers(count: count)
    }

    var waiterCount: Int { clock.sleeperCount }
}

@Suite("Store")
@MainActor
struct StoreTests {
    @Test("The state has changed when send returns")
    func synchronousUpdate() {
        let store = Store(initialState: Counter.State(), reducer: Counter(facts: .local))
        store.send(.incrementTapped)
        store.send(.incrementTapped)
        store.send(.decrementTapped)
        #expect(store.count == 1)
    }

    @Test("Actions sent with Effect.send are processed, in order, before send returns")
    func effectSend() {
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        store.send(.chain(2))
        #expect(store.log == ["chain 2", "chain 1", "chain 0"])
        store.send(.sendTwice)
        #expect(store.log.suffix(2) == ["finished one", "finished two"])
    }

    @Test("finish() waits for the effects of a send and their actions")
    func finishWaits() async {
        let gate = Gate()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        let task = store.send(.start("a"))
        await gate.waitForWaiters(1)
        gate.open()
        await task.finish()
        #expect(store.log == ["start a", "finished a"])
    }

    @Test("Cancelling a StoreTask cancels its effects, and their late actions are ignored")
    func cancelStoreTask() async {
        let gate = Gate()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        let task = store.send(.start("a"))
        await gate.waitForWaiters(1)
        task.cancel()
        await task.finish()
        #expect(task.isCancelled)
        #expect(store.log == ["start a"])
    }

    @Test("A StoreTask without effects is not cancelled")
    func emptyStoreTask() async {
        let store = Store(initialState: Counter.State(), reducer: Counter(facts: .local))
        let task = store.send(.incrementTapped)
        #expect(!task.isCancelled)
        await task.finish()
    }

    @Test("cancel(id:) cancels the running effects with that id")
    func cancelByID() async {
        let gate = Gate()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        let first = store.send(.startTracked("a", cancelInFlight: false))
        let second = store.send(.startTracked("b", cancelInFlight: false))
        await gate.waitForWaiters(2)
        store.send(.cancelTracked)
        await first.finish()
        await second.finish()
        #expect(store.log == ["start a", "start b"])
        #expect(gate.waiterCount == 0)
    }

    @Test("cancelInFlight keeps only the newest effect with the same id")
    func cancelInFlight() async {
        let gate = Gate()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        let first = store.send(.startTracked("a", cancelInFlight: true))
        let second = store.send(.startTracked("b", cancelInFlight: true))
        await first.finish()
        #expect(first.isCancelled)
        await gate.waitForWaiters(1)
        gate.open()
        await second.finish()
        #expect(store.log == ["start a", "start b", "finished b"])
    }

    @Test("Effects are cancelled when the store is deallocated")
    func deallocationCancels() async {
        let gate = Gate()
        var store: Store<Jobs.State, Jobs.Action>? = Store(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        let task = store?.send(.start("a"))
        await gate.waitForWaiters(1)
        store = nil
        await task?.finish()
        #expect(task?.isCancelled == true)
        #expect(gate.waiterCount == 0)
    }

    @Test("Actions that send each other forever stop at the limit and are reported")
    func synchronousLoopLimit() {
        let issues = Collected<StoreIssue>()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: Gate())) { issues.append($0) }
        store.send(.loopForever)
        #expect(issues.values == [StoreIssue(
            kind: .synchronousActionLimitExceeded(limit: StoreLimits.synchronousActions),
            actionType: String(reflecting: Jobs.Action.self)
        )])
        // The store still works afterwards.
        store.send(.chain(0))
        #expect(store.log == ["chain 0"])
    }

    @Test("An unhandled effect error is reported with type names only, never with its values")
    func unhandledErrorIsReportedWithoutValues() async {
        let issues = Collected<StoreIssue>()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: Gate())) { issues.append($0) }
        await store.send(.fail).finish()
        let issue = try? #require(issues.values.first)
        #expect(issue?.kind == .unhandledEffectError(errorType: String(reflecting: SecretError.self)))
        #expect(issue?.description.contains("abc123") == false)
        #expect(issue?.description.contains("token") == false)
    }

    @Test("A catch handler turns an effect error into an action")
    func handledError() async {
        let issues = Collected<StoreIssue>()
        let store = Store(initialState: Jobs.State(), reducer: Jobs(gate: Gate())) { issues.append($0) }
        await store.send(.failHandled).finish()
        #expect(store.log == ["handled boom"])
        #expect(issues.values.isEmpty)
    }

    @Test("The quick start counter loads a fact through its effect")
    func counterFact() async {
        let store = Store(
            initialState: Counter.State(count: 4),
            reducer: Counter(facts: NumberFacts { "\($0) is a test number." })
        )
        await store.send(.factTapped).finish()
        #expect(store.fact == "4 is a test number.")
        #expect(!store.isLoadingFact)
    }

    @Test("send(_:animation:) processes the action like send(_:)")
    func sendWithAnimation() {
        let store = Store(initialState: Counter.State(), reducer: Counter(facts: .local))
        store.send(.incrementTapped, animation: .default)
        #expect(store.count == 1)
    }
}
