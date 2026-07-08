import SwiftUI

/// Mirrors AdditionTapView's contract and spare, static visual style exactly
/// — same reasoning about attention/focus applies. The one addition:
/// concrete counters show the starting count with the "taken away" amount
/// crossed out rather than removed, so subtraction reads as a visible
/// transformation of the same dots, not a second unrelated group.
struct SubtractionTapView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var fact = MathFact(a: 1, b: 1, operation: .subtract)
    @State private var choices: [Int] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?
    @State private var objectEmoji = FunObjectBank.random()

    var body: some View {
        VStack(spacing: 28) {
            if fact.a <= 10 {
                DotGroup(count: fact.a, emoji: objectEmoji, crossedOutIndices: Set(0..<max(fact.b, 0)))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: Int) -> Color {
        if justAnsweredCorrectly, choice == fact.answer { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        fact = MathFactBank.randomFact(forDifficulty: difficultyLevel, operation: .subtract)
        let distractors = MathFactBank.distractors(for: fact, count: 2)
        choices = ([fact.answer] + distractors).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        objectEmoji = FunObjectBank.random()
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
            Voice.shared.speak("\(PraiseBank.random()) \(fact.spokenText) is \(fact.answer).")
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
