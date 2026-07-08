import SwiftUI

/// The bonus round — genuinely different gameplay from every other
/// activity's tap-a-choice pattern: flip two cards, see if they belong
/// together. Appears at the end of a quest using content from banks the
/// child has already met through the normal quest loop (PhonicsBank,
/// NumberBank), so it reads as a reward lap, not new material to learn.
/// A wrong pair never penalizes anything — the cards just flip back over
/// and the child tries again, same gentle-retry spirit as every other
/// activity, adapted to a memory game instead of a question.
struct MatchingGameView: View {
    let onDone: () -> Void

    private struct Card: Identifiable {
        let id = UUID()
        let pairID: String
        let label: String
    }

    @State private var pairs: [MatchPair] = []
    @State private var cards: [Card] = []
    @State private var revealed: Set<UUID> = []
    @State private var matchedPairIDs: Set<String> = []
    @State private var firstSelection: Card?
    @State private var isChecking = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 24) {
            Text("Bonus Round: Find the Matches!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(cards) { card in
                    cardView(card)
                }
            }
            .padding(.horizontal)

            if matchedPairIDs.count == pairs.count && !pairs.isEmpty {
                Button("Continue") { onDone() }
                    .buttonStyle(.bigTap)
            }
        }
        .padding()
        .onAppear { setUp() }
    }

    private func cardView(_ card: Card) -> some View {
        let isFaceUp = revealed.contains(card.id) || matchedPairIDs.contains(card.pairID)
        let isMatched = matchedPairIDs.contains(card.pairID)

        return Button {
            tapped(card)
        } label: {
            Text(isFaceUp ? card.label : "🌱")
                .font(.system(size: isFaceUp ? 34 : 28, weight: .heavy, design: .rounded))
                .frame(width: 92, height: 92)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(isMatched ? Color.fernbyCorrect.opacity(0.25) : Color.accentColor.opacity(isFaceUp ? 0.85 : 0.5))
                )
        }
        .buttonStyle(.plain)
        .disabled(isMatched || isChecking || revealed.contains(card.id))
        .accessibilityLabel(isFaceUp ? card.label : "Face-down card")
    }

    private func setUp() {
        pairs = MatchGameBank.randomPairs(count: 3)
        var built: [Card] = []
        for pair in pairs {
            built.append(Card(pairID: pair.id, label: pair.left))
            built.append(Card(pairID: pair.id, label: pair.right))
        }
        cards = built.shuffled()
        revealed = []
        matchedPairIDs = []
        firstSelection = nil
        isChecking = false
        Voice.shared.speak("Bonus round! Find the matching cards.", interrupt: true)
    }

    private func tapped(_ card: Card) {
        guard !isChecking, !revealed.contains(card.id) else { return }
        Haptics.shared.tap()
        revealed.insert(card.id)

        guard let first = firstSelection else {
            firstSelection = card
            return
        }

        isChecking = true
        if first.pairID == card.pairID {
            matchedPairIDs.insert(card.pairID)
            firstSelection = nil
            isChecking = false
            Haptics.shared.correct()
            Voice.shared.speak("Match!")
            if matchedPairIDs.count == pairs.count {
                Haptics.shared.questComplete()
                Voice.shared.speak("You found them all!")
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                revealed.remove(first.id)
                revealed.remove(card.id)
                firstSelection = nil
                isChecking = false
            }
        }
    }
}
