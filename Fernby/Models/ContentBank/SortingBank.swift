import Foundation

struct SortItem: Identifiable {
    let id = UUID()
    let display: String
    let spokenForm: String
    let belongsLeft: Bool
}

struct SortRound {
    let prompt: String
    let leftLabel: String
    let rightLabel: String
    let items: [SortItem]
}

/// Content for the sort-into-buckets bonus round — reuses PhonicsBank and
/// NumberBank exactly as their own activities do, so sorting never tests
/// material outside the normal quest loop. Two themes, picked randomly, like
/// MatchGameBank.
enum SortingBank {
    static func randomRound() -> SortRound {
        Bool.random() ? numberRound() : letterRound()
    }

    private static func numberRound() -> SortRound {
        let items = Array(1...10).shuffled().prefix(5).map {
            SortItem(display: "\($0)", spokenForm: NumberBank.word(for: $0), belongsLeft: $0 <= 5)
        }
        return SortRound(
            prompt: "Tap the bucket where each number belongs.",
            leftLabel: "Small\n1–5",
            rightLabel: "Big\n6–10",
            items: items
        )
    }

    private static func letterRound() -> SortRound {
        let vowels: Set<String> = ["a", "e", "i", "o", "u"]
        let items = PhonicsBank.all.shuffled().map { entry in
            SortItem(display: entry.letter.uppercased(), spokenForm: "the letter \(entry.letter)", belongsLeft: vowels.contains(entry.letter))
        }
        return SortRound(
            prompt: "Tap the bucket — is it a vowel or a consonant?",
            leftLabel: "Vowel",
            rightLabel: "Consonant",
            items: items
        )
    }
}
