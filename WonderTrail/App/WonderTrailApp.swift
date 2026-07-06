import SwiftUI

@main
struct WonderTrailApp: App {
    init() {
        #if DEBUG
        DebugSeed.applyIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

#if DEBUG
/// Manual-QA seeding hook, launch-argument gated so it can never fire in a
/// release build or by accident. Lets a tester jump straight to any node
/// (e.g. the ones DailyQuestView would otherwise take a dozen correct
/// answers to reach) without fighting cfprefsd's preferences cache by
/// editing UserDefaults' backing plist directly.
///
/// Usage: launch with env var WT_SEED_UNMASTERED set to a comma-separated
/// list of node ids to leave unmastered (everything else in both chains is
/// marked mastered at max difficulty), e.g. "reading.sentences,math.wordProblems".
enum DebugSeed {
    @MainActor
    static func applyIfRequested() {
        guard let raw = ProcessInfo.processInfo.environment["WT_SEED_UNMASTERED"] else { return }
        let unmasteredIDs = Set(raw.split(separator: ",").map(String.init))

        for node in SkillGraph.all {
            var progress = NodeProgress(nodeID: node.id)
            if unmasteredIDs.contains(node.id) {
                progress.difficultyLevel = 1
            } else {
                progress.difficultyLevel = DifficultyEngine.maxDifficulty
                progress.mastered = true
                progress.masteredAt = Date()
            }
            ProgressStore.shared.update(progress)
        }
        if let index = ProgressStore.shared.profiles.firstIndex(where: { $0.id == ProgressStore.shared.activeProfileID }) {
            ProgressStore.shared.profiles[index].hasCompletedPlacement = true
        }
    }
}
#endif
