import SwiftUI

/// The celebration screen — reserved for quest completion and mastery
/// unlocks only, never per-question, per the cognitive-load finding that
/// constant reward animation hinders rather than helps younger children.
struct QuestSummaryView: View {
    let correctCount: Int
    let totalCount: Int
    /// Usually 0 or 1 node, but a longer, multi-rep quest can master more
    /// than one node in a single sitting — shown as a list, not silently
    /// collapsed to just the last one.
    var masteredNodeTitles: [String] = []
    /// Set when this quest's mastery events completed one or more whole
    /// biome gates — a bigger, rarer moment than an ordinary node unlock,
    /// so it gets its own badge instead of sharing the plain unlock line.
    var justCompletedBiomes: [Biome] = []
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            CompanionView(progressStore: ProgressStore.shared, size: 180, showsName: true)

            Text("Quest complete!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))

            VStack(spacing: 12) {
                ForEach(justCompletedBiomes, id: \.id) { biome in
                    biomeCompleteBadge(biome)
                }
                if !unbadgedMasteredTitles.isEmpty {
                    Text("You unlocked \(unbadgedMasteredTitles.formattedList())!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button("Continue") { onDone() }
                .buttonStyle(.bigTap)
        }
        .padding()
        .onAppear {
            var message = "Great job! You finished your quest."
            for biome in justCompletedBiomes {
                message += " You finished \(biome.title)!"
            }
            if !unbadgedMasteredTitles.isEmpty {
                message += " You unlocked \(unbadgedMasteredTitles.formattedList())!"
            }
            Voice.shared.speak(message, interrupt: true)
            Haptics.shared.questComplete()
        }
    }

    /// Node titles not already called out by a biome badge above, so a
    /// finished node doesn't get announced twice.
    private var unbadgedMasteredTitles: [String] {
        let biomeTitles = Set(justCompletedBiomes.map(\.title))
        return masteredNodeTitles.filter { !biomeTitles.contains($0) }
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
