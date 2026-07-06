import Foundation

/// A single completed quest, logged for on-device debrief only. No name, no
/// profile identifier, no free text — just enough to reconstruct "what did a
/// test session look like" without collecting anything that identifies the
/// child. Never leaves the device; there is no server for it to go to.
struct SessionEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let nodeIDs: [String]
    let correctCount: Int
    let totalCount: Int
    let durationSeconds: Double

    init(nodeIDs: [String], correctCount: Int, totalCount: Int, durationSeconds: Double) {
        self.id = UUID()
        self.date = Date()
        self.nodeIDs = nodeIDs
        self.correctCount = correctCount
        self.totalCount = totalCount
        self.durationSeconds = durationSeconds
    }
}

/// On-device-only history of completed quests, for playtest debriefs and the
/// parent view. Capped at a rolling window so it never grows unbounded in
/// UserDefaults, and fully deletable in one call from Settings.
@MainActor
final class SessionLog: ObservableObject {
    static let shared = SessionLog()

    private static let key = "wt.sessionLog"
    private static let maxEntries = 60

    @Published private(set) var entries: [SessionEntry]

    private init() {
        entries = Self.load()
    }

    func record(_ entry: SessionEntry) {
        entries.append(entry)
        if entries.count > Self.maxEntries {
            entries.removeFirst(entries.count - Self.maxEntries)
        }
        persist()
    }

    func deleteAll() {
        entries = []
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    private static func load() -> [SessionEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SessionEntry].self, from: data) else { return [] }
        return decoded
    }
}
