<!-- i18n-source: README.md@cb1a4ebaa23d3b3d094095fce21161ccf8f401f7 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

SwiftUI State Management — небольшой пакет на Swift 6 для однонаправленного состояния в
приложениях SwiftUI, начиная с iOS 17. Функциональность описывается reducer'ом: значением с
`State`, `Action` и одним методом, который изменяет состояние и возвращает асинхронную работу,
которую нужно запустить. `Store` выполняет его на main actor и реализует `Observable`, поэтому
представления читают его как модель `@Observable`, а чтения отслеживаются по свойствам без
макросов. Навигация — это состояние, сохранение — один модификатор reducer'а, а `TestStore`
проверяет каждое изменение состояния и каждое действие, которое отправляет effect. Зависимостей у
пакета нет.

## Основные возможности

- **Однонаправленный поток на Observation** — представления читают `store.count` и вызывают
  `store.send(.incrementTapped)`; состояние меняется только в reducer'е. Чтение хранимого
  свойства `Equatable` отслеживается отдельно, поэтому представление, которое показывает `count`,
  не обновляется при изменении `title`.
- **Effect'ы, которые можно отменить** — `.run` запускает задачу на main actor; пометьте её id,
  чтобы отменить, или позвольте `cancelInFlight` оставить только самую новую. Отменённый effect не
  может отправить устаревший результат, а store отменяет всё, когда освобождается.
- **Навигация как состояние** — пути `NavigationStack`, sheet'ы, alert'ы и пункты назначения в
  виде enum работают через binding'и, отправляющие действия, поэтому deep link'ам и тестам
  представление не нужно.
- **Сохранение** — `persisting(\.items, to: .todos, in: storage)` сохраняет часть состояния после
  каждого изменения: с debounce, с немедленной записью по запросу (flush), вне main actor и по
  порядку. Ключи версионированы, ограничены по размеру и проверяются, поэтому имя не может
  выйти за пределы каталога хранилища.
- **Исчерпывающие тесты** — `TestStore` падает с построчным различием, если изменение состояния,
  полученное действие или оставшийся effect отличаются от того, что написано в тесте; `TestClock`
  завершает debounce, не дожидаясь.
- **Честно об альтернативах** — руководство [Выбор подхода](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  объясняет, когда достаточно обычных моделей `@Observable`, а когда лучше выбрать
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

**2. Импортируйте модуль**

```swift
import SwiftUIStateManagement
```

**3. Используйте**

Опишите функциональность, покажите её и создайте store
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

`NumberFacts` обозначает ваш сервис: struct с асинхронным замыканием `fact(Int)`, чтобы тесты
могли передать подставную реализацию. Создайте store один раз — там, где начинается время жизни
экрана:

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

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…**, введите URL репозитория и добавьте
`SwiftUIStateManagement` в таргет приложения, а `SwiftUIStateManagementTesting` — в тестовый
таргет:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Или добавьте его в `dependencies` вашего `Package.swift`:

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

## Использование

Примеры ниже скопированы из
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift): приложение-пример
собирает этот файл, а набор тестов запускает его.

### Effect'ы и отмена

Поиск, который запускается, только когда пользователь перестал печатать на 300 мс: каждое нажатие
клавиши отменяет ожидающий поиск через `cancelInFlight`, а очистка поля отменяет его
окончательно. Часы — это зависимость, поэтому тесты могут передать `TestClock`.

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

В представлении `store.binding(\.query, send: Search.Action.queryChanged)` подключает текстовое
поле.

### Состояние навигации

Стек — это массив в состоянии, а sheet — опционал. `binding(_:send:)` превращает массив в путь
`NavigationStack`, а `binding(_:dismiss:)` отправляет `newContactDismissed`, когда пользователь
смахивает sheet вниз:

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

`isPresented(_:dismiss:)` делает то же самое для alert'ов и диалогов подтверждения. Руководство
[Состояние навигации](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
рассказывает о пунктах назначения в виде enum, deep link'ах и восстановлении стека при запуске.

### Сохранение

Загрузите сохранённое значение при создании store и поручите `persisting(_:to:in:)` сохранять
каждое изменение:

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

В приложении передавайте `try FileStorage.applicationSupport()`, а в тестах и превью —
`InMemoryStorage`. Сохранённые данные несут свою версию; ключ может мигрировать старые данные, а
сохранённый файл, превышающий лимит ключа (по умолчанию 1 MiB), отклоняется до чтения.

### Тестирование

`TestStore` проверяет каждое изменение состояния и каждое действие, которое effect отправляет
обратно. Этот тест из
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) вводит
две буквы и проверяет, что искался только второй запрос:

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

`Collected` — небольшой массив под защитой блокировки в тестовом таргете. Тест падает, если reducer
изменяет состояние иначе, если приходит другое действие или если к концу теста effect всё ещё
выполняется.

