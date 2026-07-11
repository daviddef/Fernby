import SwiftUI

/// A real founder complaint — "still no crosswords, anagrams" — traced back
/// to a discoverability bug, not a missing feature: Criss-Cross (crossword)
/// and Letter Scramble (anagram) existed but only ever appeared as a random
/// 1-of-7 pick at the very end of a daily quest, roughly a 1-in-7 chance
/// per session with no way to choose it on purpose. This is the fix — an
/// always-open arcade, named by game, so a child (or the grown-up showing
/// it off) can go straight to "I want to do a crossword" instead of hoping
/// the dice land right.
struct ArcadeView: View {
    let onDismiss: () -> Void

    @State private var selectedGame: BonusGame?

    private var eligibleGames: [BonusGame] {
        BonusGame.eligible(voiceEnabled: Voice.shared.enabled)
    }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(eligibleGames) { game in
                        Button {
                            Haptics.shared.tap()
                            selectedGame = game
                        } label: {
                            VStack(spacing: 6) {
                                Text(game.emoji)
                                    .font(.system(size: 34))
                                Text(game.title)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.center)
                                Text(game.subtitle)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.16))
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(game.title). \(game.subtitle)")
                    }
                }
                .padding()
            }
            .navigationTitle("Game Arcade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                }
            }
        }
        .fullScreenCover(item: $selectedGame) { game in
            BonusGameContainerView(game: game, onDone: { selectedGame = nil })
        }
    }
}
