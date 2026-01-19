# 📚 Guia de Comentários do Código - Snap Sieve

Este documento explica todos os conceitos e padrões usados no projeto Snap Sieve. Perfeito para aprendizado e criação de conteúdo educativo!

---

## 🏗️ ARQUITETURA DO PROJETO

### Padrão MVVM (Model-View-ViewModel)

O projeto usa o padrão MVVM, que separa:

1. **Model (Modelo)**: Dados e lógica de negócio
   - `PhotoAssetEntity`: Representa uma foto
   - `PhotoGroupEntity`: Representa um grupo de fotos duplicadas/similares
   - `QualityScore`: Armazena métricas de qualidade

2. **View (Visualização)**: Interface do usuário
   - `SieveView`: Tela de batalha de fotos
   - `SieveSelectionView`: Seleção de grupos
   - `ContentArea`: Área principal do app

3. **ViewModel**: Lógica de apresentação
   - `SieveViewModel`: Gerencia estado do torneio
   - `ScanViewModel`: Gerencia processo de análise

---

## 📝 CONCEITOS SWIFT IMPORTANTES

### 1. Property Wrappers

```swift
// @State - Para estado local da view
@State private var showingError = false

// @Published - Em ViewModels, notifica mudanças
@Published var phase: SievePhase = .notStarted

// @StateObject - Cria e mantém uma instância de ObservableObject
@StateObject private var viewModel = SieveViewModel()

// @Environment - Acessa valores do ambiente
@Environment(\.dismiss) private var dismiss

// @Query - Busca dados do SwiftData
@Query(filter: #Predicate<PhotoGroupEntity> { $0.groupType == "duplicate" })
private var duplicateGroups: [PhotoGroupEntity]
```

**Para YouTube:**
- @State: dados da própria view
- @Published: dados que views observam
- @StateObject: cria objeto observável
- @Environment: valores compartilhados
- @Query: busca automática no banco

### 2. SwiftData (Persistência de Dados)

```swift
// Define um modelo persistente
@Model
final class PhotoAssetEntity {
    var localIdentifier: String
    var creationDate: Date?
    // SwiftData salva automaticamente!
}

// Relacionamentos
@Relationship(deleteRule: .cascade)
var photos: [PhotoAssetEntity] = []
```

**Para YouTube:**
- `@Model`: transforma classe em modelo de dados
- `@Relationship`: define relações entre entidades
- `.cascade`: quando deletar pai, deleta filhos
- Tudo é automático, sem SQL!

### 3. Async/Await (Concorrência)

```swift
// Função assíncrona
func fetchPhotos() async -> [Photo] {
    // Operação que leva tempo
}

// Chamando função assíncrona
Task {
    let photos = await fetchPhotos()
}

// Actor - Thread-safe automático
actor PhotoLibraryService {
    func loadImage() async -> Image? { }
}
```

**Para YouTube:**
- `async`: função que pode "esperar"
- `await`: "aguarde este resultado"
- `Task`: executa código assíncrono
- `actor`: evita race conditions automaticamente

### 4. Enums com Associated Values

```swift
// Enum que carrega dados adicionais
enum SievePhase: Equatable {
    case notStarted
    case fighting
    case roundWon(winnerId: String) // Carrega ID do vencedor
    case tournamentComplete(championId: String)
}

// Usando em switch
switch viewModel.phase {
case .notStarted:
    startScreen
case .roundWon(let winnerId):
    print("Vencedor: \(winnerId)")
}
```

**Para YouTube:**
- Enums podem carregar dados
- `case .roundWon(winnerId:)` tem um valor associado
- Use `let` no switch para extrair o valor

### 5. Generics e Result Builders

```swift
// ViewBuilder - cria views com sintaxe limpa
@ViewBuilder
private var content: some View {
    if condition {
        Text("Sim")
    } else {
        Text("Não")
    }
}
```

---

## 🎯 PADRÕES USADOS NO PHOTOCLEANER

### 1. Separation of Concerns (Separação de Responsabilidades)

