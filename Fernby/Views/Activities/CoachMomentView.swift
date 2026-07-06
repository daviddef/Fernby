import SwiftUI

/// The Teach-Back mechanic: the companion attempts a question from
/// something it already learned (a mastered node), and it's sometimes
/// wrong — pulled from that node's own review rotation, not scripted for
/// this moment. The child checks the answer and, when it's wrong, corrects
/// it. This is the review rep in disguise: the child never sees a drill,
/// they see a friend who needs help. Grounded in the protégé effect —
/// children put in more effort checking/correcting a character than they
/// do answering a question aimed at themselves.
struct CoachMomentView: View {
    let node: SkillNode
    let onDone: () -> Void

    private enum Stage {
        case asking
        case correcting
        case done(childWasRight: Bool)
    }

    @State private var prompt: CoachPrompt?
    @State private var stage: Stage = .asking

    private var companionName: String { CompanionAbilityCatalog.companionName }

    var body: some View {
        VStack(spacing: 24) {
            CompanionView(progressStore: ProgressStore.shared, size: 120)

            if let prompt {
                switch stage {
                case .asking:
                    askingView(prompt)
                case .correcting:
                    correctingView(prompt)
                case .done(let childWasRight):
                    doneView(prompt, childWasRight: childWasRight)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .onAppear { setUp() }
    }

    private func askingView(_ prompt: CoachPrompt) -> some View {
        VStack(spacing: 18) {
            Text("\(companionName) is trying this one!")
                .font(.system(size: 18, weight: .semibold, design: .rounded))

            Text(prompt.promptText)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)

            Text("\(companionName) says: \(prompt.companionAnswerText)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.accentColor)

            Text("Is \(companionName) right?")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button("Yes!") { answered(saidYes: true, prompt: prompt) }
                    .buttonStyle(.bigTap(tint: .green))
                Button("Help \(companionName)") { answered(saidYes: false, prompt: prompt) }
                    .buttonStyle(.bigTap(tint: .orange))
            }
        }
    }

    private func correctingView(_ prompt: CoachPrompt) -> some View {
        VStack(spacing: 18) {
            Text("Show \(companionName) the right answer:")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach([prompt.correctAnswerText, prompt.companionAnswerText].shuffled(), id: \.self) { choice in
                    Button(choice) { corrected(with: choice, prompt: prompt) }
                        .buttonStyle(.bigTap)
                }
            }
        }
    }

    private func doneView(_ prompt: CoachPrompt, childWasRight: Bool) -> some View {
        VStack(spacing: 12) {
            Text(childWasRight ? "You taught \(companionName) something!" : "Now you both know!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text("The answer was \(prompt.correctAnswerText).")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
        }
    }

    private func setUp() {
        let difficultyLevel = ProgressStore.shared.progress(for: node.id).difficultyLevel
        prompt = CoachMomentGenerator.prompt(for: node, difficultyLevel: difficultyLevel)
        stage = .asking
        guard let prompt else { return }
        Voice.shared.speak("\(companionName) is trying this one. \(prompt.spokenPrompt)", interrupt: true)
    }

    private func answered(saidYes: Bool, prompt: CoachPrompt) {
        Haptics.shared.tap()
        if prompt.isCompanionCorrect {
            // Companion was actually right, regardless of what the child said —
            // either way this ends here with the same true answer surfaced.
            Voice.shared.speak(saidYes
                ? "Yes, \(companionName) got it right!"
                : "Actually, \(companionName) was right this time! The answer is \(prompt.correctAnswerText).")
            finish(childWasRight: saidYes)
        } else if saidYes {
            // Companion was wrong and the child missed it — no punishment,
            // just the information, same as every other activity's ethos.
            Voice.shared.speak("Let's look again together. The answer is really \(prompt.correctAnswerText).")
            finish(childWasRight: false)
        } else {
            stage = .correcting
            Voice.shared.speak("Which one is right?", interrupt: true)
        }
    }

    private func corrected(with choice: String, prompt: CoachPrompt) {
        let childWasRight = choice == prompt.correctAnswerText
        Haptics.shared.correct()
        Voice.shared.speak(childWasRight
            ? "Yes! You taught \(companionName)! It's \(prompt.correctAnswerText)."
            : "Close — it's really \(prompt.correctAnswerText). Now \(companionName) knows too.")
        finish(childWasRight: childWasRight)
    }

    private func finish(childWasRight: Bool) {
        stage = .done(childWasRight: childWasRight)
        ReviewScheduler.markReviewed(node.id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            onDone()
        }
    }
}
