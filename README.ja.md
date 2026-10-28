<!-- i18n-source: README.md@b40031a37de449c4b6b347a51e557e63c1f5981a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

SwiftUI State Management は、iOS 17 以降の SwiftUI アプリで単方向の状態管理を行うための、小さな Swift 6 パッケージです。機能は reducer です。`State`、`Action`、そして状態を変更して開始すべき非同期処理を返す 1 つのメソッドを持つ値です。`Store` はこれをメインアクター上で実行して `Observable` を実装するため、ビューは `@Observable` モデルと同じように読み取ることができ、マクロなしでプロパティ単位に読み取りを追跡します。ナビゲーションは状態であり、永続化は reducer の修飾子ひとつで済み、`TestStore` はすべての状態変更と、effect が送信するすべてのアクションを検証します。依存ライブラリはありません。

## 主な特長

- **Observation に基づく単方向フロー** — ビューは `store.count` を読み取り、`store.send(.incrementTapped)` を呼び出します。状態が変わるのは reducer の中だけです。`Equatable` な stored property の読み取りはそれぞれ個別に追跡されるので、`count` を表示するビューは `title` が変わっても更新されません。
- **キャンセルできる effect** — `.run` はメインアクター上でタスクを開始します。id を付けてキャンセルすることも、`cancelInFlight` で最新のものだけを残すこともできます。キャンセルされた effect が古い結果を送ることはなく、store が破棄されるとすべてキャンセルされます。
- **状態としてのナビゲーション** — `NavigationStack` のパス、シート、アラート、enum の遷移先を、アクションを送信する binding で扱うので、ディープリンクやテストにビューは要りません。
- **永続化** — `persisting(\.items, to: .todos, in: storage)` は、変更のたびに状態の一部を保存します。保存はデバウンスされ、必要に応じて即時に書き出し（flush）でき、メインアクターの外で順番どおりに行われます。キーはバージョン付きで、サイズ制限があり、検証されるため、名前が storage のディレクトリの外に出ることはありません。
- **網羅的なテスト** — 状態変更、受信したアクション、残った effect がテストの記述と異なると、`TestStore` は行単位の差分とともに失敗します。`TestClock` を使えば、待たずにデバウンスを終わらせられます。
- **代替案についても正直に** — [アプローチの選び方](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) ガイドでは、素の `@Observable` モデルで十分な場合と、[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) のほうが適している場合を説明しています。

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

**2. モジュールをインポートする**

```swift
import SwiftUIStateManagement
```

**3. 使ってみる**

機能を記述し、表示し、store を作成します（[ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)）。

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

`NumberFacts` は皆さんのサービスを表します。非同期の `fact(Int)` クロージャを持つ struct なので、テストではフェイクを渡せます。ネットワークを使わない版は次のとおりです。

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

store は、画面のライフタイムが始まる場所で 1 回だけ作成します。

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

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力して、`SwiftUIStateManagement` をアプリのターゲットに、`SwiftUIStateManagementTesting` をテストターゲットに追加します。

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

または、`Package.swift` の `dependencies` に追加します。

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

## 使い方