```swift
// ❌ ERRADO - View fazendo tudo
struct SieveView: View {
    func setupTournament() {
        // Lógica complexa aqui...
        // Cálculos...
        // Validações...
    }
}

// ✅ CORRETO - ViewModel com lógica
class SieveViewModel: ObservableObject {
    func setupTournament(from group: PhotoGroupEntity) {
        // Toda a lógica aqui
    }
}

struct SieveView: View {
    @StateObject private var viewModel = SieveViewModel()
    
    var body: some View {
        // Apenas UI
    }
}
```

**Para YouTube:**
- View: apenas apresentação visual
- ViewModel: toda a lógica
- Facilita testes e manutenção

### 2. Computed Properties

```swift
class SieveViewModel: ObservableObject {
    @Published var rounds: [TournamentRound] = []
    @Published var currentRoundIndex: Int = 0
    
    // Propriedade calculada - sempre atualizada
    var totalRounds: Int {
        rounds.count
    }
    
    // Outra computed property
    var currentRoundNumber: Int {
        currentRoundIndex + 1
    }
    
    var roundName: String {
        let remainingRounds = totalRounds - currentRoundIndex
        switch remainingRounds {
        case 1: return "Final!"
        case 2: return "Semi-Final"
        default: return "Rodada \(currentRoundNumber)"
        }
    }
}
```

**Para YouTube:**
- Não armazena valor, calcula quando acessado
- Sempre sincronizado com outras propriedades
- Ótimo para formatações e transformações

### 3. Guard Statements (Validação Antecipada)

```swift
// ❌ Pirâmide do inferno
func setupTournament(from group: PhotoGroupEntity) {
    if group.photos.count >= 2 {
        let sortedPhotos = group.photos.sorted { ... }
        if !sortedPhotos.isEmpty {
            self.photos = sortedPhotos
            buildBracket(from: sortedPhotos.map { $0.localIdentifier })
            if !rounds.isEmpty {
                if let firstMatch = rounds.first?.matches.first {
                    currentMatch = firstMatch
                    phase = .fighting
                }
            }
        }
    }
}

// ✅ Código limpo com guard
func setupTournament(from group: PhotoGroupEntity) {
    // Reseta estado primeiro
    reset()
    
    // Valida fotos
    let sortedPhotos = Array(group.photos).sorted {
        $0.compositeQualityScore < $1.compositeQualityScore
    }
    
    guard sortedPhotos.count >= 2 else {
        print("⚠️ Fotos insuficientes")
        return
    }
    
    self.photos = sortedPhotos
    
    // Constrói chave
    buildBracket(from: sortedPhotos.map { $0.localIdentifier })
    
    // Valida rounds
    guard !rounds.isEmpty, let firstMatch = rounds.first?.matches.first else {
        print("⚠️ Falha ao criar rounds")
        return
    }
    
    currentMatch = firstMatch
    phase = .fighting
}
```

**Para YouTube:**
- `guard` valida e sai cedo se der errado
- Evita aninhamento excessivo
- Código mais linear e legível

### 4. Protocol-Oriented Programming

```swift
// Protocol define um contrato
protocol Identifiable {
    var id: UUID { get }
}

// Structs implementam o protocol
struct SieveMatch: Identifiable, Equatable {
    let id = UUID()
    let photo1Id: String
    let photo2Id: String
    var winnerId: String?
}

// SwiftUI requer Identifiable para ForEach
ForEach(matches) { match in
    // match.id é usado automaticamente
}
```

---

## 🎨 SWIFTUI PATTERNS

### 1. Composição de Views

```swift
// View grande dividida em pequenas
struct SieveView: View {
    var body: some View {
        ZStack {
            background
            
            switch viewModel.phase {
            case .notStarted:
                startScreen // View separada
            case .fighting:
                battleContent // View separada
            }
        }
    }
    
    // View pequena e focada
    private var startScreen: some View {
        VStack {
            Text("Batalha de Fotos!")
            // ...
        }
    }
    
    // Outra view pequena
    private var battleContent: some View {
        HSplitView {
            bracketSidebar
            mainArea
        }
    }
}
```

**Para YouTube:**
- Divida views grandes em pequenas
- Mais fácil de entender e manter
- Reutilização de código

### 2. ViewModifiers Customizados

```swift
// Modifier reutilizável
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
    }
}

// Extension para facilitar uso
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Uso
Text("Hello")
    .cardStyle()
```

### 3. Animations (Animações)

