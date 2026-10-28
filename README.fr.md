<!-- i18n-source: README.md@b40031a37de449c4b6b347a51e557e63c1f5981a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Dernière version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

SwiftUI State Management est un petit package Swift 6 pour gérer un état unidirectionnel dans les
apps SwiftUI à partir d’iOS 17. Une fonctionnalité est un reducer : une valeur avec un `State`, une
`Action` et une méthode qui modifie l’état et renvoie le travail asynchrone à lancer. Un `Store`
l’exécute sur le main actor et implémente `Observable` ; les vues le lisent donc comme un modèle
`@Observable`, et il suit les lectures propriété par propriété, sans macros. La navigation est de
l’état, la persistance est un seul modificateur de reducer, et `TestStore` vérifie chaque
changement d’état et chaque action qu’un effect envoie. Il n’a aucune dépendance.

## Points forts

- **Flux unidirectionnel sur Observation** — les vues lisent `store.count` et appellent
  `store.send(.incrementTapped)` ; le reducer est le seul endroit où l’état change. La lecture
  d’une propriété stockée `Equatable` est suivie séparément : une vue qui affiche `count` n’est
  donc pas mise à jour quand `title` change.
- **Des effects annulables** — `.run` lance une tâche sur le main actor ; donnez-lui un id pour
  pouvoir l’annuler, ou laissez `cancelInFlight` ne garder que la plus récente. Un effect annulé
  ne peut pas envoyer de résultats périmés, et le store annule tout lorsqu’il disparaît.
- **La navigation comme état** — chemins de `NavigationStack`, sheets, alertes et destinations
  sous forme d’enum, via des bindings qui envoient des actions : les deep links et les tests n’ont
  besoin d’aucune vue.
- **Persistance** — `persisting(\.items, to: .todos, in: storage)` enregistre une partie de
  l’état après chaque changement, avec debounce, écriture immédiate à la demande (flush), en
  dehors du main actor et dans l’ordre. Les clés sont versionnées, limitées en taille et validées :
  un nom ne peut donc pas sortir du répertoire du storage.
- **Des tests exhaustifs** — `TestStore` échoue avec une différence ligne par ligne lorsqu’un
  changement d’état, une action reçue ou un effect restant diffère de ce que dit le test ;
  `TestClock` termine un debounce sans attendre.
- **Honnête sur les alternatives** — le guide [Choisir une approche](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  explique quand de simples modèles `@Observable` suffisent et quand
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
  est le meilleur choix.

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Jusqu’à la sortie de la 2.0.0, réglez **Dependency Rule** sur **Branch** et saisissez `main` : la
règle par défaut choisit la dernière version publiée, la 1.0.0, qui a encore l’ancienne API.

**2. Importer le module**

```swift
import SwiftUIStateManagement
```

**3. L’utiliser**

Décrivez la fonctionnalité, affichez-la et créez le store
([ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)) :

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

`NumberFacts` représente votre service : un struct avec une closure asynchrone `fact(Int)`, afin que
les tests puissent en passer une factice. Une version qui n’a pas besoin du réseau :

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

Créez le store une seule fois, là où commence la durée de vie de l’écran :

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

Dans Xcode, choisissez **File › Add Package Dependencies…**, saisissez l’URL du dépôt et ajoutez
`SwiftUIStateManagement` à la cible de votre app et `SwiftUIStateManagementTesting` à votre cible
de tests :

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Jusqu’à la sortie de la 2.0.0, réglez **Dependency Rule** sur **Branch** et saisissez `main` : la
règle par défaut choisit la dernière version publiée, la 1.0.0, qui a encore l’ancienne API.

Ou ajoutez-le aux `dependencies` de votre `Package.swift` :

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

## Utilisation

Les exemples ci-dessous sont copiés depuis
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift), que l’app d’exemple
compile et que la suite de tests exécute.

### Effects et annulation

Une recherche qui ne s’exécute qu’une fois que l’utilisateur a cessé de taper pendant 300 ms :
chaque frappe annule la recherche en attente grâce à `cancelInFlight`, et vider le champ l’annule
purement et simplement. L’horloge est une dépendance : les tests peuvent donc passer une
`TestClock`.

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

Dans la vue, `store.binding(\.query, send: Search.Action.queryChanged)` relie un champ de texte.

### État de navigation

La pile est un tableau dans l’état et la sheet est un optionnel. `binding(_:send:)` transforme le
tableau en chemin du `NavigationStack`, et `binding(_:dismiss:)` envoie `newContactDismissed`
lorsque l’utilisateur fait glisser la sheet vers le bas :

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

`isPresented(_:dismiss:)` fait la même chose pour les alertes et les boîtes de dialogue de
confirmation. Le guide
[État de navigation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
traite des destinations sous forme d’enum, des deep links et de la restauration de la pile au
lancement.

### Persistance

Chargez la valeur enregistrée lorsque vous créez le store, et laissez `persisting(_:to:in:)`
enregistrer chaque changement :

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

Passez `try FileStorage.applicationSupport()` dans l’app et un `InMemoryStorage` dans les tests et
les previews. Les données enregistrées portent leur version ; une clé peut migrer d’anciennes
données, et un fichier enregistré plus grand que la limite de la clé (1 MiB par défaut) est refusé
avant d’être lu.

### Tests

`TestStore` vérifie chaque changement d’état et chaque action qu’un effect renvoie. Ce test de
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) saisit
deux lettres et vérifie que seule la seconde requête est recherchée :

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

