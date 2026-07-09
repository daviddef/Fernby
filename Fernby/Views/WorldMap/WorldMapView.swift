import SwiftUI

/// Home screen — a winding trail of five biomes, each a real gate on the
/// skill graph (see Biome.swift), not five identical circles. The zigzag
/// layout and dotted connectors are what make it read as a trail worth
/// walking rather than a list worth scrolling past.
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
    @State private var showingPracticeGrounds = false
    @State private var exploringBiome: Biome?
    @State private var returnGreeting: String?

    private var unlockedBiomesInOrder: [Biome] {
        Biome.all.filter { $0.isUnlocked(progressStore) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Fernby")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .padding(.top, 24)

                if let returnGreeting {
                    Text(returnGreeting)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }

                Button {
                    Haptics.shared.tap()
                    showingJournal = true
                } label: {
                    CompanionView(progressStore: progressStore, size: 150, showsName: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Double tap to see what your companion has learned.")

                trail
                    .padding(.top, 8)

                Spacer(minLength: 24)
            }
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Haptics.shared.tap()
                    showingPracticeGrounds = true
                } label: {
                    Image(systemName: "gamecontroller.fill")
                }
                .accessibilityLabel("Practice Grounds")
            }
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
        .fullScreenCover(isPresented: $showingPracticeGrounds) {
            PracticeGroundsView(onDismiss: { showingPracticeGrounds = false })
        }
        .sheet(item: $exploringBiome) { biome in
            BiomeExploreView(biome: biome, onDone: { exploringBiome = nil })
        }
        .onAppear { showReturnGreetingIfNeeded() }
    }

    private func showReturnGreetingIfNeeded() {
        guard returnGreeting == nil, let greeting = GreetingBank.forReturningVisit(
            daysPlayed: progressStore.companion.daysPlayed,
            totalActivitiesCompleted: progressStore.companion.totalActivitiesCompleted
        ) else { return }
        withAnimation { returnGreeting = greeting }
        Voice.shared.speak(greeting, interrupt: false)
    }

    private var trail: some View {
        VStack(spacing: 0) {
            ForEach(Array(Biome.all.enumerated()), id: \.element.id) { index, biome in
                let isUnlocked = biome.isUnlocked(progressStore)
                biomeRow(biome, isUnlocked: isUnlocked, leansLeft: index % 2 == 0)

                if index < Biome.all.count - 1 {
                    trailConnector(isActive: isUnlocked)
                }
            }
        }
    }

    private func biomeRow(_ biome: Biome, isUnlocked: Bool, leansLeft: Bool) -> some View {
        HStack {
            if !leansLeft { Spacer(minLength: 40) }
            ZStack(alignment: .topTrailing) {
                BiomeNodeView(
                    title: biome.title,
                    emoji: biome.emoji,
                    accentColor: biome.accentColor,
                    isLocked: !isUnlocked,
                    isCurrent: isUnlocked && biome.id == unlockedBiomesInOrder.last?.id,
                    action: { startQuest() }
                )
                if isUnlocked {
                    Button {
                        Haptics.shared.tap()
                        exploringBiome = biome
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(biome.accentColor)
                            .background(Circle().fill(.white))
                    }
                    .offset(x: -2, y: 4)
                    .accessibilityLabel("Explore \(biome.title)")
                }
            }
            if leansLeft { Spacer(minLength: 40) }
        }
    }

    private func trailConnector(isActive: Bool) -> some View {
        VStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(isActive ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.18))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 34)
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
