<!-- i18n-source: README.md@b40031a37de449c4b6b347a51e557e63c1f5981a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

SwiftUI State Management 是一个小巧的 Swift 6 包，用于在 iOS 17 及更高版本的 SwiftUI 应用中实现单向状态管理。一个功能就是一个 reducer：它是一个值，包含一个 `State`、一个 `Action`，以及一个方法——该方法修改状态，并返回需要启动的异步任务。`Store` 在主 actor 上运行它并实现 `Observable`，因此视图读取它的方式与读取 `@Observable` 模型一样，并且无需宏就能按属性追踪读取。导航就是状态，持久化只是一个 reducer 修饰符，`TestStore` 会检查每一次状态变化以及 effect 发送的每一个 action。它没有任何依赖。

## 亮点

- **基于 Observation 的单向数据流** —— 视图读取 `store.count` 并调用 `store.send(.incrementTapped)`；状态只会在 reducer 中改变。对 `Equatable` 存储属性的读取会被单独追踪，因此显示 `count` 的视图不会在 `title` 变化时更新。
- **可以取消的 effect** —— `.run` 在主 actor 上启动一个任务；给它加上 id 即可取消，也可以用 `cancelInFlight` 只保留最新的一个。被取消的 effect 不会再发送过期的结果，store 销毁时会取消所有 effect。
- **把导航当作状态** —— `NavigationStack` 路径、sheet、alert 和枚举目标都通过会发送 action 的 binding 实现，因此 deep link 和测试都不需要视图。
- **持久化** —— `persisting(\.items, to: .todos, in: storage)` 会在每次变化后保存部分状态，支持防抖（debounce）和按需刷新（flush），在主 actor 之外按顺序执行。键带有版本、有大小限制并经过校验，因此名称无法跳出 storage 所在的目录。
- **穷尽式测试** —— 当状态变化、收到的 action 或残留的 effect 与测试所写的不一致时，`TestStore` 会以逐行差异的形式报告失败；`TestClock` 无需等待即可结束一次防抖。
- **对替代方案保持坦诚** —— [选择合适的方式](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) 指南说明了什么时候普通的 `@Observable` 模型就够用，什么时候 [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 是更好的选择。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

在 2.0.0 发布之前，请把 **Dependency Rule** 设为 **Branch** 并输入 `main`：默认规则会选择最新发布的 1.0.0，它仍是旧的 API。

**2. 导入模块**

```swift
import SwiftUIStateManagement
```

**3. 开始使用**

描述功能、展示它，然后创建 store（[ReadmeSamples.swift](Examples/StateDemo/StateDemo/ReadmeSamples.swift)）：

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

`NumberFacts` 代表你自己的服务：一个带有异步 `fact(Int)` 闭包的结构体，这样测试就可以传入一个假的实现。一个不需要网络的版本：

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

请只创建一次 store，位置就在界面生命周期开始的地方：

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

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，输入仓库地址，然后把 `SwiftUIStateManagement` 添加到应用 target，把 `SwiftUIStateManagementTesting` 添加到测试 target：

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

在 2.0.0 发布之前，请把 **Dependency Rule** 设为 **Branch** 并输入 `main`：默认规则会选择最新发布的 1.0.0，它仍是旧的 API。

或者把它添加到 `Package.swift` 的 `dependencies` 中：

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

## 使用方法

下面的示例复制自 [`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift)，示例应用会编译它，测试套件会运行它。

### Effect 与取消

只在用户停止输入 300 毫秒之后才执行的搜索：每一次按键都会通过 `cancelInFlight` 取消正在等待的搜索，清空输入框则会直接取消它。时钟是一个依赖，因此测试可以传入 `TestClock`。

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

在视图中，`store.binding(\.query, send: Search.Action.queryChanged)` 用来连接文本框。

### 导航状态

导航栈是状态中的一个数组，sheet 是一个可选值。`binding(_:send:)` 把数组转换成 `NavigationStack` 的路径，当用户向下滑动关闭 sheet 时，`binding(_:dismiss:)` 会发送 `newContactDismissed`：

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

`isPresented(_:dismiss:)` 对 alert 和确认对话框做同样的事。[导航状态](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md) 指南介绍了枚举目标、deep link 以及在启动时恢复导航栈。

### 持久化

创建 store 时加载已保存的值，并让 `persisting(_:to:in:)` 保存每一次变化：

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

在应用中传入 `try FileStorage.applicationSupport()`，在测试和预览中传入 `InMemoryStorage`。保存的数据带有版本；键可以迁移旧数据，而大于该键限制（默认 1 MiB）的已存储文件会在读取之前就被拒绝。

### 测试

`TestStore` 会检查每一次状态变化，以及 effect 回传的每一个 action。[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) 中的这个测试输入两个字母，并检查只有第二次查询被搜索：

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

`Collected` 是测试 target 中一个由锁保护的小数组。如果 reducer 以其他方式修改了状态、收到了其他 action，或者测试结束时仍有 effect 在运行，测试就会失败。

## 演示

[StateDemo](Examples/StateDemo) 应用用真实的库在 iOS 和 macOS 上演示每个主题。截图来自该应用的 macOS 版本，它会用用户会发送的同样的 action 播放每个场景，由 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 截取（它的 `ios` 模式会在 iPhone 模拟器上截取相同的场景）：

| 待办事项 | 通过 deep link 打开的待办 | 防抖搜索 | 按属性观察 |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="待办事项界面：一个筛选器，五条待办，其中两条已完成"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="待办“Review the pull request”的详情界面，由 statedemo:// 链接打开"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="搜索界面：四次按键之后显示“Swift”的结果"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="观察界面：左侧卡片的 body 执行了四次，右侧卡片执行了两次"></picture> |

要运行它，请用 Xcode 26 或更高版本打开 [Examples/StateDemo](Examples/StateDemo) 中的 `StateDemo.xcodeproj`，选择一个 iPhone 模拟器或 **My Mac**，然后点击 **Run**。[Examples/README.md](Examples/README.md) 介绍了每个界面。

## 文档

API 参考文档与文章：

- [SwiftUIStateManagement 参考](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [SwiftUIStateManagementTesting 参考](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [入门](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Observation 的工作原理](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [选择合适的方式](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## 指南

- [入门](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md) —— 一个功能、它的视图，以及持有 store 的应用。
- [Observation 的工作原理](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md) —— 哪些读取会更新视图，以及如何让更新保持精简。
- [Effect 与取消](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md) —— 错误、标识符、防抖、与视图绑定的 effect、时钟。
- [导航状态](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md) —— 导航栈、sheet、alert、枚举目标、deep link 与状态恢复。
- [持久化状态](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md) —— 键、storage、防抖与 flush、迁移和限制。
- [测试功能](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md) —— `TestStore`、`TestClock`，以及使用真实 store 的测试。
- [选择合适的方式](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) —— 普通的 `@Observable` 模型、这个包，还是 The Composable Architecture。

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| 工具链 | Swift 6.2 · Xcode 26+ |

最低版本是第一批包含 Observation 框架的版本。CI 会构建所有平台，并在 macOS 和 iOS 模拟器上运行测试。

## 架构

两个库：

| 库 | 类型 |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, 各种 binding, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

设计决策：

- **值类型状态，单一 registrar。** 状态是一个结构体。store 把它放在 `ObservationRegistrar` 之后，并把对每个 `Equatable` 存储属性的读取注册在它自己的 key path 下（即 store 的状态 key path 再加上该属性的路径）。在一个 action 之后，它会比较这些属性，只通知发生变化的那些。不是由存储属性依次组成的 key path 会退回到整个状态，因此 store 绝不会在旧状态上计算 subscript 或计算属性。
- **全程在主 actor 上。** reducer、store 和 effect 的操作都在主 actor 上运行，这与 SwiftUI 保持一致，也让 `Send` 不必要求 action 满足 `Sendable`。耗时的工作应放在 effect 所等待的 client 中。
- **依赖就是存储属性。** reducer 的 API client 或时钟通过初始化方法传入；没有需要配置的全局容器。
- **问题会被报告，而不是触发陷阱。** 没有处理器的 effect 错误，或失控的 `Effect.send` 循环，会变成一个 `StoreIssue`（只包含类型名称，绝不包含值），并在 `TestStore` 下导致测试失败。持久化会用错误拒绝无效的名称和大小。

### 与其他方案的比较

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 是这种风格的成熟库，并且提供了多得多的功能：消除样板代码并追踪嵌套状态的宏、依赖系统、针对导航栈和基于树的展示的导航工具、共享状态、非穷尽式测试，以及庞大的社区。如果你的应用有许多共享状态或依赖的功能，或者你的团队熟悉它，就使用 TCA。如果你想要同样的单向结构，但希望接口小到一个下午就能读完，并且没有依赖、没有宏，就使用这个包。对于小型界面，普通的 `@Observable` 模型仍然是最简单的选择。[选择合适的方式](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md) 指南详细比较了这三种方式。

## 路线图

- 子功能的导航栈：父级持有一组子状态，并按元素 id 路由每个子功能的 action。
- 非穷尽式的 `TestStore` 模式，用于只检查部分变化的集成测试。
- 对 reducer、effect 和持久化层的 Linux 支持，这些层不需要 SwiftUI。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