```swift
// Animação simples
withAnimation(.spring()) {
    isExpanded = true
}

// Animação customizada
withAnimation(
    .spring(response: 0.3, dampingFraction: 0.6)
) {
    winnerSide = .left
}

// Animação na view
Text("Winner!")
    .scaleEffect(isWinner ? 1.02 : 1.0)
    .animation(.spring(), value: isWinner)

// Transições
if showConfetti {
    ConfettiView()
        .transition(.scale.combined(with: .opacity))
}
```

**Para YouTube:**
- `withAnimation`: anima mudanças de estado
- `.animation()`: anima view específica
- `.transition()`: anima entrada/saída
- `.spring()`: animação com física realista

### 4. GeometryReader (Layouts Dinâmicos)

```swift
GeometryReader { geometry in
    HStack(spacing: 0) {
        // Calcula largura baseado no espaço disponível
        let cardWidth = (geometry.size.width - 80) / 2 - 32
        
        photoCard(width: cardWidth)
        vsIndicator
        photoCard(width: cardWidth)
    }
}
```

---

## 🔄 FLUXO DE DADOS

### 1. One-Way Data Flow

```
View → ViewModel → Model
 ↑                    ↓
 ← @Published Update ←
```

```swift
// 1. View dispara ação
Button("Selecionar Esquerda") {
    viewModel.selectWinner(side: .left)
}

// 2. ViewModel processa
class SieveViewModel: ObservableObject {
    @Published var winnerSide: Side?
    
    func selectWinner(side: Side) {
        // Atualiza estado
        winnerSide = side
        
        // Processa lógica
        recordWinner(winnerId)
    }
}

// 3. View reage à mudança
var body: some View {
    photoCard(isWinner: viewModel.winnerSide == .left)
}
```

### 2. Dependency Injection

```swift
// View recebe dados de fora
struct SieveView: View {
    let group: PhotoGroupEntity // Injetado
    
    @StateObject private var viewModel = SieveViewModel()
}

// Uso
SieveView(group: selectedGroup)
```

---

## 🎯 VISION FRAMEWORK

### Como Funciona a Análise de Fotos

```swift
actor PhotoAnalysisService {
    // 1. Carrega imagem como CGImage
    func loadImage(for asset: PHAsset) async -> CGImage? {
        // PhotoKit API
    }
    
    // 2. Cria request do Vision
    func analyzePhoto(_ asset: PHAsset) async -> AnalysisResult? {
        guard let cgImage = await loadImage(for: asset) else {
            return nil
        }
        
        // Cria handler do Vision
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        // Cria requests
        let sharpnessRequest = VNImageRequestHandler(...)
        let exposureRequest = VNImageRequestHandler(...)
        
        // Executa análise
        try? await handler.perform([sharpnessRequest, exposureRequest])
        
        // Extrai resultados
        return AnalysisResult(...)
    }
    
    // 3. Compara fotos para duplicatas
    func comparePhotos(_ photo1: CGImage, _ photo2: CGImage) async -> Double {
        // Gera feature print de cada foto
        let fp1 = await generateFeaturePrint(photo1)
        let fp2 = await generateFeaturePrint(photo2)
        
        // Calcula similaridade (0.0 a 1.0)
        let similarity = fp1.computeDistance(to: fp2)
        
        return similarity
    }
}
```

**Para YouTube:**
- Vision Framework: IA da Apple
- Analisa qualidade, nitidez, exposição
- Feature prints: "impressão digital" da foto
- Compara similarity entre fotos
- Tudo on-device (privado)

---

## 🗄️ SWIFTDATA RELATIONSHIPS

### Como Funcionam os Relacionamentos

```swift
// Modelo pai
@Model
final class PhotoGroupEntity {
    var id: UUID
    var groupType: String // "duplicate" ou "similar"
    
    // Relacionamento: um grupo tem várias fotos
    @Relationship(deleteRule: .cascade)
    var photos: [PhotoAssetEntity] = []
}

// Modelo filho
@Model
final class PhotoAssetEntity {
    var localIdentifier: String
    var creationDate: Date?
    
    // Relacionamento inverso: foto pertence a grupos
    var groups: [PhotoGroupEntity]? 
}
```

**Comportamentos:**

