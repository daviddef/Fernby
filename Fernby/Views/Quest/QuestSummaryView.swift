import SwiftUI

/// The celebration screen — reserved for quest completion and mastery
/// unlocks only, never per-question, per the cognitive-load finding that
/// constant reward animation hinders rather than helps younger children.
struct QuestSummaryView: View {
    let correctCount: Int
    let totalCount: Int
    let masteredNodeTitle: String?
    /// Set only when this quest's mastery event completed a whole biome's
    /// gate — a bigger, rarer moment than an ordinary node unlock, so it
    /// gets its own badge instead of sharing the plain unlock line.
    var justCompletedBiome: Biome? = nil
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            CompanionView(progressStore: ProgressStore.shared, size: 180, showsName: true)

            Text("Quest complete!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))

            if let biome = justCompletedBiome {
                biomeCompleteBadge(biome)
            } else if let masteredNodeTitle {
                Text("You unlocked \(masteredNodeTitle)!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Continue") { onDone() }
                .buttonStyle(.bigTap)
        }
        .padding()
        .onAppear {
            var message = "Great job! You finished your quest."
            if let biome = justCompletedBiome {
                message += " You finished \(biome.title)!"
            } else if let masteredNodeTitle {
                message += " You unlocked \(masteredNodeTitle)!"
            }
            Voice.shared.speak(message, interrupt: true)
            Haptics.shared.questComplete()
        }
    }

    private func biomeCompleteBadge(_ biome: Biome) -> some View {
        VStack(spacing: 6) {
            Text(biome.emoji)
                .font(.system(size: 40))
            Text("You finished \(biome.title)!")
                .font(.system(size: 19, weight: .bold, design: .rounded))
            Text("A new place on the trail is open.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 22)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(biome.accentColor.opacity(0.18))
        )
    }
}
