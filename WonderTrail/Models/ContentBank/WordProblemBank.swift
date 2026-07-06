import Foundation

struct WordProblem: Equatable {
    let fact: MathFact
    let scenario: String
}

/// The last node in the math chain, and the point of the whole chain: the
/// same facts from MathFactBank, now wrapped in a one-sentence scenario, so
/// the skill being checked is translating words into an operation, not the
/// arithmetic itself (already proven by the nodes before this one).
enum WordProblemBank {
    private static let addNouns = ["apples", "stickers", "shells", "blocks", "grapes"]
    private static let subtractNouns = ["cookies", "balloons", "marbles", "leaves", "coins"]

    static func randomProblem(forDifficulty level: Int) -> WordProblem {
        let operation: MathOperation = Bool.random() ? .add : .subtract
        let fact = MathFactBank.randomFact(forDifficulty: level, operation: operation)

        switch operation {
        case .add:
            let noun = addNouns.randomElement()!
            return WordProblem(
                fact: fact,
                scenario: "You have \(fact.a) \(noun). You find \(fact.b) more. How many \(noun) now?"
            )
        case .subtract:
            let noun = subtractNouns.randomElement()!
            return WordProblem(
                fact: fact,
                scenario: "You have \(fact.a) \(noun). You give away \(fact.b). How many \(noun) are left?"
            )
        }
    }
}
