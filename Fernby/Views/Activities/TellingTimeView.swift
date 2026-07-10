import SwiftUI

/// Telling time to the hour and half-hour — the K-1 scope, no minute-level
/// precision yet. A real analog clock face (ClockFaceView), not a digital
/// readout, since reading the hands is the actual skill.
struct TellingTimeView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = TimeBank.random()
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: String?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            ClockFaceView(hour: question.hour, minute: question.minute)

            Text("What time is it?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

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
        if justAnsweredCorrectly, choice == question.correctText { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        question = TimeBank.random()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("What time is it?", interrupt: true)
    }

    private func tapped(_ choice: String) {
        let correct = choice == question.correctText
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) It's \(TimeBank.spoken(hour: question.hour, minute: question.minute)).")
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
