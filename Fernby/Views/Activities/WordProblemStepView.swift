import SwiftUI

/// Reuses the exact answer mechanic every math activity before it has
/// established (three tap choices, gentle retry, first-response-only
/// tracking) — the only new skill here is the sentence in front of it, so
/// nothing else about the interaction should be unfamiliar.
struct WordProblemStepView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var problem = WordProblemBank.randomProblem(forDifficulty: 1)
    @State private var choices: [Int] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 24) {
            Text(problem.scenario)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 16) {
                ForEach(choices, id: \.self) { choice in
                    Button("\(choice)") { tapped(choice) }
                        .buttonStyle(.bigTap(tint: tint(for: choice)))
                        .disabled(justAnsweredCorrectly)
                }
            }
        }
        .padding()
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: Int) -> Color {
        if justAnsweredCorrectly, choice == problem.fact.answer { return .green }
        if wrongChoice == choice { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        problem = WordProblemBank.randomProblem(forDifficulty: difficultyLevel)
        let distractors = MathFactBank.distractors(for: problem.fact, count: 2)
        choices = ([problem.fact.answer] + distractors).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak(problem.scenario, interrupt: true)
    }

    private func tapped(_ choice: Int) {
        let correct = choice == problem.fact.answer
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("That's right! The answer is \(problem.fact.answer).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's think about it again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
                feedback = nil
            }
        }
    }
}
