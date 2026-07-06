import SwiftUI

/// Home screen. Every biome currently opens the same reading/math quest pool
/// (see Biome.swift) — the map itself is the thing being tested for whether
/// visible unlockable places pull a second session, ahead of biome-specific
/// content existing to back it up.
struct WorldMapView: View {
    private enum Flow: Identifiable {
        case placement
        case daily
        var id: Self { self }
    }

    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var presentedFlow: Flow?
    @State private var showingParentGate = false
    @State private var showingSettings = false
    @State private var showingJournal = false

    private var unlockedBiomesInOrder: [Biome] {
        Biome.all.filter { $0.isUnlocked(progressStore) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                Text("Fernby")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .padding(.top, 24)

                Button {
                    Haptics.shared.tap()
                    showingJournal = true
                } label: {
                    CompanionView(progressStore: progressStore, size: 160, showsName: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Double tap to see what your companion has learned.")

                VStack(spacing: 24) {
                    ForEach(Biome.all) { biome in
                        let isUnlocked = biome.isUnlocked(progressStore)
                        BiomeNodeView(
                            title: biome.title,
                            emoji: biome.emoji,
                            isLocked: !isUnlocked,
                            isCurrent: isUnlocked && biome.id == unlockedBiomesInOrder.last?.id,
                            action: { startQuest() }
                        )
                    }
                }

                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingParentGate = true
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .accessibilityLabel("Settings, grown-ups only")
            }
        }
        .fullScreenCover(item: $presentedFlow) { flow in
            switch flow {
            case .placement:
                PlacementQuestView(onComplete: { presentedFlow = nil })
            case .daily:
                DailyQuestView(onComplete: { presentedFlow = nil })
            }
        }
        .sheet(isPresented: $showingParentGate) {
            ParentGateView(
                onPassed: {
                    showingParentGate = false
                    showingSettings = true
                },
                onCancel: { showingParentGate = false }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(onDismiss: { showingSettings = false })
        }
        .sheet(isPresented: $showingJournal) {
            CompanionJournalView(progressStore: progressStore)
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
