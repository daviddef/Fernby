import Foundation

/// One placed decoration — position stored as a 0...1 fraction of the
/// canvas so it replots correctly regardless of device size.
struct GardenItem: Codable, Identifiable, Equatable {
    let id: UUID
    let emoji: String
    var x: Double
    var y: Double
}

/// Persists the child's garden the same way ProgressStore persists
/// everything else (UserDefaults, auto-save on change) — a creative space
/// that stays exactly as they left it is the point; there is no "reset"
/// or "score" here to speak of.
@MainActor
final class GardenStore: ObservableObject {
    static let shared = GardenStore()

    /// Generous but bounded, purely so a years-long install can't grow the
    /// persisted blob without limit — not a gameplay constraint a child
    /// would ever realistically hit.
    private static let maxItems = 80

    private let defaults = UserDefaults.standard
    private let key = "wt.gardenItems"

    @Published var items: [GardenItem] {
        didSet { persist() }
    }

    private init() {
        items = Self.load(from: defaults, key: key) ?? []
    }

    func add(emoji: String, x: Double, y: Double) {
        items.append(GardenItem(id: UUID(), emoji: emoji, x: x, y: y))
        if items.count > Self.maxItems {
            items.removeFirst(items.count - Self.maxItems)
        }
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [GardenItem]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode([GardenItem].self, from: data)
    }
}
