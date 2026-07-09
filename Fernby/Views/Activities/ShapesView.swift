import SwiftUI

/// K-level shape identification — the first math node beyond arithmetic.
/// Shows a real SwiftUI-drawn shape (see ShapeGlyph), asks its name, taps
/// the correct word — same tap-a-choice contract as every other activity.
struct ShapesView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var target = ShapeBank.random()
    @State private var choices: [ShapeKind] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: ShapeKind?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            ShapeGlyph(kind: target, color: .accentColor)
                .accessibilityLabel(target.displayName)

            Text("What shape is this?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

            HStack(spacing: 16) {
                ForEach(choices, id: \.self) { choice in
                    Button(choice.displayName) { tapped(choice) }
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

    private func tint(for choice: ShapeKind) -> Color {
        if justAnsweredCorrectly, choice == target { return .fernbyCorrect }
        if wrongChoice == choice { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        target = ShapeBank.random()
        let decoys = ShapeBank.decoys(excluding: target, count: 2)
        choices = ([target] + decoys).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        feedback = nil
        Voice.shared.speak("What shape is this?", interrupt: true)
    }

    private func tapped(_ choice: ShapeKind) {
        let correct = choice == target
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) That's a \(target.displayName.lowercased()).")
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
