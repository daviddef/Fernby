import SwiftUI

/// Sight words are recognized whole, not sounded out, so this activity
/// never shows the target printed until after the answer — the child hears
/// the word and taps the printed word that matches, the reverse of
/// LetterSoundMatchView's "see it, hear it" order.
struct SightWordTapView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var target = SightWordBank.random()
    @State private var choices: [String] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongWord: String?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            Text("Tap the word you hear")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            Button {
                Voice.shared.speak(target, interrupt: true)
            } label: {
                Label("Hear it again", systemImage: "speaker.wave.2.fill")
            }
            .buttonStyle(.bordered)

            HStack(spacing: 16) {
                ForEach(choices, id: \.self) { choice in
                    Button(choice) { tapped(choice) }
                        .buttonStyle(.bigTap(tint: tint(for: choice)))
                        .disabled(justAnsweredCorrectly)
                }
            }
        }
        .padding()
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: String) -> Color {
        if justAnsweredCorrectly, choice == target { return .green }
        if wrongWord == choice { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        target = SightWordBank.random()
        let decoys = SightWordBank.decoys(excluding: target, count: 2)
        choices = ([target] + decoys).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongWord = nil
        feedback = nil
        Voice.shared.speak(target, interrupt: true)
    }

    private func tapped(_ choice: String) {
        let correct = choice == target
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("Yes! That word is \(target).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongWord = choice
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's listen again. \(target)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongWord = nil
                feedback = nil
            }
        }
    }
}
