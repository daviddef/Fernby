import Foundation

/// Single source of truth for everything that survives between launches:
/// learner profile(s), per-node mastery progress, and companion growth.
/// Adapted from Duck-n-Roll's GameState.swift (UserDefaults, namespaced
/// keys, auto-persist on change) but upgraded to ObservableObject/@Published
/// because SwiftUI views here — the world map, the companion — need
/// reactive updates that GameState's SpriteKit consumer didn't require.
@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let profiles = "wt.profiles"
        static let activeProfileID = "wt.activeProfileID"
        static let nodeProgress = "wt.nodeProgress"
        static let companion = "wt.companion"
    }

    @Published var profiles: [LearnerProfile] {
        didSet { persist(profiles, forKey: Key.profiles) }
    }
    @Published var activeProfileID: UUID {
        didSet { defaults.set(activeProfileID.uuidString, forKey: Key.activeProfileID) }
    }
    @Published var nodeProgress: [String: NodeProgress] {
        didSet { persist(nodeProgress, forKey: Key.nodeProgress) }
    }
    @Published var companion: CompanionState {
        didSet { persist(companion, forKey: Key.companion) }
    }

    private init() {
        let loadedProfiles: [LearnerProfile] = Self.load(forKey: Key.profiles, from: defaults) ?? []
        if let first = loadedProfiles.first {
            profiles = loadedProfiles
            activeProfileID = UUID(uuidString: defaults.string(forKey: Key.activeProfileID) ?? "") ?? first.id
        } else {
            let defaultProfile = LearnerProfile(displayName: "Explorer", createdAt: Date())
            profiles = [defaultProfile]
            activeProfileID = defaultProfile.id
        }
        nodeProgress = Self.load(forKey: Key.nodeProgress, from: defaults) ?? [:]
        companion = Self.load(forKey: Key.companion, from: defaults) ?? CompanionState()
    }

    var activeProfile: LearnerProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    func progress(for nodeID: String) -> NodeProgress {
        nodeProgress[nodeID] ?? NodeProgress(nodeID: nodeID)
    }

    func update(_ progress: NodeProgress) {
        nodeProgress[progress.nodeID] = progress
    }

    /// Retroactively mark a node complete without going through the
    /// difficulty engine — used by PlacementEngine to skip material a child
    /// already knows.
    func markMastered(nodeID: String) {
        var progress = progress(for: nodeID)
        progress.mastered = true
        progress.masteredAt = Date()
        update(progress)
    }

    func markPlacementCompleted() {
        guard let index = profiles.firstIndex(where: { $0.id == activeProfileID }) else { return }
        profiles[index].hasCompletedPlacement = true
    }

    /// Wipes learning progress and companion growth for the active profile —
    /// used by Settings' "Delete data on this device" control, and handy for
    /// resetting between playtest children on a shared test device. Does not
    /// touch the profile's name/id, only what it has done.
    func resetActiveProfileData() {
        nodeProgress = [:]
        companion = CompanionState()
        if let index = profiles.firstIndex(where: { $0.id == activeProfileID }) {
            profiles[index].hasCompletedPlacement = false
        }
    }

    func recordActivityCompleted() {
        companion.totalActivitiesCompleted += 1
        companion.daysPlayed.insert(Self.todayKey())
    }

    /// The node a daily quest should serve next for a subject: the first
    /// non-mastered node *among nodes with a shipped activity*. Placement
    /// still reasons about the full chain (SkillGraph.node(after:)), but
    /// content selection must stay within what v0.1 actually built, or a
    /// child would get routed to a node with no activity view at all.
    func currentNode(for subject: Subject) -> SkillNode {
        let playableChain = SkillGraph.chain(for: subject).filter { SkillGraph.playableIDs.contains($0.id) }
        return playableChain.first { !progress(for: $0.id).mastered }
            ?? playableChain.last
            ?? SkillGraph.chain(for: subject).first!
    }

    // MARK: - Persistence helpers

    private func persist<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func load<T: Decodable>(forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