```swift
// .cascade - Deleta filhos quando pai é deletado
@Relationship(deleteRule: .cascade)
var photos: [PhotoAssetEntity]

// .nullify - Remove referência mas mantém filhos
@Relationship(deleteRule: .nullify)
var photos: [PhotoAssetEntity]

// .deny - Não permite deletar se tiver filhos
@Relationship(deleteRule: .deny)
var photos: [PhotoAssetEntity]
```

### Queries no SwiftData

```swift
// Query básica
@Query
private var allGroups: [PhotoGroupEntity]

// Query com filtro
@Query(filter: #Predicate<PhotoGroupEntity> { 
    $0.groupType == "duplicate" 
})
private var duplicateGroups: [PhotoGroupEntity]

// Query com sort
@Query(sort: \PhotoAssetEntity.creationDate, order: .reverse)
private var photos: [PhotoAssetEntity]

// Query complexa
@Query(filter: #Predicate<PhotoGroupEntity> { 
    $0.groupType == "duplicate" && $0.photos.count >= 2
}, sort: \PhotoGroupEntity.averageSimilarity, order: .reverse)
private var groups: [PhotoGroupEntity]
```

---

## 🎮 ALGORITMO DO TORNEIO (BATTLE MODE)

### Como Funciona o Bracket

```swift
/*
Exemplo com 5 fotos:

Rodada 1:
  Photo 1 vs Photo 2  →  Winner A
  Photo 3 vs Photo 4  →  Winner B
  Photo 5             →  (bye - passa direto)

Rodada 2 (Semi-Final):
  Winner A vs Winner B  →  Winner C
  Photo 5 vs (esperando)

Rodada 3 (Final):
  Winner C vs Photo 5  →  CAMPEÃO!
*/

func buildBracket(from photoIds: [String]) {
    var remainingIds = photoIds
    rounds = []
    var roundNumber = 1
    
    // Enquanto tiver mais de 1 foto
    while remainingIds.count > 1 {
        var roundMatches: [SieveMatch] = []
        var nextRoundIds: [String] = []
        
        // Cria confrontos (pares de fotos)
        while remainingIds.count >= 2 {
            let photo1 = remainingIds.removeFirst()
            let photo2 = remainingIds.removeFirst()
            roundMatches.append(SieveMatch(photo1Id: photo1, photo2Id: photo2))
            
            // Placeholder para vencedor
            nextRoundIds.append("placeholder_\(roundMatches.count)")
        }
        
        // Se sobrou 1 (número ímpar), passa direto (bye)
        if !remainingIds.isEmpty {
            let byeId = remainingIds.removeFirst()
            nextRoundIds.append(byeId)
        }
        
        rounds.append(TournamentRound(
            roundNumber: roundNumber,
            matches: roundMatches
        ))
        
        remainingIds = nextRoundIds
        roundNumber += 1
    }
}
```

**Para YouTube:**
- Torneio eliminatório simples
- Divide fotos em pares
- Vencedores avançam para próxima rodada
- Último que sobra é o campeão
- "Bye" = passar de fase sem jogar (número ímpar)

---

## 🎨 CONCEITOS DE UI/UX

### 1. Progressive Disclosure (Revelação Progressiva)

```swift
// Mostra informações gradualmente
switch viewModel.phase {
case .notStarted:
    // Apenas tela inicial simples
    startScreen
    
case .fighting:
    // Agora mostra batalha completa
    battleContent
    
case .tournamentComplete:
    // Finalmente mostra resultado
    championScreen
}
```

### 2. Visual Feedback

```swift
// Feedback visual quando usuário interage
Button {
    viewModel.selectWinner(side: .left)
} label: {
    photoCard
        .scaleEffect(isWinner ? 1.02 : 1.0) // Cresce um pouco
        .overlay {
            if isWinner {
                winnerBadge // Badge de vencedor
            }
        }
        .shadow(
            color: isWinner ? .green : .gray, 
            radius: isWinner ? 20 : 10
        )
}
.animation(.spring(), value: isWinner)
```

### 3. Loading States

```swift
enum ViewState {
    case loading
    case loaded(data: [Photo])
    case error(message: String)
    case empty
}

var body: some View {
    switch state {
    case .loading:
        ProgressView("Carregando...")
    case .loaded(let photos):
        photoList(photos)
    case .error(let message):
        ErrorView(message: message)
    case .empty:
        EmptyStateView()
    }
}
```

