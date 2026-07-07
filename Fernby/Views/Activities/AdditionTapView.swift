import SwiftUI

/// The "calculation drill" activity type — kept deliberately spare (static
/// equation, no timer, minimal motion) per the finding that attention/focus
/// predicts calculation performance more than number sense itself, so the
/// UI shouldn't compete for that attention.
struct AdditionTapView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var fact = MathFact(a: 1, b: 1, operation: .add)
    @State private var choices: [Int] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            if max(fact.a, fact.b) <= 10 {
                // Concrete counters at low difficulty; fades out at higher
                // levels once the symbolic equation alone is the point.
                HStack(spacing: 24) {
                    DotGroup(count: fact.a, color: .blue)
                    Text("+").font(.system(size: 28, weight: .bold, design: .rounded))
                    DotGroup(count: fact.b, color: .orange)
                }
            }

            Text("\(fact.displayText) = ?")
                .font(.system(size: 44, weight: .heavy, design: .rounded))

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
        if justAnsweredCorrectly, choice == fact.answer { return .green }
        if wrongChoice == choice { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        fact = MathFactBank.randomFact(forDifficulty: difficultyLevel, operation: .add)
        let distractors = MathFactBank.distractors(for: fact, count: 2)
        choices = ([fact.answer] + distractors).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("\(fact.spokenText)?", interrupt: true)
    }

    private func tapped(_ choice: Int) {
        let correct = choice == fact.answer
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("That's right! \(fact.spokenText) is \(fact.answer).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Not quite — let's try again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
                feedback = nil
            }
        }
    }
}
