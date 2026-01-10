import SwiftUI
import SwiftData

/// View principal do modo Battle (torneio de fotos)
/// Permite ao usuário escolher sua foto favorita em uma série de batalhas eliminatórias
struct BattleView: View {
    // MARK: - Propriedades
    
    /// Grupo de fotos que participará do torneio
    let group: PhotoGroupEntity

    /// ViewModel que gerencia a lógica do torneio
    @StateObject private var viewModel = BattleViewModel()
    
    /// Ação para fechar esta view
    @Environment(\.dismiss) private var dismiss
    
    /// Controla se o alert de erro está sendo exibido
    @State private var showingError = false
    
    /// Mensagem de erro a ser exibida no alert
    @State private var errorMessage = ""

    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Gradiente de fundo (preto com toque roxo)
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.purple.opacity(0.3), Color.black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Exibe diferentes telas baseado na fase do torneio
            switch viewModel.phase {
            case .notStarted:
                startScreen // Tela inicial de apresentação
            case .fighting, .roundWon:
                battleContent // Tela de batalha ativa
            case .tournamentComplete:
                championScreen // Tela do campeão
            }

            // Overlay de confete (aparece quando há um campeão)
            if viewModel.showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false) // Não bloqueia interações
            }
        }
        .onAppear {
            setupTournament()
        }
        .alert("Erro", isPresented: $showingError) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Métodos Auxiliares
    
    /// Configura e valida o torneio antes de iniciar
    private func setupTournament() {
        // Valida que há fotos suficientes (mínimo 2)
        guard group.photos.count >= 2 else {
            errorMessage = "Este grupo precisa de pelo menos 2 fotos para iniciar uma batalha."
            showingError = true
            return
        }
        
        viewModel.setupTournament(from: group)
        
        // Verifica se o setup funcionou corretamente
        if viewModel.photos.isEmpty {
            errorMessage = "Não foi possível carregar as fotos para esta batalha. Tente executar uma nova análise."
            showingError = true
        }
    }

    // MARK: - Tela Inicial

    private var startScreen: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 20)

            Text("Photo Battle!")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.white)

            Text("\(group.photos.count) photos will compete")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.8))

            Text("Choose your favorite in each round until one champion remains!")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                viewModel.setupTournament(from: group)
            } label: {
                Label("Start Battle", systemImage: "flag.checkered")
                    .font(.title2.bold())
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.top, 20)
        }
    }

    // MARK: - Battle Content

    private var battleContent: some View {
        HSplitView {
            // Tournament bracket sidebar
            bracketSidebar
                .frame(minWidth: 200, maxWidth: 280)

            // Main battle area
            VStack(spacing: 0) {
                // Header with round info
                battleHeader
                    .padding()
                    .background(.ultraThinMaterial)

                // Main comparison area
                battleArena
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Action buttons
                actionButtons
                    .padding()
                    .background(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Bracket Sidebar

    private var bracketSidebar: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tournament Bracket")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                ForEach(Array(viewModel.bracketData.enumerated()), id: \.offset) { roundIdx, roundSlots in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(roundName(for: roundIdx))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal)

                        ForEach(roundSlots) { slot in
                            BracketMatchView(slot: slot)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color.black.opacity(0.3))
    }

    private func roundName(for index: Int) -> String {
        let remainingRounds = viewModel.totalRounds - index
        switch remainingRounds {
        case 1: return "FINAL"
        case 2: return "SEMI-FINAL"
        case 3: return "QUARTER-FINAL"
        default: return "ROUND \(index + 1)"
        }
    }

    // MARK: - Battle Header

    private var battleHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Label("Exit", systemImage: "xmark.circle")
            }
            .buttonStyle(.borderless)

            Spacer()

            VStack(spacing: 4) {
                Text(viewModel.roundName)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(viewModel.progressText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            // Progress bar
            ProgressView(value: viewModel.overallProgress)
                .progressViewStyle(.linear)
                .controlSize(.small)
                .frame(width: 100)
                .tint(.orange)
        }
    }

    // MARK: - Battle Arena

    private var battleArena: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left photo
                if let leftPhoto = viewModel.leftPhoto {
                    battleCard(
                        photo: leftPhoto,
                        side: .left,
                        isWinner: viewModel.winnerSide == .left,
                        size: geometry.size
                    )
                }

                // VS badge
                vsIndicator
                    .frame(width: 80)

                // Right photo
                if let rightPhoto = viewModel.rightPhoto {
                    battleCard(
                        photo: rightPhoto,
                        side: .right,
                        isWinner: viewModel.winnerSide == .right,
                        size: geometry.size
                    )
                }
            }
        }
        .padding()
    }

    private func battleCard(photo: PhotoAssetEntity, side: BattleViewModel.Side, isWinner: Bool, size: CGSize) -> some View {
        let photoAsset = PhotoAsset(from: photo)
        let cardWidth = (size.width - 80) / 2 - 32

        return VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Photo
                CachedThumbnailImage(
                    assetId: photo.localIdentifier,
                    size: CGSize(width: 800, height: 800)
                )
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: cardWidth, maxHeight: size.height - 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isWinner ? Color.green : Color.white.opacity(0.2), lineWidth: isWinner ? 4 : 1)
                }
                .shadow(color: isWinner ? .green.opacity(0.5) : .black.opacity(0.3), radius: isWinner ? 20 : 10)

                // Winner badge
                if isWinner {
                    winnerBadge
                        .offset(x: -10, y: 10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(isWinner ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isWinner)

            // Photo info with detailed breakdown
            BattlePhotoInfoCard(
                photo: photo,
                isRecommended: side == .left ? viewModel.leftIsRecommended : viewModel.rightIsRecommended
            )
            .frame(maxWidth: cardWidth)
        }
        .frame(maxWidth: .infinity)
    }

    private var vsIndicator: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.orange, .red],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: .orange.opacity(0.5), radius: 10)

            Text("VS")
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .rotationEffect(.degrees(viewModel.isAnimating ? 360 : 0))
        .animation(.easeInOut(duration: 0.5), value: viewModel.isAnimating)
    }

    private var winnerBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
            Text("WINNER!")
        }
        .font(.caption.bold())
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.green)
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .shadow(color: .green.opacity(0.5), radius: 5)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 40) {
            battleButton(title: "Keep Left", side: .left, color: .blue)
            battleButton(title: "Keep Right", side: .right, color: .purple)
        }
    }

    private func battleButton(title: String, side: BattleViewModel.Side, color: Color) -> some View {
        Button {
            viewModel.selectWinner(side: side)
        } label: {
            HStack {
                if side == .left {
                    Image(systemName: "arrow.left.circle.fill")
                }
                Text(title)
                    .fontWeight(.bold)
                if side == .right {
                    Image(systemName: "arrow.right.circle.fill")
                }
            }
            .font(.title3)
            .frame(minWidth: 160)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .disabled(viewModel.isAnimating)
        .opacity(viewModel.winnerSide != nil && viewModel.winnerSide != side ? 0.5 : 1.0)
    }

    // MARK: - Champion Screen

    private var championScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            // Trophy animation
            Image(systemName: "trophy.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .yellow.opacity(0.5), radius: 30)

            Text("CHAMPION!")
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Champion photo
            if let champion = viewModel.champion {
                let photoAsset = PhotoAsset(from: champion)

                VStack(spacing: 16) {
                    CachedThumbnailImage(
                        assetId: champion.localIdentifier,
                        size: CGSize(width: 800, height: 800)
                    )
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400, maxHeight: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                    }
                    .shadow(color: .yellow.opacity(0.3), radius: 20)

                    VStack(spacing: 4) {
                        Text(photoAsset.formattedDimensions)
                            .font(.headline)
                            .foregroundStyle(.white)

                        if let score = photoAsset.qualityScore {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                Text("Quality: \(Int(score.composite * 100))%")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
            }

            // Stats
            statsView

            Spacer()

            // Actions
            HStack(spacing: 20) {
                Button {
                    viewModel.reset()
                    viewModel.setupTournament(from: group)
                } label: {
                    Label("Battle Again", systemImage: "arrow.counterclockwise")
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(.white)

                Button {
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }

            Spacer()
        }
        .padding()
    }

    private var statsView: some View {
        HStack(spacing: 40) {
            statItem(value: "\(viewModel.photos.count)", label: "Photos Battled")
            statItem(value: "\(viewModel.totalRounds)", label: "Rounds Fought")
            statItem(value: "\(viewModel.eliminatedPhotos.count)", label: "Eliminated")
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

// MARK: - Bracket Match View

struct BracketMatchView: View {
    let slot: BracketSlot

    var body: some View {
        VStack(spacing: 2) {
            bracketEntry(name: slot.photo1Name, isWinner: slot.winner1, isEliminated: slot.isComplete && !slot.winner1)
            bracketEntry(name: slot.photo2Name, isWinner: slot.winner2, isEliminated: slot.isComplete && !slot.winner2)
        }
        .padding(8)
        .background(slot.isCurrentMatch ? Color.orange.opacity(0.3) : Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            if slot.isCurrentMatch {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 2)
            }
        }
        .padding(.horizontal)
    }

    private func bracketEntry(name: String, isWinner: Bool, isEliminated: Bool) -> some View {
        HStack(spacing: 6) {
            if isWinner {
                Image(systemName: "crown.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }

            Text(name)
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(isEliminated ? .white.opacity(0.3) : .white)
                .strikethrough(isEliminated)

            Spacer()

            if isWinner {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isWinner ? Color.green.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiParticleView(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

        for _ in 0..<100 {
            let particle = ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: -100...0),
                color: colors.randomElement() ?? .yellow,
                size: CGFloat.random(in: 8...16),
                rotation: Double.random(in: 0...360),
                fallDuration: Double.random(in: 2...4),
                swayAmount: CGFloat.random(in: 20...60)
            )
            particles.append(particle)
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let fallDuration: Double
    let swayAmount: CGFloat
}

struct ConfettiParticleView: View {
    let particle: ConfettiParticle
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var rotationAngle: Double = 0

    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size * 0.6)
            .rotationEffect(.degrees(particle.rotation + rotationAngle))
            .position(x: particle.x + xOffset, y: particle.y + yOffset)
            .onAppear {
                withAnimation(
                    .easeIn(duration: particle.fallDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    yOffset = 1000
                }
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                ) {
                    xOffset = particle.swayAmount
                }
                withAnimation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    rotationAngle = 360
                }
            }
    }
}

// MARK: - Preview

#Preview {
    // Create a mock group for preview
    BattleView(group: PhotoGroupEntity(groupType: .similar))
}
