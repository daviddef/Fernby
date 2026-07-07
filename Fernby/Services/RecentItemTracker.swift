import Foundation

/// Tracks the most recently shown item per content pool, in memory only
/// (resets on relaunch — this is about immediate freshness, not a
/// persisted history). Every small, fixed content bank (PhonicsBank's 6
/// letters, WordBuildingBank's 7 words, SightWordBank's 10 words) already
/// supported an `avoiding:` parameter, but nothing ever populated it —
/// true randomness with replacement can show the same letter twice in a
/// row, and now that a quest repeats each node multiple times (see
/// DailyQuestView), that got more noticeable, not less. People read
/// "genuinely random" as repetitive; avoiding just the immediately-previous
/// item is what makes shuffled content actually feel varied, the same fix
/// every music-shuffle algorithm makes for the same reason.
@MainActor
final class RecentItemTracker {
    static let shared = RecentItemTracker()

    private var lastShown: [String: String] = [:]

    private init() {}

    func recent(for key: String) -> Set<String> {
        lastShown[key].map { Set([$0]) } ?? []
    }

    func record(_ item: String, for key: String) {
        lastShown[key] = item
    }
}
