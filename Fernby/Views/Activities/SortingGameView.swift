import SwiftUI

/// Bonus round — a genuinely different interaction from tap-a-choice
/// (activities) or flip-a-card (MatchingGameView): tap a bucket to sort each
/// item into a category, one at a time. Reuses PhonicsBank/NumberBank
/// content already met in the normal quest loop. A wrong bucket never
/// penalizes anything — the item just waits for another try, same
/// gentle-retry spirit as every other activity.
struct SortingGameView: View {
    let onDone: () -> Void

    @State private var round = SortingBank.randomRound()
    @State private var index = 0
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 24) {
            Text("Bonus Round: Sort It Out!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            progressDots

            if index < round.items.count {
                Text(round.items[index].display)
                    .font(.system(size: 84, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                    .id(round.items[index].id)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("🎉")
                    .font(.system(size: 84))
            }

            HStack(spacing: 16) {
                bucketButton(label: round.leftLabel, isLeft: true)
                bucketButton(label: round.rightLabel, isLeft: false)
            }

            if index >= round.items.count {
                Button("Continue") { onDone() }
                    .buttonStyle(.bigTap)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: index)
        .answerFeedback(feedback)
        .onAppear { setUp() }
    }

    private var progressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<round.items.count, id: \.self) { i in
                Circle()
                    .fill(i < index ? Color.fernbyCorrect : Color.accentColor.opacity(0.25))
                    .frame(width: 12, height: 12)
            }
        }
    }

    private func bucketButton(label: String, isLeft: Bool) -> some View {
        Button {
            tapped(isLeft: isLeft)
        } label: {
            Text(label)
                .multilineTextAlignment(.center)
        }
        .buttonStyle(.bigTap)
        .disabled(index >= round.items.count)
    }

    private func setUp() {
        round = SortingBank.randomRound()
        index = 0
        feedback = nil
        Voice.shared.speak(round.prompt, interrupt: true)
        speakCurrentItem()
    }

    private func speakCurrentItem() {
        guard index < round.items.count else { return }
        Voice.shared.speak(round.items[index].spokenForm, interrupt: false)
    }

    private func tapped(isLeft: Bool) {
        guard index < round.items.count else { return }
        let item = round.items[index]
        let correct = item.belongsLeft == isLeft

        if correct {
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("Yes!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                feedback = nil
                index += 1
                if index >= round.items.count {
                    Haptics.shared.questComplete()
                    Voice.shared.speak("You sorted them all!")
                } else {
                    speakCurrentItem()
                }
            }
        } else {
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Try the other bucket.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                feedback = nil
            }
        }
    }
}
