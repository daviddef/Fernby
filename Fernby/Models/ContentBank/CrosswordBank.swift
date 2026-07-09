import Foundation

/// Two already-known words that cross at one shared letter — the simplest
/// possible crossword shape, matching how real K-1 "picture crosswords"
/// work: tiny grids, picture clues instead of text clues, letters chosen
/// from a bank rather than freely spelled. `acrossIndex`/`downIndex` are
/// the position within each word where they share a letter.
struct CrosswordPuzzle {
    let across: BuildableWord
    let down: BuildableWord
    let acrossIndex: Int
    let downIndex: Int
}

enum CrosswordBank {
    /// Searches the existing word banks for any pair that shares a letter
    /// (or, for words that include a digraph as one grapheme-token, the
    /// same grapheme) at some position in each — no new vocabulary, purely
    /// a new arrangement of words the child already knows.
    static func randomPuzzle() -> CrosswordPuzzle? {
        let pool = WordBuildingBank.all + BlendWordBank.all + DigraphWordBank.all
        var candidates: [CrosswordPuzzle] = []

        for across in pool {
            for down in pool where down.word != across.word {
                for (i, acrossLetter) in across.letters.enumerated() {
                    for (j, downLetter) in down.letters.enumerated() {
                        guard acrossLetter == downLetter else { continue }
                        candidates.append(CrosswordPuzzle(across: across, down: down, acrossIndex: i, downIndex: j))
                    }
                }
            }
        }

        return candidates.randomElement()
    }
}
