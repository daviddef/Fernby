import SwiftUI

/// What the companion has "learned" is never separate data to keep in sync
/// — it's read straight off NodeProgress.mastered, so this list can never
/// show the companion knowing something the child hasn't actually done.
struct CompanionJournalView: View {
    @ObservedObject var progressStore: ProgressStore

    @State private var showingWardrobe = false

    private var learnedAbilities: [CompanionAbility] {
        SkillGraph.all
            .filter { progressStore.progress(for: $0.id).mastered }
            .compactMap { CompanionAbilityCatalog.ability(for: $0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if learnedAbilities.isEmpty {
                    VStack(spacing: 16) {
                        CompanionView(progressStore: progressStore, size: 120)
                        Text("\(CompanionAbilityCatalog.companionName) is just getting started!")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Text("Finish a quest to teach \(CompanionAbilityCatalog.companionName) something new.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(learnedAbilities, id: \.nodeID) { ability in
                        Label {
                            Text("\(CompanionAbilityCatalog.companionName) can \(ability.verb)")
                        } icon: {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .navigationTitle("\(CompanionAbilityCatalog.companionName)'s Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWardrobe = true
                    } label: {
                        Image(systemName: "tshirt.fill")
                    }
                    .accessibilityLabel("Dress up \(CompanionAbilityCatalog.companionName)")
                }
            }
            .sheet(isPresented: $showingWardrobe) {
                CompanionWardrobeView(progressStore: progressStore, onDismiss: { showingWardrobe = false })
            }
        }
    }
}
