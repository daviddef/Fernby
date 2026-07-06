import SwiftUI

/// Isolates exactly one skill — matching a single letter to its sound — per
/// the "one skill at a time" pedagogy constraint. The letter is always
/// shown on screen, never audio-only. Wrong answers never end the activity;
/// the same question just asks again.
struct LetterSoundMatchView: View {
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    @State private var target = PhonicsBank.random()
    @State private var choices: [LetterSoundEntry] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongLetter: String?

    var body: some View {
        VStack(spacing: 28) {
            Text(target.letter.uppercased())
                .font(.system(size: 96, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .accessibilityLabel("The letter \(target.letter)")

            Text("What sound does this letter make?")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(choices, id: \.letter) { choice in
                    Button {
                        tapped(choice)
                    } label: {
                        VStack(spacing: 4) {
                            Text(choice.emoji).font(.system(size: 40))
                            Text(choice.exampleWord).font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                    }
                    .buttonStyle(.bigTap(tint: tint(for: choice)))
                    .disabled(justAnsweredCorrectly)
                }
            }
        }
        .padding()
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: LetterSoundEntry) -> Color {
        if justAnsweredCorrectly, choice.letter == target.letter { return .green }
        if wrongLetter == choice.letter { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        let decoys = PhonicsBank.decoys(excluding: target, count: 2)
        choices = ([target] + decoys).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongLetter = nil
        Voice.shared.speak("What sound does this letter make?", interrupt: true)
        Voice.shared.speak(target.sound, interrupt: false)
    }

    private func tapped(_ choice: LetterSoundEntry) {
        let correct = choice.letter == target.letter
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            Haptics.shared.correct()
            Voice.shared.speak("Yes! \(target.letter) says \(target.sound), like \(target.exampleWord)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongLetter = choice.letter
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's try again. \(target.sound)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongLetter = nil
            }
        }
    }
}
