import Foundation

/// On-device shelf of every story a child has generated — the difference
/// between "another quiz screen" and something a family can keep, reread,
/// and show off, which is exactly the gap the "wow" research pointed to
/// (see StoryWeaver's doc comment). Persisted the same way SessionLog is:
/// a capped rolling window in UserDefaults, nothing that ever leaves the
/// device.
@MainActor
final class StoryLibrary: ObservableObject {
    static let shared = StoryLibrary()

    private static let key = "wt.storyLibrary"
    /// Generous relative to SessionLog's 60 — stories are meant to
    /// accumulate as a keepsake shelf, not roll off quickly.
    private static let maxEntries = 40

    @Published private(set) var stories: [Story]

    private init() {
        stories = Self.load()
    }

    /// Newest first — the shelf reads top-to-bottom as "most recent story
    /// first," matching how the Storybook home always offers "today's new
    /// story" before older ones.
    var storiesNewestFirst: [Story] {
        stories.sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ story: Story) {
        stories.append(story)
        if stories.count > Self.maxEntries {
            stories.removeFirst(stories.count - Self.maxEntries)
        }
        persist()
    }

    func deleteAll() {
        stories = []
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(stories) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    private static func load() -> [Story] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Story].self, from: data) else { return [] }
        return decoded
    }
}
