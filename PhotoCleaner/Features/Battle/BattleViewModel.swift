import SwiftUI
import SwiftData

// MARK: - Battle State

enum BattlePhase: Equatable {
    case notStarted
    case fighting
    case roundWon(winnerId: String)
    case tournamentComplete(championId: String)
}

struct BattleMatch: Identifiable, Equatable {
    let id = UUID()
    let photo1Id: String
    let photo2Id: String
    var winnerId: String?

    var isComplete: Bool {
        winnerId != nil
    }
}

struct TournamentRound: Identifiable, Equatable {
    let id = UUID()
    let roundNumber: Int
    var matches: [BattleMatch]

    var isComplete: Bool {
        matches.allSatisfy { $0.isComplete }
    }

    var winners: [String] {
        matches.compactMap { $0.winnerId }
    }
}

// MARK: - ViewModel

@MainActor
final class BattleViewModel: ObservableObject {
    // MARK: - Published State

    @Published var phase: BattlePhase = .notStarted
    @Published var currentMatch: BattleMatch?
    @Published var rounds: [TournamentRound] = []
    @Published var currentRoundIndex: Int = 0
    @Published var currentMatchIndex: Int = 0
    @Published var photos: [PhotoAssetEntity] = []
    @Published var isAnimating = false
    @Published var showConfetti = false
    @Published var winnerSide: Side?

    enum Side {
        case left, right
    }

    // MARK: - Computed Properties

    var totalRounds: Int {
        rounds.count
    }

    var currentRoundNumber: Int {
        currentRoundIndex + 1
    }

    var roundName: String {
        guard !rounds.isEmpty else { return "" }

        let remainingRounds = totalRounds - currentRoundIndex

        switch remainingRounds {
        case 1:
            return "Final!"
        case 2:
            return "Semi-Final"
        case 3:
            return "Quarter-Final"
        default:
            return "Round \(currentRoundNumber)/\(totalRounds)"
        }
    }

    var progressText: String {
        let totalMatches = rounds.reduce(0) { $0 + $1.matches.count }
        let completedMatches = rounds.prefix(currentRoundIndex).reduce(0) { $0 + $1.matches.count } + currentMatchIndex
        return "Match \(completedMatches + 1) of \(totalMatches)"
    }

    var overallProgress: Double {
        let totalMatches = rounds.reduce(0) { $0 + $1.matches.count }
        guard totalMatches > 0 else { return 0 }
        let completedMatches = rounds.prefix(currentRoundIndex).reduce(0) { $0 + $1.matches.count } + currentMatchIndex
        return Double(completedMatches) / Double(totalMatches)
    }

    var leftPhoto: PhotoAssetEntity? {
        guard let match = currentMatch else { return nil }
        return photos.first { $0.localIdentifier == match.photo1Id }
    }

    var rightPhoto: PhotoAssetEntity? {
        guard let match = currentMatch else { return nil }
        return photos.first { $0.localIdentifier == match.photo2Id }
    }

    var champion: PhotoAssetEntity? {
        if case .tournamentComplete(let championId) = phase {
            return photos.first { $0.localIdentifier == championId }
        }
        return nil
    }

    var eliminatedPhotos: [PhotoAssetEntity] {
        guard let champion = champion else { return [] }
        return photos.filter { $0.localIdentifier != champion.localIdentifier }
    }

    // MARK: - Tournament Bracket Data

    var bracketData: [[BracketSlot]] {
        var result: [[BracketSlot]] = []

        for (roundIdx, round) in rounds.enumerated() {
            var roundSlots: [BracketSlot] = []

            for (matchIdx, match) in round.matches.enumerated() {
                let isCurrentMatch = roundIdx == currentRoundIndex && matchIdx == currentMatchIndex
                let photo1 = photos.first { $0.localIdentifier == match.photo1Id }
                let photo2 = photos.first { $0.localIdentifier == match.photo2Id }

                roundSlots.append(BracketSlot(
                    photo1Id: match.photo1Id,
                    photo2Id: match.photo2Id,
                    photo1Name: photo1?.fileName ?? "Photo",
                    photo2Name: photo2?.fileName ?? "Photo",
                    winnerId: match.winnerId,
                    isCurrentMatch: isCurrentMatch,
                    isComplete: match.isComplete
                ))
            }

            result.append(roundSlots)
        }

        return result
    }

    // MARK: - Setup

