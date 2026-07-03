import SwiftUI

/// The celebration screen — reserved for quest completion and mastery
/// unlocks only, never per-question, per the cognitive-load finding that
/// constant reward animation hinders rather than helps younger children.
struct QuestSummaryView: View {
    let correctCount: Int
    let totalCount: Int
    let masteredNodeTitle: String?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            CompanionView(progressStore: ProgressStore.shared, size: 180, showsName: true)

            Text("Quest complete!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))

            if let masteredNodeTitle {
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
            if let masteredNodeTitle {
                message += " You unlocked \(masteredNodeTitle)!"
            }
            Voice.shared.speak(message, interrupt: true)
            Haptics.shared.questComplete()
        }
    }
}
