<!-- i18n-source: README.md@b40031a37de449c4b6b347a51e557e63c1f5981a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

SwiftUI State Management ist ein kleines Swift-6-Paket für unidirektionalen State in SwiftUI-Apps
ab iOS 17. Ein Feature ist ein Reducer: ein Wert mit einem `State`, einer `Action` und einer
Methode, die den State ändert und die asynchrone Arbeit zurückgibt, die gestartet werden soll. Ein
`Store` führt sie auf dem Main Actor aus und implementiert `Observable`; Views lesen ihn daher wie
ein `@Observable`-Modell, und er erfasst Lesezugriffe pro Property ohne Makros. Navigation ist
State, Persistenz ist ein einziger Reducer-Modifier, und `TestStore` prüft jede State-Änderung und
jede Action, die ein Effect sendet. Es hat keine Abhängigkeiten.

## Highlights

- **Unidirektionaler Fluss auf Basis von Observation** — Views lesen `store.count` und rufen
  `store.send(.incrementTapped)` auf; der Reducer ist der einzige Ort, an dem sich der State
  ändert. Das Lesen einer gespeicherten `Equatable`-Property wird einzeln erfasst, sodass eine
  View, die `count` anzeigt, nicht aktualisiert wird, wenn sich `title` ändert.
- **Effects, die sich abbrechen lassen** — `.run` startet einen Task auf dem Main Actor; versieh
  ihn mit einer ID, um ihn abzubrechen, oder lass `cancelInFlight` nur den neuesten behalten. Ein
  abgebrochener Effect kann keine veralteten Ergebnisse mehr senden, und der Store bricht alles ab,
  wenn er freigegeben wird.
- **Navigation als State** — `NavigationStack`-Pfade, Sheets, Alerts und Enum-Ziele über Bindings,
  die Actions senden, sodass Deep Links und Tests ohne View auskommen.
- **Persistenz** — `persisting(\.items, to: .todos, in: storage)` speichert nach jeder Änderung
  einen Teil des States, mit Debounce, bei Bedarf sofort geschrieben (Flush), außerhalb des Main
  Actors und in der richtigen Reihenfolge. Schlüssel sind versioniert, größenbegrenzt und
  validiert, sodass ein Name das Verzeichnis des Storage nicht verlassen kann.
- **Erschöpfende Tests** — `TestStore` schlägt mit einem zeilenweisen Unterschied fehl, wenn eine
  State-Änderung, eine empfangene Action oder ein übrig gebliebener Effect von dem abweicht, was
  der Test angibt; `TestClock` beendet einen Debounce, ohne zu warten.
- **Ehrlich bei den Alternativen** — der Leitfaden [Den passenden Ansatz wählen](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  sagt, wann einfache `@Observable`-Modelle genügen und wann
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
  die bessere Wahl ist.

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Bis 2.0.0 erscheint, stelle **Dependency Rule** auf **Branch** und gib `main` ein: Die Standardregel
wählt das letzte Release, 1.0.0, das noch die alte API enthält.

**2. Modul importieren**

```swift
import SwiftUIStateManagement
```

**3. Verwenden**

Beschreibe das Feature, zeige es an und erstelle den Store
([ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)):

```swift
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
```

`NumberFacts` steht für deinen Service: ein Struct mit einer asynchronen `fact(Int)`-Closure, sodass
Tests eine Attrappe übergeben können. Eine Version, die kein Netzwerk braucht:

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

Erstelle den Store einmal, dort, wo die Lebensdauer des Bildschirms beginnt:

```swift
@main
struct CounterApp: App {
    @State private var store = Store(initialState: Counter.State(), reducer: Counter(facts: .local))

    var body: some Scene {
        WindowGroup {
            CounterView(store: store)
        }
    }
}
```

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…**, gib die Repository-URL ein und füge
`SwiftUIStateManagement` deinem App-Target und `SwiftUIStateManagementTesting` deinem Test-Target
hinzu:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Bis 2.0.0 erscheint, stelle **Dependency Rule** auf **Branch** und gib `main` ein: Die Standardregel
wählt das letzte Release, 1.0.0, das noch die alte API enthält.

Oder füge es den `dependencies` in deiner `Package.swift` hinzu:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-State-Management.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftUIStateManagement", package: "SwiftUI-State-Management")
    ]),
    .testTarget(name: "YourAppTests", dependencies: [
        "YourApp",
        .product(name: "SwiftUIStateManagementTesting", package: "SwiftUI-State-Management")
    ])
]
```

## Verwendung

Die folgenden Beispiele sind aus
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift) kopiert, das die
Beispiel-App baut und die Testsuite ausführt.

### Effects und Abbruch

Eine Suche, die erst läuft, wenn der Nutzer 300 ms lang nicht getippt hat: Jeder Tastenanschlag
bricht die wartende Suche über `cancelInFlight` ab, und das Leeren des Felds bricht sie
vollständig ab. Die Uhr ist eine Abhängigkeit, sodass Tests eine `TestClock` übergeben können.

```swift
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
```

In der View verbindet `store.binding(\.query, send: Search.Action.queryChanged)` ein Textfeld.

### Navigations-State

Der Stack ist ein Array im State und das Sheet ein Optional. `binding(_:send:)` macht das Array
zum Pfad des `NavigationStack`, und `binding(_:dismiss:)` sendet `newContactDismissed`, wenn der
Nutzer das Sheet nach unten wischt:

```swift
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
```

`isPresented(_:dismiss:)` leistet dasselbe für Alerts und Bestätigungsdialoge. Der Leitfaden
[Navigations-State](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
behandelt Enum-Ziele, Deep Links und die Wiederherstellung des Stacks beim Start.

### Persistenz

Lade den gespeicherten Wert, wenn du den Store erstellst, und lass `persisting(_:to:in:)` jede
Änderung speichern:

```swift
extension PersistenceKey where Value == Settings {
    static let settings = PersistenceKey("settings", version: 1)
}

