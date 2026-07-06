import SwiftUI

/// Shared by two nodes in the reading chain that both work over
/// WordBuildingBank but ask for a different skill: `reading.blending` (are
/// you can turn sounded-out letters into a word) comes first, then
/// `reading.cvcWords` (can you read the whole word fluently, no sound
/// scaffold) later in the same chain. `nodeID` picks the variant; nothing
/// else about the activity differs.
struct WordBuildingView: View {
    let nodeID: String
    let onFirstResponse: (Bool) -> Void
    let onAdvance: () -> Void

    private var isBlendingVariant: Bool { nodeID == "reading.blending" }

    @State private var target = WordBuildingBank.random()
    @State private var choices: [BuildableWord] = []
    @State private var hasRespondedFirstTime = false
    @State private var justAnsweredCorrectly = false
    @State private var wrongWord: String?

    var body: some View {
        VStack(spacing: 28) {
            if isBlendingVariant {
                HStack(spacing: 10) {
                    ForEach(target.letters, id: \.self) { letter in
                        Text(letter.uppercased())
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.accentColor)
                    }
                }
                Text("What word do these sounds make?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
            } else {
                Text(target.word)
                    .font(.system(size: 52, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                Text("Which picture matches this word?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 16) {
                ForEach(choices, id: \.word) { choice in
                    Button {
                        tapped(choice)
                    } label: {
                        VStack(spacing: 4) {
                            Text(choice.emoji).font(.system(size: 40))
                            if isBlendingVariant {
                                Text(choice.word).font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
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

    private func tint(for choice: BuildableWord) -> Color {
        if justAnsweredCorrectly, choice.word == target.word { return .green }
        if wrongWord == choice.word { return .orange.opacity(0.7) }
        return .accentColor
    }

    private func setUpQuestion() {
        target = WordBuildingBank.random()
        let decoys = WordBuildingBank.decoys(excluding: target, count: 2)
        choices = ([target] + decoys).shuffled()
        hasRespondedFirstTime = false
        justAnsweredCorrectly = false
        wrongWord = nil

        if isBlendingVariant {
            Voice.shared.speak("Listen: ", interrupt: true)
            for letter in target.letters {
                Voice.shared.speak(letter, interrupt: false)
            }
            Voice.shared.speak("What word is that?", interrupt: false)
        } else {
            Voice.shared.speak("Which picture matches \(target.word)?", interrupt: true)
        }
    }

    private func tapped(_ choice: BuildableWord) {
        let correct = choice.word == target.word
        if !hasRespondedFirstTime {
            hasRespondedFirstTime = true
            onFirstResponse(correct)
        }

        if correct {
            justAnsweredCorrectly = true
            Haptics.shared.correct()
            Voice.shared.speak("Yes! \(target.word)!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                onAdvance()
            }
        } else {
            wrongWord = choice.word
            Haptics.shared.tryAgain()
            Voice.shared.speak("Let's try again.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                wrongWord = nil
            }
        }
    }
}
