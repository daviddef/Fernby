import SwiftUI

/// Reading a simple picture graph — three categories shown as stacked
/// icons, side by side, so the comparison is visible at a glance rather
/// than just implied by numbers.
struct DataGraphView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = DataGraphBank.random()
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: String?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .bottom, spacing: 24) {
                ForEach(question.categories) { category in
                    VStack(spacing: 3) {
                        ForEach(0..<category.count, id: \.self) { _ in
                            Text(category.emoji).font(.system(size: 26))
                        }
                    }
                }
            }

            Text(question.promptText)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(question.choices, id: \.self) { choice in
                    Button(choice) { tapped(choice) }
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

    private func tint(for choice: String) -> Color {
        if justAnsweredCorrectly, choice == question.answer { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        question = DataGraphBank.random()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak(question.spokenPrompt, interrupt: true)
    }

    private func tapped(_ choice: String) {
        let correct = choice == question.answer
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak(PraiseBank.random())
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's look again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
                feedback = nil
            }
        }
    }
}
