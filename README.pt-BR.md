<!-- i18n-source: README.md@cb1a4ebaa23d3b3d094095fce21161ccf8f401f7 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/banner-light.svg" alt="SwiftUI State Management: Unidirectional state for SwiftUI on Observation, with testable stores, navigation and persistence."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftUI-State-Management/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 17+ · macOS 14+ · tvOS 17+ · watchOS 10+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftUI-State-Management/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-State-Management/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

O SwiftUI State Management é um pacote pequeno em Swift 6 para estado unidirecional em apps SwiftUI
a partir do iOS 17. Uma funcionalidade é um reducer: um valor com um `State`, uma `Action` e um
método que altera o estado e devolve o trabalho assíncrono a iniciar. Um `Store` o executa no main
actor e implementa `Observable`, de modo que as views o leem como um modelo `@Observable` e ele
rastreia as leituras por propriedade, sem macros. A navegação é estado, a persistência é um único
modificador de reducer, e o `TestStore` verifica cada mudança de estado e cada action que um
effect envia. Não tem dependências.

## Destaques

- **Fluxo unidirecional sobre o Observation** — as views leem `store.count` e chamam
  `store.send(.incrementTapped)`; o reducer é o único lugar em que o estado muda. A leitura de uma
  propriedade armazenada `Equatable` é rastreada isoladamente, então uma view que mostra `count`
  não é atualizada quando `title` muda.
- **Effects que você pode cancelar** — `.run` inicia uma task no main actor; identifique-a com um
  id para cancelá-la, ou deixe o `cancelInFlight` manter apenas a mais recente. Um effect
  cancelado não consegue enviar resultados desatualizados, e o store cancela tudo quando deixa de
  existir.
- **Navegação como estado** — caminhos de `NavigationStack`, sheets, alertas e destinos em enum,
  por meio de bindings que enviam actions, de modo que deep links e testes não precisam de view.
- **Persistência** — `persisting(\.items, to: .todos, in: storage)` salva uma parte do estado após
  cada mudança, com debounce, gravação imediata sob demanda (flush), fora do main actor e em
  ordem. As chaves têm versão, tamanho limitado e são validadas, então um nome não consegue sair
  do diretório do storage.
- **Testes exaustivos** — o `TestStore` falha com uma diferença linha a linha quando uma mudança
  de estado, uma action recebida ou um effect remanescente difere do que o teste diz; o
  `TestClock` encerra um debounce sem esperar.
