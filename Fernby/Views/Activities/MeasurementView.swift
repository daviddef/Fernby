import SwiftUI

/// Length comparison judged by eye — the K-1 measurement skill before a
/// ruler or units enter the picture. The two bars are the actual tappable
/// choices, not a separate multiple-choice row underneath them.
struct MeasurementView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var question = MeasurementBank.random()
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongIsA: Bool?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 32) {
            Text("Which one is \(question.prompt == .longer ? "longer" : "shorter")?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            VStack(spacing: 20) {
                bar(width: question.widthA, isA: true)
                bar(width: question.widthB, isA: false)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func bar(width: CGFloat, isA: Bool) -> some View {
        Button {
            tapped(isA: isA)
        } label: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tint(forA: isA))
                .frame(width: width, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(justAnsweredCorrectly)
        .accessibilityLabel(isA ? "Bar A" : "Bar B")
    }

    private func tint(forA isA: Bool) -> Color {
        if justAnsweredCorrectly, isA == question.correctIsA { return .fernbyCorrect }
        if wrongIsA == isA { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        question = MeasurementBank.random()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongIsA = nil
        feedback = nil
        Voice.shared.speak("Which one is \(question.prompt == .longer ? "longer" : "shorter")?", interrupt: true)
    }

    private func tapped(isA: Bool) {
        let correct = isA == question.correctIsA
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
            wrongIsA = isA
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's look again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongIsA = nil
                feedback = nil
            }
        }
    }
}
