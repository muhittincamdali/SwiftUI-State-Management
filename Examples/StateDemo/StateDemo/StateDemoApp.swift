import SwiftUI
import SwiftUIStateManagement

@main
struct StateDemoApp: App {
    @State private var model = AppModel(launch: DemoLaunch.current)

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .tint(.blue)
                .preferredColorScheme(DemoLaunch.colorScheme)
        }
        #if os(macOS)
        .defaultSize(width: 440, height: 760)
        #endif
    }
}

/// The screens of the demo.
enum DemoTab: String, CaseIterable, Hashable {
    case todos, search, counter, observation
}

/// How the app was launched: normally, or with `-demo <name>` to play a scripted scenario for
/// the README screenshots (`scripts/capture-example-screens.sh`).
enum DemoLaunch: Equatable {
    case normal
    case scenario(String)

    static var current: DemoLaunch {
        guard let name = UserDefaults.standard.string(forKey: "demo") else { return .normal }
        return .scenario(name)
    }

    /// `-appearance light` or `-appearance dark` fixes the color scheme for screenshots.
    static var colorScheme: ColorScheme? {
        switch UserDefaults.standard.string(forKey: "appearance") {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
}

/// Owns one store per screen for the lifetime of the app.
@MainActor
@Observable
final class AppModel {
    var tab: DemoTab
    let todos: Store<Todos.State, Todos.Action>
    let search: Store<Search.State, Search.Action>
    let counter: Store<Counter.State, Counter.Action>
    let renderCounts: Store<RenderCounts.State, RenderCounts.Action>
    private let launch: DemoLaunch

    init(launch: DemoLaunch) {
        self.launch = launch
        let storage: any StateStorage
        if case .scenario = launch {
            // Screenshots start from the same sample data on every run.
            storage = InMemoryStorage()
            try? storage.save(SampleData.todos, for: .todos)
        } else {
            storage = (try? FileStorage.applicationSupport(subdirectory: "StateDemo")) ?? InMemoryStorage()
        }
        let items = (try? storage.load(.todos)) ?? []
        let path = (try? storage.load(.todoPath)) ?? []
        todos = Store(
            initialState: Todos.State.restored(items: items, path: path),
            reducer: Todos(makeID: UUID.init).persisting(in: storage)
        )
        search = Store(
            initialState: Search.State(),
            reducer: Search(search: SampleData.searchFrameworks, clock: ContinuousClock())
        )
        counter = Store(initialState: Counter.State(), reducer: Counter(facts: .local))
        renderCounts = Store(initialState: RenderCounts.State(), reducer: RenderCounts())

        switch launch {
        case .normal, .scenario("todos"): tab = .todos
        case .scenario("todo-detail"): tab = .todos
        case .scenario("search"): tab = .search
        case .scenario("counter"): tab = .counter
        case .scenario: tab = .observation
        }
    }

    var isPlayingScenario: Bool {
        launch != .normal
    }

    /// Plays the scenario named by `-demo`, with the same actions a user would send.
    func playScenario() async {
        guard case .scenario(let name) = launch else { return }
        switch name {
        case "todo-detail":
            todos.send(.openURL(TodoLink.url(for: SampleData.todos[1].id)))
        case "search":
            for query in ["S", "Sw", "Swi", "Swift"] {
                search.send(.queryChanged(query))
                try? await Task.sleep(for: .milliseconds(120))
            }
        case "counter":
            for _ in 0..<7 { counter.send(.incrementTapped) }
            await counter.send(.factTapped).finish()
        case "observation":
            for _ in 0..<3 {
                renderCounts.send(.leftTapped)
                try? await Task.sleep(for: .milliseconds(150))
            }
            renderCounts.send(.rightTapped)
        default:
            break
        }
    }
}

struct RootView: View {
    @Bindable var model: AppModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        content
            .onOpenURL { url in
                model.tab = .todos
                model.todos.send(.openURL(url))
            }
            .onChange(of: scenePhase) { _, phase in
                // Scene-based lifecycle: write pending saves before the app may be suspended.
                if phase == .background {
                    model.todos.send(.movedToBackground)
                }
            }
            .task {
                await model.playScenario()
            }
    }

    @ViewBuilder
    private var content: some View {
        #if os(macOS)
        if model.isPlayingScenario {
            // The macOS screenshots show one screen per window, without the tab bar.
            screen(model.tab)
        } else {
            tabs
        }
        #else
        tabs
        #endif
    }

    @ViewBuilder
    private func screen(_ tab: DemoTab) -> some View {
        switch tab {
        case .todos: TodosView(store: model.todos)
        case .search: SearchView(store: model.search)
        case .counter:
            NavigationStack {
                CounterView(store: model.counter)
                    .navigationTitle("Counter")
            }
        case .observation: RenderCountsView(store: model.renderCounts)
        }
    }

    private var tabs: some View {
        TabView(selection: $model.tab) {
            TodosView(store: model.todos)
                .tabItem { Label("Todos", systemImage: "checklist") }
                .tag(DemoTab.todos)
            SearchView(store: model.search)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(DemoTab.search)
            NavigationStack {
                CounterView(store: model.counter)
                    .navigationTitle("Counter")
            }
            .tabItem { Label("Counter", systemImage: "number") }
            .tag(DemoTab.counter)
            RenderCountsView(store: model.renderCounts)
                .tabItem { Label("Observation", systemImage: "eye") }
                .tag(DemoTab.observation)
        }
    }
}