- **Honesto sobre as alternativas** — o guia [Escolhendo uma abordagem](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  diz quando modelos `@Observable` simples bastam e quando
  [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
  é a melhor escolha.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…** e informe a URL do repositório:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

**2. Importe o módulo**

```swift
import SwiftUIStateManagement
```

**3. Use**

Descreva a funcionalidade, mostre-a e crie o store
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

`NumberFacts` representa o seu serviço: uma struct com uma closure assíncrona `fact(Int)`, para
que os testes possam passar uma versão falsa. Crie o store uma única vez, onde começa o ciclo de
vida da tela:

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

## Instalação

### Swift Package Manager

No Xcode, escolha **File › Add Package Dependencies…**, informe a URL do repositório e adicione
`SwiftUIStateManagement` ao target do seu app e `SwiftUIStateManagementTesting` ao target de
testes:

```text
https://github.com/muhittincamdali/SwiftUI-State-Management.git
```

Ou adicione-o às `dependencies` do seu `Package.swift`:

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

## Uso

Os exemplos abaixo foram copiados de
[`ReadmeSamples.swift`](Examples/StateDemo/StateDemo/ReadmeSamples.swift), que o app de exemplo
compila e que a suíte de testes executa.

### Effects e cancelamento

Uma busca que só roda depois que o usuário para de digitar por 300 ms: cada tecla cancela a busca
em espera por meio de `cancelInFlight`, e limpar o campo a cancela de vez. O relógio é uma
dependência, então os testes podem passar um `TestClock`.

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

Na view, `store.binding(\.query, send: Search.Action.queryChanged)` conecta um campo de texto.

### Estado de navegação

A pilha é um array no estado e a sheet é um opcional. `binding(_:send:)` transforma o array no
caminho do `NavigationStack`, e `binding(_:dismiss:)` envia `newContactDismissed` quando o usuário
arrasta a sheet para baixo:

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

`isPresented(_:dismiss:)` faz o mesmo para alertas e diálogos de confirmação. O guia
[Estado de navegação](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
trata de destinos em enum, deep links e da restauração da pilha na inicialização.

### Persistência

Carregue o valor salvo ao criar o store e deixe o `persisting(_:to:in:)` salvar cada mudança:

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

Passe `try FileStorage.applicationSupport()` no app e um `InMemoryStorage` nos testes e nas
previews. Os dados salvos carregam a sua versão; uma chave pode migrar dados antigos, e um arquivo
salvo maior que o limite da chave (1 MiB por padrão) é recusado antes de ser lido.

### Testes

O `TestStore` verifica cada mudança de estado e cada action que um effect envia de volta. Este
teste de
[`ReadmeSamplesTests.swift`](Tests/SwiftUIStateManagementTests/ReadmeSamplesTests.swift) digita
duas letras e verifica que só a segunda consulta é pesquisada:

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

`Collected` é um pequeno array protegido por lock, no target de testes. O teste falha se o reducer
alterar o estado de outra forma, se chegar outra action ou se um effect ainda estiver em execução
quando o teste terminar.

## Demonstração

O app [StateDemo](Examples/StateDemo) executa cada tópico com a biblioteca real, no iOS e no macOS.
As capturas de tela vêm da versão do app para macOS, que reproduz cada cenário com as mesmas
actions que um usuário enviaria, e são feitas por
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) (o modo `ios` captura os
mesmos cenários em um simulador de iPhone):

| Tarefas | Tarefa aberta por deep link | Busca com debounce | Observação por propriedade |
| --- | --- | --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todos-dark.png"><img src="docs/images/demo-todos-light.png" width="200" alt="Tela de tarefas: um filtro, cinco tarefas, duas delas concluídas"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-todo-detail-dark.png"><img src="docs/images/demo-todo-detail-light.png" width="200" alt="Tela de detalhes da tarefa 'Review the pull request', aberta por um link statedemo://"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-search-dark.png"><img src="docs/images/demo-search-light.png" width="200" alt="Tela de busca: resultados para 'Swift' depois de quatro teclas"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-observation-dark.png"><img src="docs/images/demo-observation-light.png" width="200" alt="Tela de observação: o body do cartão da esquerda foi executado quatro vezes e o da direita, duas"></picture> |

Para executá-lo, abra `StateDemo.xcodeproj` em [Examples/StateDemo](Examples/StateDemo) com o Xcode
26 ou posterior, escolha um simulador de iPhone ou **My Mac** e clique em **Run**.
[Examples/README.md](Examples/README.md) descreve cada tela.

## Documentação

Referência da API e artigos:

- [Referência de SwiftUIStateManagement](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/)
- [Referência de SwiftUIStateManagementTesting](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagementtesting/)
- [Primeiros passos](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/gettingstarted)
- [Como o Observation funciona](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/howobservationworks)
- [Escolhendo uma abordagem](https://muhittincamdali.github.io/SwiftUI-State-Management/documentation/swiftuistatemanagement/choosinganapproach)

## Guias

- [Primeiros passos](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/GettingStarted.md)
  — uma funcionalidade, sua view e o app que é dono do store.
- [Como o Observation funciona](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/HowObservationWorks.md)
  — quais leituras atualizam uma view e como manter as atualizações pequenas.
- [Effects e cancelamento](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/EffectsAndCancellation.md)
  — erros, identificadores, debounce, effects atrelados a uma view, relógios.
- [Estado de navegação](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/NavigationState.md)
  — pilhas, sheets, alertas, destinos em enum, deep links e restauração.
- [Persistindo o estado](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/PersistingState.md)
  — chaves, storages, debounce e flush, migrações e limites.
- [Testando funcionalidades](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/TestingFeatures.md)
  — `TestStore`, `TestClock` e testes com o store real.
- [Escolhendo uma abordagem](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
  — modelos `@Observable` simples, este pacote ou The Composable Architecture.

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| iOS | 17 |
| macOS | 14 |
| tvOS | 17 |
| watchOS | 10 |
| visionOS | 1 |
| Ferramentas | Swift 6.2 · Xcode 26+ |

As versões mínimas são os primeiros lançamentos com o framework Observation. O CI compila todas as
plataformas e executa os testes no macOS e em um simulador de iOS.

## Arquitetura

Duas bibliotecas:

| Biblioteca | Tipos |
| --- | --- |
| `SwiftUIStateManagement` | `Reducer`, `Reduce`, `Scope`, `CombinedReducer`, `Store`, `StoreTask`, `StoreIssue`, `Effect`, `Send`, os bindings, `StateStorage`, `FileStorage`, `UserDefaultsStorage`, `InMemoryStorage`, `PersistenceKey`, `PersistingReducer` |
| `SwiftUIStateManagementTesting` | `TestStore`, `TestClock` |

Decisões de design:

- **Estado por valor, um único registrar.** O estado é uma struct. O store o mantém atrás de um
  `ObservationRegistrar` e registra cada leitura de uma propriedade armazenada `Equatable` sob o
  seu próprio key path (o key path do estado do store com o caminho da propriedade anexado). Depois
  de uma action, ele compara essas propriedades e notifica apenas as que mudaram. Key paths que não
  são uma cadeia de propriedades armazenadas recorrem ao estado inteiro, de modo que o store nunca
  avalia um subscript ou uma propriedade computada em um estado antigo.
- **Main actor em todo o fluxo.** Reducers, o store e as operações dos effects rodam no main actor,
  o que combina com o SwiftUI e livra o `Send` de exigir `Sendable` das actions. O trabalho lento
  pertence aos clients que os seus effects aguardam.
- **Dependências são propriedades armazenadas.** O client de API ou o relógio de um reducer é
  passado ao seu inicializador; não há nenhum container global para configurar.
- **Problemas são reportados, não derrubam o app.** Um erro de effect sem handler ou um loop
  descontrolado de `Effect.send` vira um `StoreIssue` (apenas nomes de tipos, nunca valores) e uma
  falha de teste sob o `TestStore`. A persistência rejeita nomes e tamanhos inválidos com erros.

### Como se compara

[The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
é a biblioteca consolidada para esse estilo e oferece muito mais: macros que eliminam código
repetitivo e rastreiam estado aninhado, um sistema de dependências, ferramentas de navegação para
pilhas e apresentação baseada em árvore, estado compartilhado, testes não exaustivos e uma grande
comunidade. Use o TCA quando o seu app tiver muitas funcionalidades que compartilham estado ou
dependências, ou quando a sua equipe já o conhecer. Use este pacote quando quiser o mesmo formato
unidirecional com uma superfície pequena o bastante para ler em uma tarde, sem dependências e sem
macros. Modelos `@Observable` simples continuam sendo a escolha mais simples para telas pequenas. O
guia [Escolhendo uma abordagem](Sources/SwiftUIStateManagement/SwiftUIStateManagement.docc/ChoosingAnApproach.md)
compara os três em detalhes.

## Roteiro

- Navegação em pilha de funcionalidades filhas: um pai que mantém uma pilha de estados filhos e
  encaminha as actions de cada filho pelo id do elemento.
- Modo não exaustivo do `TestStore`, para testes de integração que verificam apenas algumas
  mudanças.
- Suporte a Linux para as camadas de reducer, effect e persistência, que não precisam de SwiftUI.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/SwiftUI-State-Management/blob/main/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
