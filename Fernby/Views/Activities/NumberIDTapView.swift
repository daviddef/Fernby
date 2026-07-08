import SwiftUI

/// Bridges counting objects (the previous node) to reading bare equations
/// (the next node, addition): here the number is only ever spoken as a
/// word, never shown as a numeral, so matching numeral-to-word is the
/// isolated skill — no counting scaffold to lean on.
struct NumberIDTapView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var target = 1
    @State private var choices: [Int] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            Text("Which number is \"\(NumberBank.word(for: target))\"?")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(choices, id: \.self) { choice in
                    Button("\(choice)") { tapped(choice) }
                        .buttonStyle(.bigTap(tint: tint(for: choice)))
                        .disabled(justAnsweredCorrectly)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: Int) -> Color {
        if justAnsweredCorrectly, choice == target { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        let (newTarget, newChoices) = NumberBank.randomTarget(forDifficulty: difficultyLevel)
        target = newTarget
        choices = newChoices
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("Which number is \(NumberBank.word(for: target))?", interrupt: true)
    }

    private func tapped(_ choice: Int) {
        let correct = choice == target
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) That's \(target).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's try again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
                feedback = nil
            }
        }
    }
}