@MainActor
func makeSettingsStore(storage: some StateStorage) -> Store<SettingsFeature.State, SettingsFeature.Action> {
    let saved = (try? storage.load(.settings)) ?? Settings()
    return Store(
        initialState: SettingsFeature.State(settings: saved),
        reducer: SettingsFeature().persisting(\.settings, to: .settings, in: storage)
    )
}
```

Übergib in der App `try FileStorage.applicationSupport()` und in Tests und Previews einen
`InMemoryStorage`. Gespeicherte Daten tragen ihre Version; ein Schlüssel kann ältere Daten
migrieren, und eine gespeicherte Datei, die größer als das Limit des Schlüssels ist (standardmäßig
1 MiB), wird abgelehnt, bevor sie gelesen wird.

### Testen

`TestStore` prüft jede State-Änderung und jede Action, die ein Effect zurücksendet. Dieser Test aus
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) tippt
zwei Buchstaben und prüft, dass nur die zweite Anfrage gesucht wird:

```swift
let clock = TestClock()
let searched = Collected<String>()
let store = TestStore(
    initialState: Search.State(),
    reducer: Search(
        search: { query in
            searched.append(query)
            return ["\(query) result"]
        },
        clock: clock
    )
)
await store.send(.queryChanged("s")) {
    $0.query = "s"
    $0.isSearching = true
}
await store.send(.queryChanged("sw")) { $0.query = "sw" }
await clock.waitForSleepers()
clock.advance(by: .milliseconds(300))
await store.receive(.resultsLoaded(["sw result"])) {
    $0.isSearching = false
    $0.results = ["sw result"]
}
#expect(searched.values == ["sw"])
```

`Collected` ist ein kleines, durch ein Lock geschütztes Array im Test-Target. Der Test schlägt
fehl, wenn der Reducer den State auf andere Weise ändert, wenn eine andere Action eintrifft oder
wenn am Ende des Tests noch ein Effect läuft.

## Demo

Die App [StateDemo](Examples/StateDemo) führt jedes Thema mit der echten Bibliothek aus, auf iOS
und macOS. Die Screenshots stammen aus dem macOS-Build der App, der jedes Szenario mit denselben
Actions abspielt, die ein Nutzer senden würde; aufgenommen werden sie von
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) (der Modus `ios`
nimmt dieselben Szenarien in einem iPhone-Simulator auf):

| Todos | Per Deep Link geöffnetes Todo | Suche mit Debounce | Beobachtung pro Property |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Todo-Bildschirm: ein Filter, fünf Todos, zwei davon erledigt"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="Detailbildschirm des Todos 'Review the pull request', geöffnet über einen statedemo://-Link"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Suchbildschirm: Ergebnisse für 'Swift' nach vier Tastenanschlägen"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Beobachtungsbildschirm: Der Body der linken Karte lief viermal, der der rechten zweimal"></picture> |

Um sie auszuführen, öffne `StateDemo.xcodeproj` in [Examples/StateDemo](Examples/StateDemo) mit
Xcode 26 oder neuer, wähle einen iPhone-Simulator oder **My Mac** und drücke **Run**.
[Examples/README.md](Examples/README.md) beschreibt jeden Bildschirm.

## Dokumentation

API-Referenz und Artikel:

- [Referenz zu SwiftUIStateManagement](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [Referenz zu SwiftUIStateManagementTesting](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Erste Schritte](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Wie Observation funktioniert](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Den passenden Ansatz wählen](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Anleitungen

- [Erste Schritte](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — ein Feature, seine View und die App, die den Store besitzt.
- [Wie Observation funktioniert](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — welche Lesezugriffe eine View aktualisieren und wie du Updates klein hältst.
- [Effects und Abbruch](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — Fehler, Bezeichner, Debounce, an eine View gebundene Effects, Uhren.
- [Navigations-State](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — Stacks, Sheets, Alerts, Enum-Ziele, Deep Links und Wiederherstellung.
- [State persistent speichern](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — Schlüssel, Storages, Debounce und Flush, Migrationen und Limits.
- [Features testen](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock` und Tests mit dem echten Store.
- [Den passenden Ansatz wählen](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — einfache `@Observable`-Modelle, dieses Paket oder The Composable Architecture.

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Toolchain | Swift 6.2 · Xcode 26+ |

Die Mindestversionen sind die ersten Releases mit dem Observation-Framework. CI baut jede Plattform
und führt die Tests auf macOS und in einem iOS-Simulator aus.

## Architektur

Zwei Bibliotheken:

| Bibliothek | Typen |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, die Bindings, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Designentscheidungen:

- **State als Wert, ein einziger Registrar.** Der State ist ein Struct. Der Store hält ihn hinter
  einem `ObservationRegistrar` und registriert jeden Lesezugriff auf eine gespeicherte
  `Equatable`-Property unter deren eigenem Key Path (dem State-Key-Path des Stores mit angehängtem
  Pfad der Property). Nach einer Action vergleicht er diese Properties und benachrichtigt nur die,
  die sich geändert haben. Key Paths, die keine Kette gespeicherter Properties sind, fallen auf den
  gesamten State zurück, sodass der Store nie ein Subscript oder eine berechnete Property auf
  einem alten State auswertet.
- **Durchgehend Main Actor.** Reducer, Store und Effect-Operationen laufen auf dem Main Actor, was
  zu SwiftUI passt und `Send` von `Sendable`-Anforderungen an Actions freihält. Langsame Arbeit
  gehört in die Clients, auf die deine Effects warten.
- **Abhängigkeiten sind gespeicherte Properties.** Der API-Client oder die Uhr eines Reducers wird
  an seinen Initializer übergeben; es gibt keinen globalen Container, den man konfigurieren muss.
- **Probleme werden gemeldet, nicht abgefangen.** Ein Effect-Fehler ohne Handler oder eine
  außer Kontrolle geratene `Effect.send`-Schleife wird zu einem `StoreIssue` (nur Typnamen, nie
  Werte) und unter `TestStore` zu einem Testfehler. Die Persistenz weist ungültige Namen und
  Größen mit Fehlern zurück.

### Im Vergleich

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
ist die etablierte Bibliothek für diesen Stil und bietet weit mehr: Makros, die Boilerplate
entfernen und verschachtelten State verfolgen, ein Dependency-System, Navigationswerkzeuge für
Stacks und baumbasierte Präsentation, geteilten State, nicht erschöpfende Tests und eine große
Community. Nimm TCA, wenn deine App viele Features hat, die State oder Abhängigkeiten teilen, oder
wenn dein Team es kennt. Nimm dieses Paket, wenn du dieselbe unidirektionale Form mit einer
Oberfläche willst, die klein genug ist, um sie an einem Nachmittag zu lesen, ohne Abhängigkeiten
und ohne Makros. Einfache `@Observable`-Modelle bleiben die einfachste Wahl für kleine Bildschirme.
Der Leitfaden [Den passenden Ansatz wählen](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
vergleicht die drei im Detail.

## Roadmap

- Stack-Navigation von Child-Features: ein Parent, der einen Stack aus Child-States hält und die
  Actions jedes Childs über die Element-ID weiterleitet.
- Nicht erschöpfender `TestStore`-Modus für Integrationstests, die nur einige Änderungen prüfen.
- Linux-Unterstützung für die Reducer-, Effect- und Persistenzschichten, die kein SwiftUI brauchen.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
