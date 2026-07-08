import SwiftUI

@main
struct FernbyApp: App {
    init() {
        #if DEBUG
        DebugSeed.applyIfRequested()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // Every color in this app — the accent peach, the
                // correct/wrong green and rose-red, the low-opacity card
                // tints in MatchingGameView — was chosen and verified only
                // against a light background. Nothing here has ever been
                // designed or tested for Dark Mode; a real bug report
                // showed matched/unmatched cards collapsing toward
                // near-black and reading as completely unresponsive when
                // the system was in Dark Mode. Forcing light appearance
                // keeps every already-verified screen exactly as tested,
                // regardless of the device's system appearance, Night
                // Shift, or Sleep Focus schedule. Revisit if Dark Mode
                // support is ever deliberately designed, not patched in
                // piecemeal per-view.
                .preferredColorScheme(.light)
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
