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
            #if DEBUG
            debugRoot
                .preferredColorScheme(.light)
            #else
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
            #endif
        }
    }

    #if DEBUG
    /// Manual-QA hook: launch with env var WT_DEBUG_NODE set to any skill
    /// node id (e.g. "math.shapes") to jump straight into that node's
    /// activity view, bypassing the world map, placement, and quest flow
    /// entirely. Used to screenshot-verify each new node's activity view
    /// in isolation without playing through the whole chain to reach it.
    @ViewBuilder
    private var debugRoot: some View {
        if let nodeID = ProcessInfo.processInfo.environment["WT_DEBUG_NODE"], let node = SkillGraph.node(id: nodeID) {
            ActivityContainerView(node: node, instanceID: 0, onFirstResponse: { _ in }, onAdvance: {})
        } else if let screen = ProcessInfo.processInfo.environment["WT_DEBUG_SCREEN"] {
            debugScreen(screen)
        } else {
            RootView()
        }
    }

    /// Same idea as WT_DEBUG_NODE, for screens that aren't a single skill
    /// node: WT_DEBUG_SCREEN=practice|wardrobe|wordExplorer|garden|explore|
    /// scramble|crissCross|settings|dashboard|phonicsPreview|journal|
    /// questSummary|coachMoment|arcade|storybook jumps straight to that
    /// surface, bypassing however many quests it would otherwise take to
    /// reach it normally.
    @ViewBuilder
    private func debugScreen(_ name: String) -> some View {
        switch name {
        case "practice": PracticeGroundsView(onDismiss: {})
        case "wardrobe": CompanionWardrobeView(progressStore: .shared, onDismiss: {})
        case "wordExplorer": WordExplorerView(onDone: {})
        case "garden": GardenView(onDone: {})
        case "explore": BiomeExploreView(biome: Biome.all[0], onDone: {})
        case "scramble": LetterScrambleView(onDone: {})
        case "crissCross": CrissCrossView(onDone: {})
        case "settings": SettingsView(onDismiss: {})
        case "dashboard": ParentDashboardView()
        case "phonicsPreview": PhonicsPreviewView()
        case "journal": CompanionJournalView(progressStore: .shared)
        case "questSummary":
            QuestSummaryView(
                correctCount: 5, totalCount: 6,
                masteredNodeTitles: ["Letter Sounds"],
                justCompletedBiomes: [Biome.all[1]],
                onDone: {}
            )
        case "coachMoment": CoachMomentView(node: SkillGraph.all[1], onDone: {})
        case "parentGate": ParentGateView(onPassed: {}, onCancel: {})
        case "placement": PlacementQuestView(onComplete: {})
        case "arcade": ArcadeView(onDismiss: {})
        case "storybook": StorybookView(onDismiss: {})
        default: RootView()
        }
    }
    #endif
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
