import SwiftUI

/// Seven bonus-round games with genuinely different mechanics. Previously
/// these only ever appeared as a random 1-of-7 pick at the very end of a
/// daily quest — meaning a game like Criss-Cross (crossword) or Letter
/// Scramble (anagram) surfaced only ~14% of the time, with no way to
/// deliberately choose it. A real founder complaint ("still no crosswords,
/// anagrams") turned out to trace back to this: the games existed but were
/// never discoverable. Promoted to a shared, `Identifiable` type so
/// ArcadeView can list all seven as an always-available, tap-to-play menu,
/// while DailyQuestView keeps using it for the end-of-quest surprise pick.
enum BonusGame: String, CaseIterable, Identifiable {
    case matching, sorting, listenAndPoint, wordExplorer, garden, letterScramble, crissCross

    var id: String { rawValue }

    var title: String {
        switch self {
        case .matching: return "Memory Match"
        case .sorting: return "Sort It Out"
        case .listenAndPoint: return "Listen and Point"
        case .wordExplorer: return "Word Explorer"
        case .garden: return "Grow a Garden"
        case .letterScramble: return "Letter Scramble"
        case .crissCross: return "Criss-Cross"
        }
    }

    var subtitle: String {
        switch self {
        case .matching: return "Flip cards, find pairs"
        case .sorting: return "Sort into the right bucket"
        case .listenAndPoint: return "Listen, then tap what you heard"
        case .wordExplorer: return "Discover a new word"
        case .garden: return "Plant and decorate"
        case .letterScramble: return "Unscramble the letters — an anagram!"
        case .crissCross: return "Fill in a mini crossword"
        }
    }

    var emoji: String {
        switch self {
        case .matching: return "🃏"
        case .sorting: return "🧺"
        case .listenAndPoint: return "👂"
        case .wordExplorer: return "🔍"
        case .garden: return "🌱"
        case .letterScramble: return "🔤"
        case .crissCross: return "✏️"
        }
    }

    /// Excludes `listenAndPoint`, which is audio-only by design (see
    /// ListenAndPointView) and becomes an unplayable dead end when voice is
    /// muted.
    static func eligible(voiceEnabled: Bool) -> [BonusGame] {
        voiceEnabled ? Array(allCases) : allCases.filter { $0 != .listenAndPoint }
    }
}

/// The single place that knows how to render a given bonus game — used by
/// both the end-of-quest surprise pick (DailyQuestView) and the always-open
/// Arcade (ArcadeView), so the two never drift out of sync.
struct BonusGameContainerView: View {
    let game: BonusGame
    let onDone: () -> Void

    var body: some View {
        switch game {
        case .matching:
            MatchingGameView(onDone: onDone)
        case .sorting:
            SortingGameView(onDone: onDone)
        case .listenAndPoint:
            ListenAndPointView(onDone: onDone)
        case .wordExplorer:
            WordExplorerView(onDone: onDone)
        case .garden:
            GardenView(onDone: onDone)
        case .letterScramble:
            LetterScrambleView(onDone: onDone)
        case .crissCross:
            CrissCrossView(onDone: onDone)
        }
    }
}
