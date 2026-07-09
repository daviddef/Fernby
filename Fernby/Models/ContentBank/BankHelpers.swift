import Foundation

/// Shared random/decoy logic for content banks shaped as a plain array of
/// items with a stable string key — factored out once several banks
/// (PhonicsBank + DigraphBank, WordBuildingBank + BlendWordBank +
/// DigraphWordBank, SightWordBank + SightWordAdvancedBank) started
/// repeating the identical "avoid recent, else random / decoys excluding
/// target" shape.
extension Array where Element == LetterSoundEntry {
    func random(avoiding recent: Set<String> = []) -> LetterSoundEntry {
        let pool = filter { !recent.contains($0.letter) }
        return (pool.isEmpty ? self : pool).randomElement()!
    }

    func decoys(excluding target: LetterSoundEntry, count: Int) -> [LetterSoundEntry] {
        Array(filter { $0.letter != target.letter }.shuffled().prefix(count))
    }
}

extension Array where Element == BuildableWord {
    func random(avoiding recent: Set<String> = []) -> BuildableWord {
        let pool = filter { !recent.contains($0.word) }
        return (pool.isEmpty ? self : pool).randomElement()!
    }

    func decoys(excluding target: BuildableWord, count: Int) -> [BuildableWord] {
        Array(filter { $0.word != target.word }.shuffled().prefix(count))
    }
}

extension Array where Element == String {
    func randomWord(avoiding recent: Set<String> = []) -> String {
        let pool = filter { !recent.contains($0) }
        return (pool.isEmpty ? self : pool).randomElement()!
    }

    func decoyWords(excluding target: String, count: Int) -> [String] {
        Array(filter { $0 != target }.shuffled().prefix(count))
    }
}
