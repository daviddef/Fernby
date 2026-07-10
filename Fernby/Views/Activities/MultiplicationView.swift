import SwiftUI

/// Equal groups shown as visually separated clusters — "3 groups of 2,
/// how many in total?" — repeated addition, not yet the × symbol.
struct MultiplicationView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = MultiplicationBank.random(forDifficulty: 1)
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    private let groupColumns = [GridItem(.adaptive(minimum: 44, maximum: 44), spacing: 6)]

    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 18) {
                ForEach(0..<question.groupCount, id: \.self) { _ in
                    LazyVGrid(columns: groupColumns, spacing: 6) {
                        ForEach(0..<question.itemsPerGroup, id: \.self) { _ in
                            Text(question.emoji).font(.system(size: 26))
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                    )
                }
            }

            Text("\(question.groupCount) groups of \(question.itemsPerGroup) — how many in total?")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

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
        question = MultiplicationBank.random(forDifficulty: difficultyLevel)
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("\(question.groupCount) groups of \(question.itemsPerGroup). How many in total?", interrupt: true)
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
            Voice.shared.speak("Let's count again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
                feedback = nil
            }
        }
    }
}
