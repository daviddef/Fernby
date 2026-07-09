import SwiftUI

/// "3 tens and 4 ones make what number?" — place value within 100. Tens
/// and ones are shown as grouped dot-columns (a ten-frame-style visual),
/// not just spoken as numbers, so the size relationship is visible, not
/// only abstract.
struct PlaceValueView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = PlaceValueBank.random(forDifficulty: 1)
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .top, spacing: 22) {
                tensGroup
                onesGroup
            }

            Text("\(question.tens) tens and \(question.ones) ones make what number?")
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

    private var tensGroup: some View {
        VStack(spacing: 4) {
            ForEach(0..<question.tens, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.accentColor)
                    .frame(width: 44, height: 10)
            }
            Text("tens").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
        }
    }

    private var onesGroup: some View {
        VStack(spacing: 4) {
            LazyVGrid(columns: [GridItem(.fixed(14)), GridItem(.fixed(14))], spacing: 4) {
                ForEach(0..<question.ones, id: \.self) { _ in
                    Circle().fill(Color.accentColor).frame(width: 12, height: 12)
                }
            }
            .frame(minHeight: 40)
            Text("ones").font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundStyle(.secondary)
        }
    }

    private func tint(for choice: Int) -> Color {
        if justAnsweredCorrectly, choice == question.answer { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        question = PlaceValueBank.random(forDifficulty: difficultyLevel)
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("\(question.tens) tens and \(question.ones) ones make what number?", interrupt: true)
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
