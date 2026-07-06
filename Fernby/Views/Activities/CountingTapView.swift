import SwiftUI

/// The first math node a learner ever sees. Objects are shown, not
/// abstracted into dots — counting real-feeling things (apples, stars)
/// before the equation-and-dot pairing addition introduces later.
struct CountingTapView: View {
    let difficultyLevel: Int
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    private static let objectEmoji = ["🍎", "⭐️", "🍓", "🐚", "🎈"]

    @State private var target = 1
    @State private var choices: [Int] = []
    @State private var emoji = "🍎"
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongChoice: Int?

    private let columns = [GridItem(.adaptive(minimum: 44, maximum: 44), spacing: 8)]

    var body: some View {
        VStack(spacing: 28) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<target, id: \.self) { _ in
                    Text(emoji).font(.system(size: 36))
                }
            }
            .frame(maxWidth: 260)

            Text("How many are there?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))

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
        if justAnsweredCorrectly, choice == target { return .green }
        if wrongChoice == choice { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        let (newTarget, newChoices) = NumberBank.randomTarget(forDifficulty: difficultyLevel)
        target = newTarget
        choices = newChoices
        emoji = Self.objectEmoji.randomElement() ?? "🍎"
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongChoice = nil
        Voice.shared.speak("How many are there?", interrupt: true)
    }

    private func tapped(_ choice: Int) {
        let correct = choice == target
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            Haptics.shared.correct()
            Voice.shared.speak("Yes! \(NumberBank.word(for: target))!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongChoice = choice
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's count again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongChoice = nil
            }
        }
    }
}
