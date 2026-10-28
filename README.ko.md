<!-- i18n-source: README.md@44859f3e26f0b3a0db482d9cedc1ea1d1fdfcb56 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="최신 버전: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

SwiftUI State Management는 iOS 17 이상의 SwiftUI 앱에서 단방향 상태 관리를 위한 작은 Swift 6
패키지입니다. 기능은 reducer입니다. `State`, `Action`, 그리고 상태를 바꾸고 시작할 비동기 작업을
반환하는 메서드 하나로 이루어진 값입니다. `Store`는 이를 메인 액터에서 실행하고 `Observable`을
구현하므로, 뷰는 `@Observable` 모델처럼 읽을 수 있고 매크로 없이도 프로퍼티 단위로 읽기를 추적합니다.
내비게이션은 상태이고, 영속화는 reducer 수정자 하나이며, `TestStore`는 모든 상태 변경과 effect가
보내는 모든 액션을 검사합니다. 의존성은 없습니다.

## 주요 기능

- **Observation 기반의 단방향 흐름** — 뷰는 `store.count`를 읽고 `store.send(.incrementTapped)`를
  호출합니다. 상태가 바뀌는 곳은 reducer뿐입니다. `Equatable` 저장 프로퍼티를 읽으면 그 프로퍼티만
  따로 추적되므로, `count`를 보여 주는 뷰는 `title`이 바뀌어도 업데이트되지 않습니다.
- **취소할 수 있는 effect** — `.run`은 메인 액터에서 작업을 시작합니다. id를 붙여 취소하거나,
  `cancelInFlight`로 가장 최근 것만 남길 수 있습니다. 취소된 effect는 오래된 결과를 보낼 수 없고,
  store가 사라지면 모든 effect를 취소합니다.
- **상태로서의 내비게이션** — `NavigationStack` 경로, 시트, 알림, enum 목적지를 액션을 보내는
  바인딩으로 다루므로, 딥 링크와 테스트에 뷰가 필요하지 않습니다.
- **영속화** — `persisting(\.items, to: .todos, in: storage)`는 변경될 때마다 상태의 일부를
  저장합니다. 저장은 디바운스되고 필요할 때 즉시 기록(flush)할 수 있으며, 메인 액터 밖에서 순서대로
  이루어집니다. 키는 버전이 있고 크기 제한이 있으며 검증되므로, 이름이 storage의 디렉터리를 벗어날
  수 없습니다.
- **빈틈없는 테스트** — 상태 변경, 수신한 액션, 남아 있는 effect가 테스트에 적힌 것과 다르면
  `TestStore`는 줄 단위 차이를 보여 주며 실패합니다. `TestClock`은 기다리지 않고 디바운스를
  끝냅니다.
- **대안에 대해 솔직하게** — [접근 방식 선택](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  가이드는 일반 `@Observable` 모델로 충분한 경우와
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)가
  더 나은 선택인 경우를 설명합니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

**2. 모듈 가져오기**

```swift
import SwiftUIStateManagement
```

**3. 사용하기**

기능을 기술하고, 보여 주고, store를 만듭니다
([ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)).

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

`NumberFacts`는 여러분의 서비스를 나타냅니다. 비동기 `fact(Int)` 클로저를 가진 struct이므로, 테스트에서 가짜 구현을 넘길 수 있습니다. 네트워크가 필요
없는 버전은 다음과 같습니다.

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

store는 화면의 수명이 시작되는 곳에서 한 번만 만드세요.

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

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력한 다음,
`SwiftUIStateManagement`를 앱 타깃에, `SwiftUIStateManagementTesting`을 테스트 타깃에 추가하세요.

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

또는 `Package.swift`의 `dependencies`에 추가하세요.

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftUI-State-Management.git", from: "2.0.0")
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

## 사용법