    func setupTournament(from group: PhotoGroupEntity) {
        // Get all photos sorted by quality score (lowest first)
        let sortedPhotos = group.photos.sorted {
            $0.compositeQualityScore < $1.compositeQualityScore
        }

        guard sortedPhotos.count >= 2 else { return }

        self.photos = sortedPhotos

        // Build tournament bracket
        buildBracket(from: sortedPhotos.map { $0.localIdentifier })

        // Start the tournament
        if let firstMatch = rounds.first?.matches.first {
            currentMatch = firstMatch
            phase = .fighting
        }
    }

    private func buildBracket(from photoIds: [String]) {
        var remainingIds = photoIds
        rounds = []

        // Calculate number of rounds needed
        var roundNumber = 1

        while remainingIds.count > 1 {
            var roundMatches: [BattleMatch] = []
            var nextRoundIds: [String] = []

            // Create matches for this round
            while remainingIds.count >= 2 {
                let photo1 = remainingIds.removeFirst()
                let photo2 = remainingIds.removeFirst()
                roundMatches.append(BattleMatch(photo1Id: photo1, photo2Id: photo2))
                // Placeholder for winner (will be filled during battle)
                nextRoundIds.append("placeholder_\(roundMatches.count)")
            }

            // If odd number, bye goes to next round
            if !remainingIds.isEmpty {
                nextRoundIds.append(remainingIds.removeFirst())
            }

            rounds.append(TournamentRound(roundNumber: roundNumber, matches: roundMatches))
            remainingIds = nextRoundIds
            roundNumber += 1
        }

        currentRoundIndex = 0
        currentMatchIndex = 0
    }

    // MARK: - Battle Actions

    func selectWinner(side: Side) {
        guard let match = currentMatch, !isAnimating else { return }

        let winnerId = side == .left ? match.photo1Id : match.photo2Id

        // Animate the selection
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            winnerSide = side
            isAnimating = true
        }

        // Update match result after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.recordWinner(winnerId)
        }
    }

    private func recordWinner(_ winnerId: String) {
        guard currentRoundIndex < rounds.count,
              currentMatchIndex < rounds[currentRoundIndex].matches.count else {
            return
        }

        // Record the winner
        rounds[currentRoundIndex].matches[currentMatchIndex].winnerId = winnerId

        // Check if round is complete
        if rounds[currentRoundIndex].isComplete {
            advanceToNextRound()
        } else {
            // Move to next match in current round
            currentMatchIndex += 1
            if currentMatchIndex < rounds[currentRoundIndex].matches.count {
                currentMatch = rounds[currentRoundIndex].matches[currentMatchIndex]
                winnerSide = nil
                isAnimating = false
            }
        }
    }

    private func advanceToNextRound() {
        let winners = rounds[currentRoundIndex].winners

        // Check if tournament is complete
        if winners.count == 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                phase = .tournamentComplete(championId: winners[0])
                showConfetti = true
            }
            return
        }

        // Build next round with winners
        currentRoundIndex += 1

        if currentRoundIndex < rounds.count {
            // Update existing round matches with actual winners
            var winnerIds = winners
            for matchIdx in 0..<rounds[currentRoundIndex].matches.count {
                if winnerIds.count >= 2 {
                    let winner1 = winnerIds.removeFirst()
                    let winner2 = winnerIds.removeFirst()
                    rounds[currentRoundIndex].matches[matchIdx] = BattleMatch(
                        photo1Id: winner1,
                        photo2Id: winner2
                    )
                }
            }

            currentMatchIndex = 0
            currentMatch = rounds[currentRoundIndex].matches.first

            withAnimation {
                phase = .roundWon(winnerId: winners.first ?? "")
                winnerSide = nil
                isAnimating = false
            }

            // After brief celebration, continue fighting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                withAnimation {
                    self?.phase = .fighting
                }
            }
        }
    }

    // MARK: - Reset

    func reset() {
        phase = .notStarted
        currentMatch = nil
        rounds = []
        currentRoundIndex = 0
        currentMatchIndex = 0
        photos = []
        isAnimating = false
        showConfetti = false
        winnerSide = nil
    }
}

// MARK: - Bracket Slot

struct BracketSlot: Identifiable, Equatable {
    let id = UUID()
    let photo1Id: String
    let photo2Id: String
    let photo1Name: String
    let photo2Name: String
    let winnerId: String?
    let isCurrentMatch: Bool
    let isComplete: Bool

    var winner1: Bool {
        winnerId == photo1Id
    }

    var winner2: Bool {
        winnerId == photo2Id
    }
}
