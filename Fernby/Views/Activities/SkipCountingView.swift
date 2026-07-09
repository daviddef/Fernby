import SwiftUI

/// "2, 4, 6, ___" — skip counting by 2s, 5s, or 10s. Sits between Addition
/// and Subtraction: still reasons about one growing sequence, not yet an
/// operation between two numbers.
struct SkipCountingView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = SkipCountingBank.random(forDifficulty: 1)
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            HStack(spacing: 14) {
                ForEach(question.sequence, id: \.self) { number in
                    Text("\(number)")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.accentColor)
                }
                Text("?")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Text("What comes next?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            HStack(spacing: 16) {
                ForEach(question.choices, id: \.self) { choice in
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
        if justAnsweredCorrectly, choice == question.answer { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        question = SkipCountingBank.random(forDifficulty: difficultyLevel)
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        let sequenceSpoken = question.sequence.map(String.init).joined(separator: ", ")
        Voice.shared.speak("\(sequenceSpoken)... what comes next?", interrupt: true)
    }

    private func tapped(_ choice: Int) {
        let correct = choice == question.answer
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) \(question.answer)!")
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