아래 예제는 [`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift)에서
가져온 것입니다. 이 파일은 예제 앱이 빌드하고 테스트 스위트가 실행합니다.

### effect와 취소

사용자가 300 ms 동안 입력을 멈춘 뒤에야 실행되는 검색입니다. 키를 누를 때마다 `cancelInFlight`가
대기 중인 검색을 취소하고, 입력란을 비우면 검색이 즉시 취소됩니다. 시계는 의존성이므로 테스트에서는
`TestClock`을 넘길 수 있습니다.

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

뷰에서는 `store.binding(\.query, send: Search.Action.queryChanged)`로 텍스트 필드를 연결합니다.

### 내비게이션 상태

스택은 상태 안의 배열이고 시트는 옵셔널입니다. `binding(_:send:)`는 배열을 `NavigationStack`
경로로 바꾸고, `binding(_:dismiss:)`는 사용자가 시트를 아래로 쓸어 내리면 `newContactDismissed`를
보냅니다.

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

`isPresented(_:dismiss:)`는 알림과 확인 대화 상자에 대해 같은 일을 합니다.
[내비게이션 상태](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
가이드는 enum 목적지, 딥 링크, 실행 시 스택 복원을 다룹니다.

### 영속화

store를 만들 때 저장된 값을 불러오고, 변경 사항의 저장은 `persisting(_:to:in:)`에 맡기세요.

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

앱에서는 `try FileStorage.applicationSupport()`를, 테스트와 프리뷰에서는 `InMemoryStorage`를
넘기세요. 저장된 데이터에는 버전이 들어 있고, 키는 이전 데이터를 마이그레이션할 수 있으며, 키의
한도(기본값 1 MiB)보다 큰 저장 파일은 읽기 전에 거부됩니다.

### 테스트

`TestStore`는 모든 상태 변경과 effect가 다시 보내는 모든 액션을 검사합니다.
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift)의
이 테스트는 두 글자를 입력하고 두 번째 쿼리만 검색되는지 확인합니다.

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

`Collected`는 테스트 타깃에 있는, 잠금으로 보호되는 작은 배열입니다. reducer가 다른 방식으로
상태를 바꾸거나, 다른 액션이 도착하거나, 테스트가 끝날 때 effect가 아직 실행 중이면 테스트는
실패합니다.

## 데모

[StateDemo](Examples/StateDemo) 앱은 각 주제를 실제 라이브러리로 iOS와 macOS에서 실행합니다.
스크린샷은 앱의 macOS 빌드에서 가져온 것으로, 사용자가 보낼 액션과 똑같은 액션으로 각 시나리오를
재생하며
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)가 캡처합니다
(`ios` 모드는 같은 시나리오를 iPhone 시뮬레이터에서 캡처합니다).

| 할 일 | 딥 링크로 연 할 일 | 디바운스 검색 | 프로퍼티별 관찰 |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="할 일 화면: 필터 하나와 할 일 다섯 개, 그중 두 개는 완료됨"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="statedemo:// 링크로 연 'Review the pull request' 할 일의 상세 화면"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="검색 화면: 키를 네 번 누른 뒤 'Swift'의 검색 결과"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="관찰 화면: 왼쪽 카드의 body는 네 번, 오른쪽 카드의 body는 두 번 실행됨"></picture> |

실행하려면 Xcode 26 이상으로 [Examples/StateDemo](Examples/StateDemo)의 `StateDemo.xcodeproj`를
열고, iPhone 시뮬레이터 또는 **My Mac**을 선택한 다음 **Run**을 누르세요.
각 화면은 [Examples/README.md](Examples/README.md)에 설명되어 있습니다.

## 문서

API 레퍼런스와 문서:

- [SwiftUIStateManagement 레퍼런스](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [SwiftUIStateManagementTesting 레퍼런스](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [시작하기](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Observation의 동작 방식](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [접근 방식 선택](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## 가이드

- [시작하기](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — 기능 하나, 그 뷰, 그리고 store를 소유하는 앱.
- [Observation의 동작 방식](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — 어떤 읽기가 뷰를 업데이트하는지, 업데이트를 작게 유지하는 방법.
- [effect와 취소](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — 오류, 식별자, 디바운스, 뷰에 묶인 effect, 시계.
- [내비게이션 상태](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — 스택, 시트, 알림, enum 목적지, 딥 링크, 복원.
- [상태 영속화](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — 키, storage, 디바운스와 flush, 마이그레이션과 한도.
- [기능 테스트](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock`, 그리고 실제 store를 사용하는 테스트.
- [접근 방식 선택](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — 일반 `@Observable` 모델, 이 패키지, 또는 The Composable Architecture.

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| 툴체인 | Swift 6.2 · Xcode 26+ |

최소 버전은 Observation 프레임워크가 포함된 첫 릴리스입니다. CI는 모든 플랫폼을 빌드하고 macOS와
iOS 시뮬레이터에서 테스트를 실행합니다.

## 아키텍처

라이브러리는 두 개입니다.

| 라이브러리 | 타입 |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, 바인딩들, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

설계 결정:

- **값 타입 상태, 하나의 registrar.** 상태는 struct입니다. store는 이를 `ObservationRegistrar`
  뒤에 두고, `Equatable` 저장 프로퍼티를 읽을 때마다 그 프로퍼티 고유의 key path(store의 state key
  path에 프로퍼티의 경로를 덧붙인 것)로 등록합니다. 액션이 처리된 뒤에는 그 프로퍼티들을 비교해서
  바뀐 것만 알립니다. 저장 프로퍼티의 연쇄가 아닌 key path는 상태 전체로 대체되므로, store는 이전
  상태에서 subscript나 계산 프로퍼티를 평가하는 일이 없습니다.
- **처음부터 끝까지 메인 액터.** reducer, store, effect 연산은 메인 액터에서 실행됩니다. 이는
  SwiftUI와 맞고, `Send`가 액션에 `Sendable` 요구 사항을 두지 않게 해 줍니다. 느린 작업은 effect가
  기다리는 클라이언트에 두세요.
- **의존성은 저장 프로퍼티.** reducer의 API 클라이언트나 시계는 이니셜라이저로 넘기며, 설정해야 할
  전역 컨테이너는 없습니다.
- **문제는 트랩하지 않고 보고합니다.** 핸들러가 없는 effect 오류나 폭주하는 `Effect.send` 루프는
  `StoreIssue`가 되고(타입 이름만 포함하며 값은 절대 포함하지 않습니다), `TestStore`에서는 테스트
  실패가 됩니다. 영속화는 잘못된 이름과 크기를 오류로 거부합니다.

### 비교

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)는
이 스타일을 위한 확립된 라이브러리이며 훨씬 더 많은 것을 제공합니다. 보일러플레이트를 없애고 중첩된
상태를 추적하는 매크로, 의존성 시스템, 스택과 트리 기반 표시를 위한 내비게이션 도구, 공유 상태,
non-exhaustive 테스트, 그리고 큰 커뮤니티입니다. 앱에 상태나 의존성을 공유하는 기능이
많거나 팀이 이미 TCA를 알고 있다면 TCA를 사용하세요. 같은 단방향 구조를 하루 오후면 읽을 수 있는
작은 표면, 의존성 없음, 매크로 없음으로 원한다면 이 패키지를 사용하세요. 작은 화면에는 일반
`@Observable` 모델이 여전히 가장 간단한 선택입니다.
[접근 방식 선택](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
가이드가 세 가지를 자세히 비교합니다.

## 로드맵

- 자식 기능의 스택 내비게이션: 자식 상태의 스택을 보유하고 각 자식의 액션을 요소 id로 전달하는 부모.
- 일부 변경만 검사하는 통합 테스트를 위한 non-exhaustive `TestStore` 모드.
- SwiftUI가 필요 없는 reducer, effect, 영속화 계층의 Linux 지원.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
