import SwiftUI

/// Isolates exactly one skill — matching a letter or digraph to its sound —
/// per the "one skill at a time" pedagogy constraint. The grapheme is
/// always shown on screen, never audio-only. Wrong answers never end the
/// activity; the same question just asks again.
///
/// Shared by two nodes the same way WordBuildingView shares `blending` and
/// `cvcWords`: `reading.letterSounds` uses PhonicsBank, `reading.
/// digraphSounds` uses DigraphBank — same interaction, different bank.
struct LetterSoundMatchView: View {
    let nodeID: String
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    private var isDigraphVariant: Bool { nodeID == "reading.digraphSounds" }
    private var bank: [LetterSoundEntry] { isDigraphVariant ? DigraphBank.all : PhonicsBank.all }

    // Can't reference `nodeID` in a property initializer — setUpQuestion(),
    // called on appear, immediately overwrites this with the real pick.
    @State private var target = PhonicsBank.random()
    @State private var choices: [LetterSoundEntry] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongLetter: String?
    @State private var feedback: AnswerFeedbackKind?

    var body: some View {
        VStack(spacing: 28) {
            Text(target.letter.uppercased())
                .font(.system(size: target.letter.count > 2 ? 64 : 96, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .accessibilityLabel("The letters \(target.letter)")

            Text("What sound does this make?")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .answerFeedback(feedback)
        .onAppear { setUpQuestion() }
    }

    private func tint(for choice: LetterSoundEntry) -> Color {
        if justAnsweredCorrectly, choice.letter == target.letter { return .fernbyCorrect }
        if wrongLetter == choice.letter { return .fernbyWrong }
        return .accentColor
    }

    private func setUpQuestion() {
        target = bank.random(avoiding: RecentItemTracker.shared.recent(for: nodeID))
        RecentItemTracker.shared.record(target.letter, for: nodeID)
        let decoys = bank.decoys(excluding: target, count: 2)
        choices = ([target] + decoys).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongLetter = nil
        feedback = nil
        Voice.shared.speak("What sound does this make?", interrupt: true)
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
            feedback = .correct
            Haptics.shared.correct()
            Voice.shared.speak("\(PraiseBank.random()) \(target.letter) says \(target.sound), like \(target.exampleWord)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongLetter = choice.letter
            feedback = .tryAgain
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's try again. \(target.sound)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongLetter = nil
                feedback = nil
            }
        }
    }
}