---

## 🐛 DEBUGGING E LOGS

### Estratégia de Logging

```swift
// ✅ Logs informativos
print("✅ SieveViewModel: Torneio iniciado com \(photos.count) fotos")

// ⚠️ Warnings (avisos)
print("⚠️ SieveViewModel: Fotos insuficientes (precisa: 2, tem: \(count))")

// ❌ Erros
print("❌ PhotoAnalysis: Falha ao carregar imagem - \(error.localizedDescription)")

// 📍 Checkpoints (marcos)
print("📍 Rodada \(roundNumber): \(matches.count) confrontos")

// 🏆 Sucessos importantes
print("🏆 Campeão definido: \(championId)")
```

### Assert vs Guard

```swift
// Assert - apenas em debug, crash se falhar
assert(photos.count >= 2, "Deve ter pelo menos 2 fotos")

// Guard - sempre ativo, retorna graciosamente
guard photos.count >= 2 else {
    print("⚠️ Fotos insuficientes")
    return
}

// Precondition - sempre ativo, crash se falhar
precondition(photos.count >= 2, "Bug crítico: fotos insuficientes")
```

---

## 📊 PERFORMANCE

### 1. Lazy Loading

```swift
// ❌ Carrega tudo de uma vez (lento)
let allPhotos = fetchAllPhotos()

// ✅ Carrega sob demanda
LazyVStack {
    ForEach(photoIds, id: \.self) { id in
        AsyncImage(id: id) // Carrega quando aparecer na tela
    }
}
```

### 2. Task Cancellation

```swift
struct PhotoView: View {
    @State private var image: NSImage?
    @State private var loadTask: Task<Void, Never>?
    
    var body: some View {
        content
            .task(id: photoId) {
                // Task anterior é cancelada automaticamente
                image = await loadImage(photoId)
            }
    }
}
```

### 3. Caching

```swift
actor ImageCache {
    private var cache = NSCache<NSString, NSImage>()
    
    init() {
        cache.countLimit = 500 // Limite de items
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB
    }
    
    func image(for key: String) -> NSImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: NSImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
```

---

## 🎓 CONCEITOS PARA CANAL DO YOUTUBE

### Tópicos para Vídeos

1. **"SwiftUI do Zero ao Snap Sieve"**
   - Views básicas
   - State management
   - Navegação

2. **"SwiftData: Banco de Dados Sem SQL"**
   - Criar modelos
   - Relacionamentos
   - Queries

3. **"Vision Framework: IA da Apple"**
   - Detectar duplicatas
   - Analisar qualidade
   - Feature prints

4. **"Async/Await: Concorrência Fácil"**
   - Task
   - Actor
   - MainActor

5. **"MVVM no SwiftUI"**
   - Arquitetura
   - ObservableObject
   - Published properties

6. **"Animações Profissionais no SwiftUI"**
   - Spring animations
   - Transitions
   - GeometryEffect

7. **"Publicando na App Store"**
   - Xcode setup
   - App Store Connect
   - Screenshots

### Progressão de Conteúdo

**Iniciante:**
- Views básicas (Text, Image, Button)
- Stack views (VStack, HStack, ZStack)
- State e Binding
- Lists e ForEach

**Intermediário:**
- NavigationStack
- Sheets e modals
- ViewModels
- SwiftData básico

**Avançado:**
- Actors e concorrência
- Vision Framework
- Performance optimization
- Custom animations

---

## 🔍 PATTERNS IMPORTANTES

### 1. Repository Pattern

```swift
// Abstração do acesso a dados
protocol PhotoRepository {
    func fetchPhotos() async -> [Photo]
    func savePhoto(_ photo: Photo) async
    func deletePhoto(id: String) async
}

// Implementação com SwiftData
actor SwiftDataPhotoRepository: PhotoRepository {
    func fetchPhotos() async -> [Photo] {
        // Implementação
    }
}

// Uso no ViewModel
class PhotoViewModel: ObservableObject {
    private let repository: PhotoRepository
    
    init(repository: PhotoRepository) {
        self.repository = repository
    }
}
```

### 2. Factory Pattern

```swift
enum ViewFactory {
    static func makeSieveView(
        for group: PhotoGroupEntity
    ) -> some View {
        SieveView(group: group)
    }
    
    static func makeEmptyState() -> some View {
        EmptyStateView()
    }
}
```

