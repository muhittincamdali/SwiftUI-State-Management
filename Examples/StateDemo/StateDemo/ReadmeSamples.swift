// The code samples of the README. The example app runs them, and the package's test target
// compiles this file (through a symbolic link) and tests them, so the README cannot drift from
// code that works.
import SwiftUI
import SwiftUIStateManagement

// MARK: - Quick start

/// Answers a question about a number. Stands for a network service.
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
}

extension NumberFacts {
    /// Works out a fact on the device after a short pause, so the demo needs no network.
    static let local = NumberFacts { number in
        try await Task.sleep(for: .milliseconds(400))
        switch number {
        case 0: return "0 is the only number that is neither positive nor negative."
        case let n where n < 0: return "\(n) is negative."
        case let n where n.isMultiple(of: 2): return "\(n) is even."
        default: return "\(number) is odd."
        }
    }
}

struct Counter: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoadingFact = false
    }

    enum Action: Equatable {
        case incrementTapped
        case decrementTapped
        case factTapped
        case factLoaded(String)
        case factFailed
    }

    let facts: NumberFacts

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .incrementTapped:
            state.count += 1
            state.fact = nil
            return .none
        case .decrementTapped:
            state.count -= 1
            state.fact = nil
            return .none
        case .factTapped:
            state.isLoadingFact = true
            return .run { [facts, count = state.count] send in
                send(.factLoaded(try await facts.fact(count)))
            } catch: { _, send in
                send(.factFailed)
            }
        case .factLoaded(let fact):
            state.isLoadingFact = false
            state.fact = fact
            return .none
        case .factFailed:
            state.isLoadingFact = false
            state.fact = "No fact this time."
            return .none
        }
    }
}

struct CounterView: View {
    let store: Store<Counter.State, Counter.Action>

    var body: some View {
        Form {
            Stepper("Count: \(store.count)") {
                store.send(.incrementTapped)
            } onDecrement: {
                store.send(.decrementTapped)
            }
            Button("Tell me a fact") { store.send(.factTapped) }
                .disabled(store.isLoadingFact)
            if let fact = store.fact {
                Text(fact)
            }
        }
    }
}

// MARK: - Effects and cancellation

struct Search: Reducer {
    struct State: Equatable {
        var query = ""
        var results: [String] = []
        var isSearching = false
    }

    enum Action: Equatable {
        case queryChanged(String)
        case resultsLoaded([String])
        case searchFailed
    }

    enum CancelID { case search }

    let search: @Sendable (String) async throws -> [String]
    let clock: any Clock<Duration>

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .queryChanged(let query):
            state.query = query
            guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                state.results = []
                state.isSearching = false
                return .cancel(id: CancelID.search)
            }
            state.isSearching = true
            // A new keystroke cancels the waiting search: only the last query runs.
            return .run(id: CancelID.search, cancelInFlight: true) { [search, clock] send in
                try await clock.sleep(for: .milliseconds(300))
                send(.resultsLoaded(try await search(query)))
            } catch: { _, send in
                send(.searchFailed)
            }
        case .resultsLoaded(let results):
            state.isSearching = false
            state.results = results
            return .none
        case .searchFailed:
            state.isSearching = false
            state.results = []
            return .none
        }
    }
}

// MARK: - Navigation state

struct Contacts: Reducer {
    struct Contact: Identifiable, Hashable, Codable, Sendable {
        var id: Int
        var name: String
    }

    struct NewContact: Identifiable, Equatable {
        var id: Int
        var name = ""
    }

    struct State: Equatable {
        var contacts: [Contact] = []
        /// The stack of a `NavigationStack`: the ids of the contacts pushed on it.
        var path: [Contact.ID] = []
        /// The sheet that adds a contact; `nil` when it is not shown.
        var newContact: NewContact?

        var newContactName: String { newContact?.name ?? "" }
    }

    enum Action: Equatable {
        case pathChanged([Contact.ID])
        case contactTapped(Contact.ID)
        case addTapped
        case newContactNameChanged(String)
        case saveTapped
        case newContactDismissed
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .pathChanged(let path):
            state.path = path
        case .contactTapped(let id):
            state.path.append(id)
        case .addTapped:
            state.newContact = NewContact(id: (state.contacts.map(\.id).max() ?? 0) + 1)
        case .newContactNameChanged(let name):
            state.newContact?.name = name
        case .saveTapped:
            guard let new = state.newContact, !new.name.isEmpty else { return .none }
            state.contacts.append(Contact(id: new.id, name: new.name))
            state.newContact = nil
        case .newContactDismissed:
            state.newContact = nil
        }
        return .none
    }
}

struct ContactsView: View {
    let store: Store<Contacts.State, Contacts.Action>

    var body: some View {
        NavigationStack(path: store.binding(\.path, send: Contacts.Action.pathChanged)) {
            List(store.contacts) { contact in
                Button(contact.name) { store.send(.contactTapped(contact.id)) }
            }
            .navigationDestination(for: Contacts.Contact.ID.self) { id in
                Text(store.contacts.first { $0.id == id }?.name ?? "Deleted")
            }
            .toolbar {
                Button("Add") { store.send(.addTapped) }
            }
            .sheet(item: store.binding(\.newContact, dismiss: .newContactDismissed)) { _ in
                Form {
                    TextField("Name", text: store.binding(\.newContactName, send: Contacts.Action.newContactNameChanged))
                    Button("Save") { store.send(.saveTapped) }
                }
            }
        }
    }
}

// MARK: - Persistence

struct Settings: Codable, Equatable, Sendable {
    var showsCompleted = true
    var sortOrder = SortOrder.newestFirst

    enum SortOrder: String, Codable, Sendable {
        case newestFirst
        case alphabetical
    }
}

extension PersistenceKey where Value == Settings {
    static let settings = PersistenceKey("settings", version: 1)
}

struct SettingsFeature: Reducer {
    struct State: Equatable {
        var settings = Settings()
    }

    enum Action: Equatable {
        case showsCompletedToggled(Bool)
        case sortOrderChanged(Settings.SortOrder)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .showsCompletedToggled(let isOn):
            state.settings.showsCompleted = isOn
        case .sortOrderChanged(let order):
            state.settings.sortOrder = order
        }
        return .none
    }
}

@MainActor
func makeSettingsStore(storage: some StateStorage) -> Store<SettingsFeature.State, SettingsFeature.Action> {
    let saved = (try? storage.load(.settings)) ?? Settings()
    return Store(
        initialState: SettingsFeature.State(settings: saved),
        reducer: SettingsFeature().persisting(\.settings, to: .settings, in: storage)
    )
}
