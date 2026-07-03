import SwiftUI

/// Home screen. v0.1 ships a single biome — the world map grows to
/// multiple unlockable biomes in v0.2. Tapping the biome routes to
/// PlacementQuestView on first launch, DailyQuestView after that.
struct WorldMapView: View {
    private enum Flow: Identifiable {
        case placement
        case daily
        var id: Self { self }
    }

    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var presentedFlow: Flow?

    var body: some View {
        VStack(spacing: 36) {
            Text("Wonder Trail")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .padding(.top, 24)

            CompanionView(progressStore: progressStore, size: 160, showsName: true)

            BiomeNodeView(
                title: "Whispering Woods",
                emoji: "🌳",
                isLocked: false,
                isCurrent: true,
                action: startQuest
            )

            Spacer()
        }
        .padding()
        .fullScreenCover(item: $presentedFlow) { flow in
            switch flow {
            case .placement:
                PlacementQuestView(onComplete: { presentedFlow = nil })
            case .daily:
                DailyQuestView(onComplete: { presentedFlow = nil })
            }
        }
    }

    private func startQuest() {
        Haptics.shared.tap()
        if progressStore.activeProfile?.hasCompletedPlacement == true {
            presentedFlow = .daily
        } else {
            presentedFlow = .placement
        }
    }
}
