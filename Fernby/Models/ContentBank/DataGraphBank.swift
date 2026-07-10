import Foundation

/// Reading a simple picture graph — the Grade 1-2 CCSS data skill. Two
/// question shapes, picked at random: reading a single category's count
/// straight off the graph, or comparing categories (which has the most/
/// fewest) — the second is the real "data literacy" half of this skill,
/// not just counting.
struct DataCategory: Identifiable {
    let id = UUID()
    let emoji: String
    let count: Int
}

struct DataGraphQuestion {
    let categories: [DataCategory]
    let promptText: String
    let spokenPrompt: String
    let answer: String
    let choices: [String]
}

enum DataGraphBank {
    private static let emojiPool = ["🍎", "🍌", "🍇", "🐶", "🐱", "🐟", "⚽️", "🏀", "🎈"]

    static func random() -> DataGraphQuestion {
        let chosenEmoji = emojiPool.shuffled().prefix(3)
        var counts = Set<Int>()
        while counts.count < 3 {
            counts.insert(Int.random(in: 1...6))
        }
        let countList = Array(counts)
        let categories = zip(chosenEmoji, countList).map { DataCategory(emoji: $0, count: $1) }

        if Bool.random() {
            // "How many X are there?"
            let target = categories.randomElement()!
            let correct = "\(target.count)"
            var decoys: [String] = []
            for other in categories where other.emoji != target.emoji {
                decoys.append("\(other.count)")
            }
            let choices = ([correct] + decoys.prefix(2)).shuffled()
            return DataGraphQuestion(
                categories: categories,
                promptText: "How many \(target.emoji) are there?",
                spokenPrompt: "How many are there?",
                answer: correct,
                choices: choices
            )
        } else {
            // "Which has the most / fewest?"
            let wantsMost = Bool.random()
            let extreme = wantsMost ? categories.max(by: { $0.count < $1.count })! : categories.min(by: { $0.count < $1.count })!
            let choices = categories.map(\.emoji).shuffled()
            return DataGraphQuestion(
                categories: categories,
                promptText: wantsMost ? "Which has the most?" : "Which has the fewest?",
                spokenPrompt: wantsMost ? "Which has the most?" : "Which has the fewest?",
                answer: extreme.emoji,
                choices: choices
            )
        }
    }
}
