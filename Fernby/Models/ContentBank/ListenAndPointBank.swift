import Foundation

struct ListenPointOption: Identifiable {
    let id = UUID()
    let display: String
    let isTarget: Bool
}

struct ListenPointRound {
    let targetSpokenCue: String
    let options: [ListenPointOption]
}

/// Content for the audio-only bonus round — reuses PhonicsBank and
/// NumberBank exactly as their own activities do. Unlike every other
/// activity (see LetterSoundMatchView, which always shows the letter on
/// screen), here the target is never shown, only spoken — a pure
/// listening-comprehension check dressed as a game.
enum ListenAndPointBank {
    static func randomRound() -> ListenPointRound {
        Bool.random() ? phonicsRound() : numberRound()
    }

    private static func phonicsRound() -> ListenPointRound {
        let target = PhonicsBank.random()
        let decoys = PhonicsBank.decoys(excluding: target, count: 2)
        let options = ([target] + decoys).shuffled().map {
            ListenPointOption(display: $0.emoji, isTarget: $0.letter == target.letter)
        }
        return ListenPointRound(targetSpokenCue: target.sound, options: options)
    }

    private static func numberRound() -> ListenPointRound {
        let target = Int.random(in: 1...10)
        var decoys: [Int] = []
        for offset in [-2, -1, 1, 2].shuffled() {
            let candidate = target + offset
            guard candidate >= 1, candidate != target, !decoys.contains(candidate) else { continue }
            decoys.append(candidate)
            if decoys.count == 2 { break }
        }
        let options = ([target] + decoys).shuffled().map {
            ListenPointOption(display: "\($0)", isTarget: $0 == target)
        }
        return ListenPointRound(targetSpokenCue: NumberBank.word(for: target), options: options)
    }
}
