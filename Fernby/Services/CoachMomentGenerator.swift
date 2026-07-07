import Foundation

struct CoachPrompt {
    let promptText: String
    let spokenPrompt: String
    let correctAnswerText: String
    /// What the companion "guesses" — sometimes right, sometimes wrong, so
    /// the child's check is a real check, not a foregone conclusion.
    let companionAnswerText: String
    let isCompanionCorrect: Bool
}

/// Builds a single review question, reusing each node's own content bank
/// exactly as its real activity would — a Coach Moment should never test
/// material a child wasn't actually taught. Only kinds with a simple
/// "one clearly correct choice among a few" shape are supported; sentence
/// building and word problems are narrative/multi-step and don't reduce to
/// a single right-or-wrong guess a companion can plausibly make, so
/// `supports` returns false for those and ReviewScheduler skips them —
/// a scoped cut, not an oversight.
enum CoachMomentGenerator {
    static func supports(_ kind: ActivityKind) -> Bool {
        switch kind {
        case .sentenceBuild, .wordProblemStep, .letterTracing: return false
        default: return true
        }
    }

    static func prompt(for node: SkillNode, difficultyLevel: Int) -> CoachPrompt? {
        switch node.activityKind {
        case .letterSoundMatch:
            let target = PhonicsBank.random()
            let decoy = PhonicsBank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "What sound does \"\(target.letter.uppercased())\" make?",
                spokenPrompt: "What sound does the letter \(target.letter) make?",
                correct: target.sound,
                wrong: decoy.sound
            )

        case .additionTap, .subtractionTap:
            let operation: MathOperation = node.activityKind == .additionTap ? .add : .subtract
            let fact = MathFactBank.randomFact(forDifficulty: difficultyLevel, operation: operation)
            let wrong = MathFactBank.distractors(for: fact, count: 1)[0]
            return build(
                promptText: "\(fact.displayText) = ?",
                spokenPrompt: "\(fact.spokenText)?",
                correct: "\(fact.answer)",
                wrong: "\(wrong)"
            )

        case .countingTap, .numberIDTap:
            let (target, choices) = NumberBank.randomTarget(forDifficulty: difficultyLevel)
            let wrong = choices.first { $0 != target } ?? target + 1
            return build(
                promptText: "How many is \"\(NumberBank.word(for: target))\"?",
                spokenPrompt: "How many is \(NumberBank.word(for: target))?",
                correct: "\(target)",
                wrong: "\(wrong)"
            )

        case .wordBuilding:
            let target = WordBuildingBank.random()
            let decoy = WordBuildingBank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "\(target.emoji)",
                spokenPrompt: "What word matches this picture?",
                correct: target.word,
                wrong: decoy.word
            )

        case .sightWordTap:
            let target = SightWordBank.random()
            let decoy = SightWordBank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "\"\(target)\"",
                spokenPrompt: "Is this word \(target)?",
                correct: target,
                wrong: decoy
            )

        case .sentenceBuild, .wordProblemStep, .letterTracing:
            return nil
        }
    }

    private static func build(promptText: String, spokenPrompt: String, correct: String, wrong: String) -> CoachPrompt {
        let isCorrect = Double.random(in: 0..<1) > 0.55
        return CoachPrompt(
            promptText: promptText,
            spokenPrompt: spokenPrompt,
            correctAnswerText: correct,
            companionAnswerText: isCorrect ? correct : wrong,
            isCompanionCorrect: isCorrect
        )
    }
}