以下のサンプルは [`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift) からコピーしたものです。このファイルはサンプルアプリがビルドし、テストスイートが実行します。

### effect とキャンセル

ユーザーが 300 ms 入力を止めてから実行される検索です。キー入力のたびに `cancelInFlight` によって待機中の検索がキャンセルされ、入力欄を空にすると検索そのものがキャンセルされます。クロックは依存として渡すので、テストでは `TestClock` を渡せます。

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

ビューでは、`store.binding(\.query, send: Search.Action.queryChanged)` でテキストフィールドを接続します。

### ナビゲーションの状態

スタックは状態の中の配列で、シートはオプショナルです。`binding(_:send:)` は配列を `NavigationStack` のパスに変換し、`binding(_:dismiss:)` は、ユーザーがシートを下にスワイプして閉じたときに `newContactDismissed` を送信します。

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

`isPresented(_:dismiss:)` は、アラートや確認ダイアログに対して同じことを行います。[ナビゲーションの状態](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md) ガイドでは、enum の遷移先、ディープリンク、起動時のスタックの復元を取り上げています。

### 永続化

store を作成するときに保存済みの値を読み込み、変更のたびの保存は `persisting(_:to:in:)` に任せます。

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

アプリでは `try FileStorage.applicationSupport()` を、テストとプレビューでは `InMemoryStorage` を渡します。保存されたデータはバージョンを持ち、キーは古いデータを移行でき、キーの上限（既定は 1 MiB）より大きい保存ファイルは、読み込む前に拒否されます。

### テスト

`TestStore` は、すべての状態変更と、effect が送り返すすべてのアクションを検証します。[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) のこのテストは、2 文字を入力して、2 番目のクエリだけが検索されることを確認します。

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

`Collected` は、テストターゲット内にある、ロックで保護された小さな配列です。reducer が別の方法で状態を変更した場合、別のアクションが届いた場合、またはテスト終了時に effect がまだ実行中の場合、テストは失敗します。

## デモ

[StateDemo](Examples/StateDemo) アプリは、各トピックを実際のライブラリで iOS と macOS 上で動かします。スクリーンショットはアプリの macOS ビルドから撮影したもので、各シナリオをユーザーが送るのと同じアクションで再生し、[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) が撮影します（`ios` モードでは、同じシナリオを iPhone シミュレータで撮影します）。

| Todo | ディープリンクで開いた Todo | デバウンス付き検索 | プロパティ単位の監視 |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Todo 画面：フィルタと 5 件の Todo があり、そのうち 2 件が完了している"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="statedemo:// リンクで開いた、Todo「Review the pull request」の詳細画面"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="検索画面：4 回のキー入力のあとの「Swift」の検索結果"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="監視画面：左のカードの body は 4 回、右のカードの body は 2 回実行された"></picture> |

実行するには、Xcode 26 以降で [Examples/StateDemo](Examples/StateDemo) の `StateDemo.xcodeproj` を開き、iPhone シミュレータまたは **My Mac** を選んで、**Run** を押します。各画面の説明は [Examples/README.md](Examples/README.md) にあります。

## ドキュメント

API リファレンスと解説記事：

- [SwiftUIStateManagement リファレンス](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [SwiftUIStateManagementTesting リファレンス](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [はじめに](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Observation のしくみ](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [アプローチの選び方](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## ガイド

- [はじめに](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md) — 機能、そのビュー、store を保持するアプリ。
- [Observation のしくみ](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md) — どの読み取りがビューを更新するか、更新を小さく保つ方法。
- [effect とキャンセル](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md) — エラー、識別子、デバウンス、ビューに結び付いた effect、クロック。
- [ナビゲーションの状態](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md) — スタック、シート、アラート、enum の遷移先、ディープリンク、復元。
- [状態の永続化](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md) — キー、storage、デバウンスと flush、マイグレーションと上限。
- [機能のテスト](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md) — `TestStore`、`TestClock`、実際の store を使ったテスト。
- [アプローチの選び方](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) — 素の `@Observable` モデル、このパッケージ、または The Composable Architecture。

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| ツールチェーン | Swift 6.2 · Xcode 26+ |

最小バージョンは、Observation フレームワークが利用できる最初のリリースです。CI はすべてのプラットフォームをビルドし、macOS と iOS シミュレータでテストを実行します。

## アーキテクチャ

ライブラリは 2 つあります。

| ライブラリ | 型 |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, 各種 binding, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

設計上の判断：

- **値としての状態と、単一の registrar。** 状態は struct です。store はそれを `ObservationRegistrar` の背後に保持し、`Equatable` な stored property の読み取りを、それぞれ固有の key path （store の state key path にプロパティのパスを付け足したもの） で登録します。アクションのあと、それらのプロパティを比較して、変更があったものだけに通知します。stored property の連なりではない key path は状態全体にフォールバックするので、store が古い状態に対して subscript や computed property を評価することはありません。
- **すべてメインアクター。** reducer、store、effect の操作はメインアクターで実行されます。これは SwiftUI に合致しており、`Send` がアクションに `Sendable` を要求しないで済みます。時間のかかる処理は、effect が await するクライアントに置いてください。
- **依存は stored property。** reducer の API クライアントやクロックはイニシャライザに渡します。設定が必要なグローバルなコンテナはありません。
- **問題はトラップせず報告する。** ハンドラのない effect のエラーや、暴走した `Effect.send` のループは `StoreIssue` になり（型名のみで、値は含みません）、`TestStore` ではテストの失敗になります。永続化は、無効な名前やサイズをエラーで拒否します。

### 他の選択肢との比較

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) は、このスタイルでは定評のあるライブラリで、はるかに多くの機能を備えています。ボイラープレートを減らしてネストした状態を追跡するマクロ、依存関係のシステム、スタックやツリーベースの表示のためのナビゲーションツール、共有状態、非網羅的なテスト、そして大きなコミュニティです。状態や依存関係を共有する機能がアプリに多数ある場合や、チームがすでに TCA を知っている場合は、TCA を使ってください。同じ単方向の構造を、午後ひとつで読み切れるほど小さな API、依存ライブラリなし、マクロなしで使いたい場合は、このパッケージを使ってください。小さな画面には、素の `@Observable` モデルがいまでも最も簡単な選択です。[アプローチの選び方](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) ガイドでは、この 3 つを詳しく比較しています。

## ロードマップ

- 子機能のスタックナビゲーション：子の状態のスタックを保持し、各子のアクションを要素の id で振り分ける親。
- 一部の変更だけを検証する統合テスト向けの、非網羅的な `TestStore` モード。
- SwiftUI を必要としない reducer、effect、永続化の各層での Linux サポート。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
