<!-- i18n-source: README.md@b40031a37de449c4b6b347a51e557e63c1f5981a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

SwiftUI State Management, iOS 17 ve üzeri SwiftUI uygulamalarında tek yönlü state yönetimi için
küçük bir Swift 6 paketidir. Bir özellik (feature) bir reducer'dır: bir `State`, bir `Action`
ve state'i değiştirip başlatılacak asenkron işi döndüren tek bir metottan oluşan bir değerdir.
`Store` bunu ana aktörde (main actor) çalıştırır ve `Observable` protokolünü uygular; böylece
view'lar onu bir `@Observable` model gibi okur ve okumaları makro kullanmadan özellik bazında
izler. Navigasyon state'tir, kalıcılık tek bir reducer değiştiricisidir ve `TestStore` her state
değişikliğini ve bir effect'in gönderdiği her action'ı denetler. Hiçbir bağımlılığı yoktur.

## Öne çıkanlar

- **Observation üzerinde tek yönlü akış** — view'lar `store.count` değerini okur ve
  `store.send(.incrementTapped)` çağırır; state'in değiştiği tek yer reducer'dır. `Equatable`
  bir stored property'nin okunması tek başına izlenir; bu yüzden `count` gösteren bir view,
  `title` değiştiğinde güncellenmez.
- **İptal edebileceğiniz effect'ler** — `.run`, ana aktörde bir görev (task) başlatır; bir id
  ile etiketleyerek iptal edebilir ya da `cancelInFlight` ile yalnızca en yenisini tutabilirsiniz.
  İptal edilmiş bir effect eski sonuçları gönderemez ve store ortadan kalktığında her şeyi iptal
  eder.
- **State olarak navigasyon** — `NavigationStack` yolları, sheet'ler, alert'ler ve enum
  hedefleri, action gönderen binding'ler üzerinden çalışır; böylece deep link'ler ve testler
  için view gerekmez.
- **Kalıcılık** — `persisting(\.items, to: .todos, in: storage)` state'in bir bölümünü her
  değişiklikten sonra kaydeder; kayıt debounce edilir, istek üzerine hemen yazılır (flush),
  ana aktörün dışında ve sırayla yapılır. Anahtarlar sürümlüdür, boyut sınırı vardır ve
  doğrulanır; bu yüzden bir ad, storage'ın dizininin dışına çıkamaz.
- **Kapsamlı testler** — bir state değişikliği, alınan bir action ya da kalan bir effect testte
  yazılandan farklıysa `TestStore`, satır satır bir farkla başarısız olur; `TestClock` bir
  debounce'u beklemeden bitirir.
