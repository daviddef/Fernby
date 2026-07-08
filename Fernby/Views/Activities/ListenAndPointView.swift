import SwiftUI

/// Bonus round — audio is the *entire* prompt here, which nothing else in
/// this app does (every activity always shows the target on screen too;
/// see LetterSoundMatchView). A pure listening-comprehension check, framed
/// as a game: tap the picture or number that matches what you heard. Reuses
/// PhonicsBank/NumberBank content already met in the normal quest loop.
struct ListenAndPointView: View {
    let onDone: () -> Void

    @State private var round = ListenAndPointBank.randomRound()
    @State private var isDone = false
    @State private var wrongOptionID: UUID?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            Text("Bonus Round: Listen and Point!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            Button {
                Voice.shared.speak(round.targetSpokenCue, interrupt: true)
            } label: {
                Label("Hear it again", systemImage: "speaker.wave.2.fill")
            }
            .buttonStyle(.bordered)
            .disabled(isDone)

            HStack(spacing: 16) {
                ForEach(round.options) { option in
                    Button {
                        tapped(option)
                    } label: {
                        Text(option.display)
                            .font(.system(size: 40))
                    }
                    .buttonStyle(.bigTap(tint: tint(for: option)))
                    .disabled(isDone)
                }
            }

            if isDone {
                Button("Continue") { onDone() }
                    .buttonStyle(.bigTap)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUp() }
    }

    private func tint(for option: ListenPointOption) -> Color {
        if isDone, option.isTarget { return .fernbyCorrect }
        if wrongOptionID == option.id { return .fernbyWrong }
        return .accentColor
    }

    private func setUp() {
        round = ListenAndPointBank.randomRound()
        isDone = false
        wrongOptionID = nil
        feedback = nil
        Voice.shared.speak("Listen carefully.", interrupt: true)
        Voice.shared.speak(round.targetSpokenCue, interrupt: false)
    }

    private func tapped(_ option: ListenPointOption) {
        guard !isDone else { return }
        if option.isTarget {
            isDone = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("That's it!")
        } else {
            wrongOptionID = option.id
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Listen again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongOptionID = nil
                feedback = nil
            }
        }
    }
}