### 3. Coordinator Pattern (Navegação)

```swift
@MainActor
class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func showSieve(for group: PhotoGroupEntity) {
        path.append(Route.battle(group))
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

---

## 💡 DICAS DE CÓDIGO LIMPO

### 1. Nomenclatura

```swift
// ✅ Nomes descritivos
func setupTournament(from group: PhotoGroupEntity)
var totalRoundsRemaining: Int
let duplicatePhotoGroups: [PhotoGroupEntity]

// ❌ Nomes vagos
func setup()
var x: Int
let groups: [PhotoGroupEntity]
```

### 2. Funções Pequenas

```swift
// ✅ Uma função, uma responsabilidade
func validatePhotos() -> Bool {
    return photos.count >= 2
}

func buildBracket() {
    // Apenas constrói bracket
}

func startTournament() {
    guard validatePhotos() else { return }
    buildBracket()
    advanceToFirstMatch()
}

// ❌ Função fazendo muitas coisas
func setupEverything() {
    // Valida, constrói, inicia, etc...
}
```

### 3. Early Returns

```swift
// ✅ Retorno antecipado
func process() {
    guard isValid else { return }
    guard hasData else { return }
    guard canProceed else { return }
    
    // Lógica principal
}

// ❌ Aninhamento profundo
func process() {
    if isValid {
        if hasData {
            if canProceed {
                // Lógica principal
            }
        }
    }
}
```

---

## 🎯 PRÓXIMOS PASSOS

### Melhorias Futuras no Snap Sieve

1. **Suporte a RAW**
   - Detectar arquivos RAW
   - Análise específica para RAW
   - Comparação RAW vs JPEG

2. **Exportar Relatórios**
   - PDF com estatísticas
   - Lista de fotos deletadas
   - Gráficos de uso de espaço

3. **iCloud Photos**
   - Sincronizar com iCloud
   - Download sob demanda
   - Status de sincronização

4. **Scans Agendados**
   - Timer automático
   - Notificações
   - Background processing

5. **Machine Learning Customizado**
   - Treinar modelo próprio
   - Detectar rostos específicos
   - Categorização inteligente

---

## 📚 RECURSOS PARA APRENDIZADO

### Documentação Apple

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [PhotoKit](https://developer.apple.com/documentation/photokit)

### Conceitos Importantes

1. **Property Wrappers**: @State, @Published, @Binding
2. **Result Builders**: @ViewBuilder
3. **Actors**: Thread-safety
4. **Async/Await**: Concorrência moderna
5. **Predicates**: Queries type-safe

### Padrões de Design

1. **MVVM**: Model-View-ViewModel
2. **Repository**: Abstração de dados
3. **Factory**: Criação de objetos
4. **Coordinator**: Navegação
5. **Observer**: Reactive programming

---

## 🎬 ESTRUTURA DE VÍDEOS SUGERIDA

### Vídeo 1: "Como Criei um App de Limpeza de Fotos"
- Overview do projeto
- Demonstração do app
- Tecnologias usadas

### Vídeo 2: "SwiftUI Básico - Views e State"
- Anatomia de uma View
- State management
- Composition

### Vídeo 3: "SwiftData - Banco de Dados Fácil"
- Criar modelos
- Salvar dados
- Queries

### Vídeo 4: "Vision Framework - IA da Apple"
- Análise de imagens
- Detecção de duplicatas
- Quality scores

### Vídeo 5: "MVVM no Snap Sieve"
- Arquitetura
- ViewModels
- Data flow

### Vídeo 6: "Sieve Mode - Algoritmo de Torneio"
- Lógica do bracket
- State machine
- Animações

### Vídeo 7: "Publicando na App Store"
- Xcode setup
- App Store Connect
- Aprovação

---

## 🚀 DICA FINAL

**Para seu canal:**
- Mostre o código funcionando primeiro
- Explique conceitos gradualmente
- Use exemplos simples antes dos complexos
- Mostre erros comuns e como corrigir
- Faça lives codificando features novas

**Para novas versões:**
- Sempre adicione testes
- Documente mudanças
- Mantenha código legível
- Use comentários em português
- Git commits descritivos

Boa sorte com o canal! 🎥
