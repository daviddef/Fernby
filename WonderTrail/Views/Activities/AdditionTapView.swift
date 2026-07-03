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
            Haptics.shared.correct()
            Voice.shared.speak("That's right! \(fact.spokenText) is \(fact.answer).")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            Haptics.shared.tryAgain()
            Voice.shared.speak("Not quite — let's try again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
            }
        }
    }
}

/// A calm, static row of dots — no animation, no physics, just a count a
/// child can visually verify against the equation above.
private struct DotGroup: View {
    let count: Int
    let color: Color

    private let columns = [GridItem(.adaptive(minimum: 18, maximum: 18), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<max(count, 0), id: \.self) { _ in
                Circle().fill(color).frame(width: 16, height: 16)
            }
        }
        .frame(width: 70)
    }
}
