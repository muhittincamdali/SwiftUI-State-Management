import SwiftUI
import SwiftUIStateManagement

// MARK: - Search

struct SearchView: View {
    let store: Store<Search.State, Search.Action>

    var body: some View {
        NavigationStack {
            List {
                if store.isSearching {
                    HStack {
                        ProgressView()
                        Text("Waiting for you to stop typing…")
                            .foregroundStyle(.secondary)
                    }
                }
                ForEach(store.results, id: \.self) { result in
                    Text(result)
                }
            }
            .overlay {
                if store.query.isEmpty {
                    ContentUnavailableView(
                        "Search Apple frameworks",
                        systemImage: "magnifyingglass",
                        description: Text("Each keystroke cancels the waiting search; only the last query runs, 300 ms after you stop typing.")
                    )
                }
            }
            .navigationTitle("Search")
            .searchable(text: store.binding(\.query, send: Search.Action.queryChanged))
        }
    }
}

// MARK: - Observation

/// Two counters in one state, shown by two views that each read one of them.
struct RenderCounts: Reducer {
    struct State: Equatable {
        var left = 0
        var right = 0
    }

    enum Action: Equatable {
        case leftTapped
        case rightTapped
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .leftTapped: state.left += 1
        case .rightTapped: state.right += 1
        }
        return .none
    }
}

/// Counts how often a view's body runs. Not observable on purpose: reading it must not cause
/// updates of its own.
final class BodyCounter {
    private(set) var count = 0

    func tick() -> Int {
        count += 1
        return count
    }
}

struct RenderCountsView: View {
    let store: Store<RenderCounts.State, RenderCounts.Action>

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CounterCard(title: "Left", store: store, value: \.left, action: .leftTapped)
                    CounterCard(title: "Right", store: store, value: \.right, action: .rightTapped)
                } footer: {
                    Text("Each card reads one property through the store. Tapping one card runs only that card's body: the store notifies observers per property.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Observation")
        }
    }
}

private struct CounterCard: View {
    let title: String
    let store: Store<RenderCounts.State, RenderCounts.Action>
    let value: KeyPath<RenderCounts.State, Int>
    let action: RenderCounts.Action
    @State private var bodyCounter = BodyCounter()

    var body: some View {
        let renders = bodyCounter.tick()
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(title): \(store[dynamicMember: value])")
                    .font(.title2.monospacedDigit())
                Text("body ran \(renders) \(renders == 1 ? "time" : "times")")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Add one") { store.send(action) }
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sample data

enum SampleData {
    static let todos: [Todo] = [
        Todo(id: UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964F1")!, title: "Book train tickets", isDone: true),
        Todo(id: UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964F2")!, title: "Review the pull request", notes: "Check the migration of saved settings."),
        Todo(id: UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964F3")!, title: "Buy oat milk"),
        Todo(id: UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964F4")!, title: "Call the dentist", isDone: true),
        Todo(id: UUID(uuidString: "6F9619FF-8B86-D011-B42D-00C04FC964F5")!, title: "Water the plants"),
    ]

    static let frameworks = [
        "Accessibility", "ActivityKit", "AppIntents", "AVFoundation", "CloudKit", "Combine", "Core Data",
        "Core Location", "Foundation", "MapKit", "Observation", "PhotosUI", "RealityKit", "StoreKit",
        "Swift Charts", "Swift Testing", "SwiftData", "SwiftUI", "TipKit", "UIKit", "WeatherKit", "WidgetKit",
    ]

    /// Searches the framework names; stands for a network search.
    @Sendable
    static func searchFrameworks(_ query: String) async throws -> [String] {
        try await Task.sleep(for: .milliseconds(150))
        return frameworks.filter { $0.localizedStandardContains(query) }
    }
}