## Демо

Приложение [StateDemo](Examples/StateDemo) запускает каждую тему на настоящей библиотеке — на iOS
и macOS. Скриншоты сделаны из macOS-сборки приложения, которая разыгрывает каждый сценарий теми же
действиями, что отправил бы пользователь; их снимает скрипт
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) (его режим `ios`
снимает те же сценарии в симуляторе iPhone):

| Задачи | Задача, открытая по deep link | Поиск с debounce | Наблюдение по свойствам |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Экран задач: фильтр, пять задач, две из них выполнены"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="Экран сведений о задаче «Review the pull request», открытый по ссылке statedemo://"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Экран поиска: результаты для «Swift» после четырёх нажатий клавиш"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Экран наблюдения: body левой карточки выполнился четыре раза, правой — два"></picture> |

Чтобы запустить его, откройте `StateDemo.xcodeproj` в [Examples/StateDemo](Examples/StateDemo) в
Xcode 26 или новее, выберите симулятор iPhone или **My Mac** и нажмите **Run**.
[Examples/README.md](Examples/README.md) описывает каждый экран.

## Документация

Справочник API и статьи:

- [Справочник SwiftUIStateManagement](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [Справочник SwiftUIStateManagementTesting](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Начало работы](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Как работает Observation](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Выбор подхода](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Руководства

- [Начало работы](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — функциональность, её представление и приложение, которое владеет store.
- [Как работает Observation](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — какие чтения обновляют представление и как сделать обновления небольшими.
- [Effect'ы и отмена](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — ошибки, идентификаторы, debounce, effect'ы, привязанные к представлению, часы.
- [Состояние навигации](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — стеки, sheet'ы, alert'ы, пункты назначения в виде enum, deep link'и и восстановление.
- [Сохранение состояния](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — ключи, хранилища, debounce и flush, миграции и лимиты.
- [Тестирование функциональности](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock` и тесты с настоящим store.
- [Выбор подхода](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — обычные модели `@Observable`, этот пакет или The Composable Architecture.

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Инструменты | Swift 6.2 · Xcode 26+ |

Минимальные версии — это первые выпуски с фреймворком Observation. CI собирает все платформы и
запускает тесты на macOS и в симуляторе iOS.

## Архитектура

Две библиотеки:

| Библиотека | Типы |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, binding'и, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Проектные решения:

- **Состояние-значение и один registrar.** Состояние — это struct. Store держит его за
  `ObservationRegistrar` и регистрирует каждое чтение хранимого свойства `Equatable` под его
  собственным key path (key path состояния store с добавленным путём свойства). После действия он
  сравнивает эти свойства и уведомляет только об изменившихся. Key path'ы, которые не являются
  цепочкой хранимых свойств, откатываются к состоянию целиком, поэтому store никогда не вычисляет
  subscript или вычисляемое свойство на старом состоянии.
- **Везде main actor.** Reducer'ы, store и операции effect'ов выполняются на main actor, что
  соответствует SwiftUI и избавляет `Send` от требований `Sendable` к действиям. Медленная работа
  относится к клиентам, которых ждут ваши effect'ы.
- **Зависимости — это хранимые свойства.** API-клиент или часы reducer'а передаются в его
  инициализатор; никакого глобального контейнера настраивать не нужно.
- **О проблемах сообщается, приложение не падает.** Ошибка effect'а без обработчика или
  неуправляемый цикл `Effect.send` превращается в `StoreIssue` (только имена типов, никогда
  значения) и в падение теста под `TestStore`. Сохранение отклоняет недопустимые имена и размеры
  с ошибками.

### Сравнение

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) —
зрелая библиотека для такого стиля, и она предлагает гораздо больше: макросы, которые убирают
шаблонный код и отслеживают вложенное состояние, систему зависимостей, инструменты навигации для
стеков и древовидного показа, общее состояние, неисчерпывающие тесты и большое сообщество.
Используйте TCA, когда в приложении много функциональностей с общим состоянием или зависимостями
либо когда ваша команда её знает. Используйте этот пакет, когда вам нужна та же
однонаправленная форма с поверхностью, достаточно небольшой, чтобы прочитать её за один вечер, без
зависимостей и без макросов. Обычные модели `@Observable` остаются самым простым выбором для
небольших экранов. Руководство
[Выбор подхода](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
подробно сравнивает все три.

## План развития

- Стековая навигация дочерних функциональностей: родитель, который хранит стек дочерних состояний
  и направляет действия каждого дочернего по id элемента.
- Неисчерпывающий режим `TestStore` для интеграционных тестов, проверяющих лишь часть изменений.
- Поддержка Linux для слоёв reducer'а, effect'ов и сохранения, которым SwiftUI не нужен.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
