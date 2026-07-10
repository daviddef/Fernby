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
        case .sentenceBuild, .wordProblemStep, .letterTracing, .measurementTap: return false
        default: return true
        }
    }

    static func prompt(for node: SkillNode, difficultyLevel: Int) -> CoachPrompt? {
        switch node.activityKind {
        case .letterSoundMatch:
            let bank: [LetterSoundEntry] = node.id == "reading.digraphSounds" ? DigraphBank.all : PhonicsBank.all
            let target = bank.random()
            let decoy = bank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "What sound does \"\(target.letter.uppercased())\" make?",
                spokenPrompt: "What sound does \(target.letter) make?",
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
            let bank: [BuildableWord]
            switch node.id {
            case "reading.blendWords": bank = BlendWordBank.all
            case "reading.digraphWords": bank = DigraphWordBank.all
            default: bank = WordBuildingBank.all
            }
            let target = bank.random()
            let decoy = bank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "\(target.emoji)",
                spokenPrompt: "What word matches this picture?",
                correct: target.word,
                wrong: decoy.word
            )

        case .sightWordTap:
            let bank: [String]
            switch node.id {
            case "reading.sightWordsAdvanced": bank = SightWordAdvancedBank.all
            case "reading.sightWordsTier3": bank = SightWordTier3Bank.all
            case "reading.sightWordsTier4": bank = SightWordTier4Bank.all
            default: bank = SightWordBank.all
            }
            let target = bank.randomWord()
            let decoy = bank.decoyWords(excluding: target, count: 1)[0]
            return build(
                promptText: "\"\(target)\"",
                spokenPrompt: "Is this word \(target)?",
                correct: target,
                wrong: decoy
            )

        case .shapesTap:
            let target = ShapeBank.random()
            let decoy = ShapeBank.decoys(excluding: target, count: 1)[0]
            return build(
                promptText: "What shape is this?",
                spokenPrompt: "What shape is this?",
                correct: target.displayName,
                wrong: decoy.displayName
            )

        case .skipCountingTap:
            let question = SkipCountingBank.random(forDifficulty: difficultyLevel)
            let wrong = question.choices.first { $0 != question.answer } ?? question.answer + 1
            return build(
                promptText: "\(question.sequence.map(String.init).joined(separator: ", ")), ?",
                spokenPrompt: "What comes next?",
                correct: "\(question.answer)",
                wrong: "\(wrong)"
            )

        case .placeValueTap:
            let question = PlaceValueBank.random(forDifficulty: difficultyLevel)
            let wrong = question.choices.first { $0 != question.answer } ?? question.answer + 1
            return build(
                promptText: "\(question.tens) tens and \(question.ones) ones = ?",
                spokenPrompt: "\(question.tens) tens and \(question.ones) ones make what number?",
                correct: "\(question.answer)",
                wrong: "\(wrong)"
            )

        case .tellingTimeTap:
            let question = TimeBank.random()
            let wrong = question.choices.first { $0 != question.correctText } ?? question.correctText
            return build(
                promptText: "What time is it?",
                spokenPrompt: "What time is it?",
                correct: question.correctText,
                wrong: wrong
            )

        case .moneyTap:
            let question = CoinBank.random(forDifficulty: difficultyLevel)
            let wrong = question.choices.first { $0 != question.total } ?? question.total + 1
            return build(
                promptText: "How much money is this?",
                spokenPrompt: "How much money is this?",
                correct: "\(question.total)¢",
                wrong: "\(wrong)¢"
            )

        case .dataGraphTap:
            let question = DataGraphBank.random()
            let wrong = question.choices.first { $0 != question.answer } ?? question.answer
            return build(
                promptText: question.promptText,
                spokenPrompt: question.spokenPrompt,
                correct: question.answer,
                wrong: wrong
            )

        case .multiplicationTap:
            let question = MultiplicationBank.random(forDifficulty: difficultyLevel)
            let wrong = question.choices.first { $0 != question.answer } ?? question.answer + 1
            return build(
                promptText: "\(question.groupCount) groups of \(question.itemsPerGroup) = ?",
                spokenPrompt: "\(question.groupCount) groups of \(question.itemsPerGroup). How many in total?",
                correct: "\(question.answer)",
                wrong: "\(wrong)"
            )

        case .sentenceBuild, .wordProblemStep, .letterTracing, .measurementTap:
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