- **Alternatifler konusunda dürüst** — [Yaklaşım seçimi](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  rehberi, düz `@Observable` modellerin ne zaman yettiğini ve
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
  kütüphanesinin ne zaman daha iyi bir seçim olduğunu anlatır.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

2.0.0 yayımlanana kadar **Dependency Rule** seçeneğini **Branch** yapın ve `main` girin: varsayılan
kural, hâlâ eski API'yi içeren son sürümü (1.0.0) seçer.

**2. Modülü içe aktarın**

```swift
import SwiftUIStateManagement
```

**3. Kullanın**

Özelliği tanımlayın, gösterin ve store'u oluşturun
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

`NumberFacts`, sizin servisinizi temsil eder: asenkron bir `fact(Int)` closure'ı olan bir struct;
böylece testler sahte bir uygulama geçirebilir. Ağ gerektirmeyen bir sürüm:

```swift
struct NumberFacts: Sendable {
    var fact: @Sendable (Int) async throws -> String
    static let local = NumberFacts { "\($0) is a number." }
}
```

Store'u ekranın ömrünün başladığı yerde, bir kez oluşturun:

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

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin, depo adresini girin ve
`SwiftUIStateManagement` ürününü uygulama hedefinize, `SwiftUIStateManagementTesting` ürününü
test hedefinize ekleyin:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

2.0.0 yayımlanana kadar **Dependency Rule** seçeneğini **Branch** yapın ve `main` girin: varsayılan
kural, hâlâ eski API'yi içeren son sürümü (1.0.0) seçer.

Ya da `Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

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

## Kullanım

Aşağıdaki örnekler, örnek uygulamanın derlediği ve test paketinin çalıştırdığı
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift) dosyasından
kopyalanmıştır.

### Effect'ler ve iptal

Kullanıcı 300 ms boyunca yazmayı bıraktıktan sonra çalışan bir arama: her tuş vuruşu, bekleyen
aramayı `cancelInFlight` ile iptal eder; alanı temizlemek de aramayı doğrudan iptal eder.
Saat bir bağımlılıktır, bu yüzden testler bir `TestClock` geçirebilir.

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

View'da `store.binding(\.query, send: Search.Action.queryChanged)` bir metin alanını bağlar.

### Navigasyon state'i

Yığın, state içindeki bir dizidir; sheet ise bir optional'dır. `binding(_:send:)` diziyi
`NavigationStack` yoluna çevirir; `binding(_:dismiss:)` ise kullanıcı sheet'i aşağı kaydırdığında
`newContactDismissed` action'ını gönderir:

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

`isPresented(_:dismiss:)` aynı işi alert'ler ve onay iletişim kutuları için yapar.
[Navigasyon state'i](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
rehberi enum hedeflerini, deep link'leri ve yığını uygulama açılışında geri yüklemeyi anlatır.

### Kalıcılık

Kaydedilmiş değeri store'u oluştururken yükleyin ve her değişikliği `persisting(_:to:in:)`
kaydetsin:

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

Uygulamada `try FileStorage.applicationSupport()`, testlerde ve önizlemelerde ise bir
`InMemoryStorage` geçirin. Kaydedilen veri sürümünü taşır; bir anahtar eski veriyi taşıyabilir
(migration) ve anahtarın sınırından (varsayılan 1 MiB) büyük bir dosya okunmadan önce reddedilir.

### Test

`TestStore`, her state değişikliğini ve bir effect'in geri gönderdiği her action'ı denetler.
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift)
dosyasındaki bu test iki harf yazar ve yalnızca ikinci sorgunun arandığını doğrular:

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

`Collected`, test hedefindeki küçük, kilitle korunan bir dizidir. Reducer state'i başka bir
şekilde değiştirirse, başka bir action gelirse ya da test biterken bir effect hâlâ çalışıyorsa
test başarısız olur.

## Demo

[StateDemo](Examples/StateDemo) uygulaması her konuyu gerçek kütüphaneyle, iOS'ta ve macOS'ta
çalıştırır. Ekran görüntüleri uygulamanın macOS sürümünden alınmıştır; bu sürüm her senaryoyu,
bir kullanıcının göndereceği action'larla oynatır ve görüntüleri
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) betiği çeker (betiğin
`ios` modu aynı senaryoları bir iPhone simülatöründe yakalar):

| Yapılacaklar | Deep link ile açılan yapılacak | Debounce'lu arama | Özellik bazında gözlem |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Yapılacaklar ekranı: bir filtre, beş yapılacak iş, ikisi tamamlanmış"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="'Review the pull request' yapılacak işinin ayrıntı ekranı, statedemo:// bağlantısıyla açılmış"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Arama ekranı: dört tuş vuruşundan sonra 'Swift' için sonuçlar"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Gözlem ekranı: soldaki kartın body'si dört kez, sağdaki kartınki iki kez çalıştı"></picture> |

Çalıştırmak için [Examples/StateDemo](Examples/StateDemo) klasöründeki `StateDemo.xcodeproj`
dosyasını Xcode 26 veya üzeriyle açın, bir iPhone simülatörü ya da **My Mac** seçin ve
**Run**'a basın. [Examples/README.md](Examples/README.md) her ekranı anlatır.

## Dokümantasyon

API başvuru belgeleri ve makaleler:

- [SwiftUIStateManagement başvurusu](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [SwiftUIStateManagementTesting başvurusu](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Başlarken](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Observation nasıl çalışır](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Yaklaşım seçimi](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Rehberler

- [Başlarken](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — bir özellik, view'ı ve store'a sahip olan uygulama.
- [Observation nasıl çalışır](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — hangi okumalar bir view'ı günceller ve güncellemeler nasıl küçük tutulur.
- [Effect'ler ve iptal](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — hatalar, tanımlayıcılar, debounce, bir view'a bağlı effect'ler, saatler.
- [Navigasyon state'i](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — yığınlar, sheet'ler, alert'ler, enum hedefleri, deep link'ler ve geri yükleme.
- [State'i kalıcı kılma](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — anahtarlar, storage'lar, debounce ve flush, migration'lar ve sınırlar.
- [Özellikleri test etme](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock` ve gerçek store ile testler.
- [Yaklaşım seçimi](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — düz `@Observable` modeller, bu paket ya da The Composable Architecture.

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

En düşük sürümler, Observation framework'ünü içeren ilk sürümlerdir. CI her platformu derler ve
testleri macOS'ta ve bir iOS simülatöründe çalıştırır.

## Mimari

İki kütüphane:

| Kütüphane | Türler |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, binding'ler, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Tasarım kararları:

- **Değer olarak state, tek registrar.** State bir struct'tır. Store onu bir
  `ObservationRegistrar` arkasında tutar ve bir `Equatable` stored property'nin her okumasını
  kendi key path'i altında kaydeder (store'un state key path'i ile property'nin yolunun
  birleşimi). Bir action'dan sonra bu property'leri karşılaştırır ve yalnızca değişenleri
  bildirir. Stored property zinciri olmayan key path'ler tüm state'e geri düşer; bu sayede store,
  eski bir state üzerinde hiçbir zaman subscript ya da computed property değerlendirmez.
- **Baştan sona ana aktör.** Reducer'lar, store ve effect işlemleri ana aktörde çalışır; bu,
  SwiftUI ile uyumludur ve `Send`'i action'lar üzerindeki `Sendable` gereksinimlerinden
  kurtarır. Yavaş işler, effect'lerinizin beklediği client'lara aittir.
- **Bağımlılıklar stored property'dir.** Bir reducer'ın API client'ı ya da saati initializer'ına
  geçirilir; yapılandırılacak global bir container yoktur.
- **Sorunlar raporlanır, uygulamayı çökertmez.** İşleyicisi olmayan bir effect hatası ya da
  kontrolden çıkmış bir `Effect.send` döngüsü bir `StoreIssue` olur (yalnızca tür adları,
  asla değerler) ve `TestStore` altında test hatasına dönüşür. Kalıcılık, geçersiz adları ve
  boyutları hatalarla reddeder.

### Karşılaştırma

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture),
bu tarz için yerleşik kütüphanedir ve çok daha fazlasını sunar: şablon kodu azaltan ve iç içe
state'i izleyen makrolar, bir bağımlılık sistemi, yığınlar ve ağaç tabanlı sunum için navigasyon
araçları, paylaşılan state, kapsamlı olmayan (non-exhaustive) testler ve büyük bir topluluk.
Uygulamanızda state'i ya da bağımlılıkları paylaşan çok sayıda özellik varsa veya ekibiniz onu
biliyorsa TCA'yı kullanın. Aynı tek yönlü yapıyı, bir öğleden sonrada okunabilecek kadar küçük
bir yüzeyle, bağımlılıksız ve makrosuz istiyorsanız bu paketi kullanın. Küçük ekranlar için en
basit seçim yine düz `@Observable` modellerdir.
[Yaklaşım seçimi](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
rehberi üçünü ayrıntılı olarak karşılaştırır.

## Yol haritası

- Alt özelliklerin yığın navigasyonu: alt state'lerden oluşan bir yığın tutan ve her alt
  özelliğin action'larını eleman id'sine göre yönlendiren bir üst özellik.
- Yalnızca bazı değişiklikleri denetleyen entegrasyon testleri için `TestStore`'un
  non-exhaustive modu.
- SwiftUI gerektirmeyen reducer, effect ve kalıcılık katmanları için Linux desteği.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
