import Foundation
import Testing
@testable import SwiftUIStateManagement
@testable import SwiftUIStateManagementTesting

@Suite("TestStore")
@MainActor
struct TestStoreTests {
    @Test("A correct description of each change passes")
    func passingFlow() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(1)) { $0.log = ["chain 1"] }
        await store.receive(.chain(0)) { $0.log.append("chain 0") }
        #expect(store.state.log == ["chain 1", "chain 0"])
    }

    @Test("A wrong description of the change fails with a line-by-line difference")
    func wrongUpdate() async {
        let store = TestStore(initialState: Counter.State(), reducer: Counter(facts: .local))
        await withKnownIssue {
            await store.send(.incrementTapped) { $0.count = 2 }
        } matching: { issue in
            let text = issue.comments.map(\.rawValue).joined()
            return text.contains("− ") && text.contains("count: 2") && text.contains("+ ") && text.contains("count: 1")
        }
        #expect(store.state.count == 1)
    }

    @Test("A change that the test does not describe fails")
    func undescribedChange() async {
        let store = TestStore(initialState: Counter.State(), reducer: Counter(facts: .local))
        await withKnownIssue {
            await store.send(.incrementTapped)
        }
    }

    @Test("Receiving waits for the action of a running effect")
    func receiveWaits() async {
        let gate = Gate()
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        await store.send(.start("a")) { $0.log = ["start a"] }
        await gate.waitForWaiters(1)
        gate.open()
        await store.receive(.finished("a")) { $0.log.append("finished a") }
    }

    @Test("Receiving another action than expected fails")
    func unexpectedAction() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(1)) { $0.log = ["chain 1"] }
        await withKnownIssue {
            await store.receive(.chain(5)) { $0.log.append("chain 0") }
        }
    }

    @Test("receive(matching:) checks actions that are not Equatable")
    func receiveMatching() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(1)) { $0.log = ["chain 1"] }
        await store.receive(matching: { if case .chain = $0 { true } else { false } }) {
            $0.log.append("chain 0")
        }
    }

    @Test("Receiving fails at once when no effect is running")
    func receiveWithoutEffects() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()), timeout: .seconds(30))
        let start = ContinuousClock.now
        await withKnownIssue {
            await store.receive(.finished("never"))
        }
        #expect(ContinuousClock.now - start < .seconds(5))
    }

    @Test("Receiving fails after the timeout when the effect sends nothing in time")
    func receiveTimeout() async {
        let gate = Gate()
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        await store.send(.start("slow")) { $0.log = ["start slow"] }
        await withKnownIssue {
            await store.receive(.finished("slow"), timeout: .milliseconds(50))
        }
        store.cancelInFlightEffects()
        await store.finish()
    }

    @Test("Sending before checking received actions fails")
    func sendWithUnreceivedActions() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(1)) { $0.log = ["chain 1"] }
        await withKnownIssue {
            await store.send(.chain(0)) { $0.log.append(contentsOf: ["chain 0", "chain 0"]) }
        }
    }

    @Test("skipReceivedActions discards actions the test does not care about")
    func skipReceived() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(3)) { $0.log = ["chain 3"] }
        store.skipReceivedActions()
        await store.send(.cancelTracked)
    }

    @Test("Received actions left unchecked fail when the store goes away")
    func unreceivedAtExit() async {
        await withKnownIssue {
            let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
            await store.send(.chain(1)) { $0.log = ["chain 1"] }
        }
    }

    @Test("Effects still running fail when the store goes away")
    func runningAtExit() async {
        let gate = Gate()
        await withKnownIssue {
            let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: gate))
            await store.send(.start("forever")) { $0.log = ["start forever"] }
        }
    }

    @Test("finish waits for effects, and fails when they outlive the timeout")
    func finish() async {
        let gate = Gate()
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: gate))
        await store.send(.start("a")) { $0.log = ["start a"] }
        await withKnownIssue {
            await store.finish(timeout: .milliseconds(50))
        }
        gate.open()
        await store.receive(.finished("a")) { $0.log.append("finished a") }
        await store.finish()
    }

    @Test("An error that an effect does not handle fails the test")
    func unhandledError() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await withKnownIssue {
            await store.send(.fail).finish()
        }
    }

    @Test("Actions that send each other forever fail instead of hanging")
    func loopLimit() async {
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await withKnownIssue {
            await store.send(.loopForever)
        }
        store.skipReceivedActions()
    }

    @Test("A failure message stays bounded for a very large state")
    func boundedDifference() {
        let expected = Array(0..<100_000)
        var actual = expected
        actual[50_000] = -1
        let message = Difference.lines(expected: expected, actual: actual)
        #expect(message.split(separator: "\n").count <= 2 * Difference.maximumLines + 5)
        #expect(message.utf8.count < 20_000)
    }

    @Test("A failure message lists at most maximumLines unchecked actions")
    func boundedActionList() async {
        let isBounded: @Sendable (Issue) -> Bool = { issue in
            let text = issue.comments.map(\.rawValue).joined(separator: "\n")
            return text.contains("… \(500 - Difference.maximumLines) more")
                && text.split(separator: "\n").count <= Difference.maximumLines + 2
        }
        let store = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
        await store.send(.chain(500)) { $0.log = ["chain 500"] }
        await withKnownIssue {
            await store.send(.cancelTracked)
        } matching: { isBounded($0) }

        await withKnownIssue {
            let leftUnchecked = TestStore(initialState: Jobs.State(), reducer: Jobs(gate: Gate()))
            await leftUnchecked.send(.chain(500)) { $0.log = ["chain 500"] }
        } matching: { isBounded($0) }
    }

    @Test("The difference shows only the lines that changed")
    func differenceContent() {
        let message = Difference.lines(
            expected: Counter.State(count: 1, fact: nil),
            actual: Counter.State(count: 2, fact: nil)
        )
        #expect(message.contains("−   - count: 1"))
        #expect(message.contains("+   - count: 2"))
        #expect(!message.contains("isLoadingFact"))
    }
}

@Suite("TestClock")
struct TestClockTests {
    @Test("A sleep ends when the clock reaches its deadline, not before")
    func sleepEnds() async throws {
        let clock = TestClock()
        let woke = CallCounter()
        let task = Task {
            try await clock.sleep(for: .seconds(10))
            woke.increment()
        }
        #expect(await clock.waitForSleepers())
        clock.advance(by: .seconds(9))
        try await Task.sleep(for: .milliseconds(20))
        #expect(woke.count == 0)
        clock.advance(by: .seconds(1))
        try await task.value
        #expect(woke.count == 1)
        #expect(clock.now.offset == .seconds(10))
    }

    @Test("A sleep with a past deadline returns at once")
    func pastDeadline() async throws {
        let clock = TestClock()
        clock.advance(by: .seconds(5))
        try await clock.sleep(until: TestClock.Instant(offset: .seconds(1)))
    }

    @Test("A cancelled sleep throws CancellationError and leaves no sleeper behind")
    func cancelledSleep() async {
        let clock = TestClock()
        let task = Task { try await clock.sleep(for: .seconds(1)) }
        await clock.waitForSleepers()
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(clock.sleeperCount == 0)
    }

    @Test("waitForSleepers returns false after its timeout")
    func waitTimeout() async {
        let clock = TestClock()
        #expect(await clock.waitForSleepers(count: 1, timeout: .milliseconds(20)) == false)
    }

    @Test("Moving backwards is a test failure and leaves the clock where it is")
    func negativeAdvance() {
        let clock = TestClock()
        withKnownIssue {
            clock.advance(by: .seconds(-1))
        }
        #expect(clock.now.offset == .zero)
    }
}
