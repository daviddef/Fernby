import Foundation

/// "2, 4, 6, ___" — skip counting by 2s, 5s, or 10s. Sits between Addition
/// and Subtraction in the math chain since it still reasons about a single
/// growing sequence, not yet an operation between two numbers.
struct SkipCountingQuestion {
    let step: Int
    let sequence: [Int]
    let answer: Int
    let choices: [Int]
}

enum SkipCountingBank {
    static func random(forDifficulty level: Int) -> SkipCountingQuestion {
        let steps = level <= 1 ? [2, 10] : [2, 5, 10]
        let step = steps.randomElement()!
        let start = step * Int.random(in: 0...4)
        let sequence = (0..<3).map { start + step * $0 }
        let answer = start + step * 3
        // Off-by-one is the natural mistake here, so that's the distractor
        // shape, not a random far-off number.
        let choices = [answer - 1, answer, answer + 1].shuffled()
        return SkipCountingQuestion(step: step, sequence: sequence, answer: answer, choices: choices)
    }
}