`Collected` est un petit tableau protégé par un verrou, dans la cible de tests. Le test échoue si
le reducer modifie l’état d’une autre manière, si une autre action arrive ou si un effect est
encore en cours à la fin du test.

## Démo

L’app [StateDemo](Examples/StateDemo) exécute chaque sujet avec la vraie bibliothèque, sur iOS et
macOS. Les captures d’écran proviennent de la version macOS de l’app, qui joue chaque scénario
avec les mêmes actions que celles d’un utilisateur ; elles sont prises par
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) (son mode `ios`
capture les mêmes scénarios sur un simulateur d’iPhone) :

| Tâches | Tâche ouverte par un deep link | Recherche avec debounce | Observation par propriété |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Écran des tâches : un filtre, cinq tâches, dont deux terminées"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="Écran de détail de la tâche « Review the pull request », ouvert par un lien statedemo://"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Écran de recherche : résultats pour « Swift » après quatre frappes"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Écran d’observation : le body de la carte de gauche s’est exécuté quatre fois, celui de la carte de droite deux fois"></picture> |

Pour l’exécuter, ouvrez `StateDemo.xcodeproj` dans [Examples/StateDemo](Examples/StateDemo) avec
Xcode 26 ou version ultérieure, choisissez un simulateur d’iPhone ou **My Mac**, puis appuyez sur
**Run**. [Examples/README.md](Examples/README.md) décrit chaque écran.

## Documentation

Référence de l’API et articles :

- [Référence de SwiftUIStateManagement](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [Référence de SwiftUIStateManagementTesting](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Premiers pas](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Comment fonctionne Observation](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Choisir une approche](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Guides

- [Premiers pas](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — une fonctionnalité, sa vue et l’app qui possède le store.
- [Comment fonctionne Observation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — quelles lectures mettent à jour une vue, et comment garder les mises à jour petites.
- [Effects et annulation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — erreurs, identifiants, debounce, effects liés à une vue, horloges.
- [État de navigation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — piles, sheets, alertes, destinations sous forme d’enum, deep links et restauration.
- [Persister l’état](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — clés, storages, debounce et flush, migrations et limites.
- [Tester les fonctionnalités](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock`, et tests avec le vrai store.
- [Choisir une approche](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — de simples modèles `@Observable`, ce package ou The Composable Architecture.

## Prérequis

| Plateforme | Version minimale |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Chaîne d’outils | Swift 6.2 · Xcode 26+ |

Les versions minimales sont les premières à inclure le framework Observation. La CI compile toutes
les plateformes et exécute les tests sur macOS et sur un simulateur iOS.

## Architecture

Deux bibliothèques :

| Bibliothèque | Types |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, les bindings, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Choix de conception :

- **Un état par valeur, un seul registrar.** L’état est un struct. Le store le garde derrière un
  `ObservationRegistrar` et enregistre chaque lecture d’une propriété stockée `Equatable` sous son
  propre key path (le key path de l’état du store, auquel on ajoute le chemin de la propriété).
  Après une action, il compare ces propriétés et ne notifie que celles qui ont changé. Les key
  paths qui ne sont pas une chaîne de propriétés stockées retombent sur l’état entier : le store
  n’évalue ainsi jamais un subscript ou une propriété calculée sur un ancien état.
- **Le main actor partout.** Les reducers, le store et les opérations des effects s’exécutent sur
  le main actor, ce qui correspond à SwiftUI et évite à `Send` d’imposer `Sendable` aux actions.
  Le travail lent appartient aux clients qu’attendent vos effects.
- **Les dépendances sont des propriétés stockées.** Le client d’API ou l’horloge d’un reducer est
  passé à son initialiseur ; il n’y a aucun conteneur global à configurer.
- **Les problèmes sont signalés, pas fatals.** Une erreur d’effect sans gestionnaire ou une boucle
  d’`Effect.send` hors de contrôle devient un `StoreIssue` (uniquement des noms de types, jamais
  de valeurs) et un échec de test sous `TestStore`. La persistance rejette par des erreurs les noms
  et les tailles non valides.

### Comparaison

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
est la bibliothèque de référence pour ce style et offre bien plus : des macros qui suppriment le
code répétitif et suivent l’état imbriqué, un système de dépendances, des outils de navigation pour
les piles et la présentation arborescente, l’état partagé, les tests non exhaustifs et une grande
communauté. Utilisez TCA lorsque votre app compte de nombreuses fonctionnalités qui partagent de
l’état ou des dépendances, ou lorsque votre équipe la connaît. Utilisez ce package lorsque vous
voulez la même forme unidirectionnelle avec une surface assez petite pour être lue en un
après-midi, sans dépendances et sans macros. De simples modèles `@Observable` restent le choix le
plus simple pour les petits écrans. Le guide
[Choisir une approche](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
compare les trois en détail.

## Feuille de route

- Navigation en pile de fonctionnalités enfants : un parent qui détient une pile d’états enfants
  et route les actions de chaque enfant par id d’élément.
- Mode non exhaustif de `TestStore`, pour des tests d’intégration qui ne vérifient que certains
  changements.
- Prise en charge de Linux pour les couches reducer, effect et persistance, qui n’ont pas besoin de
  SwiftUI.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
