import SwiftUI

/// Every accessory is earned by a deterministic activities-completed
/// threshold, shown up front rather than as a surprise — the guardrail
/// checklist's "every reward is visible and explained before it's earned."
/// Nothing here is randomized, purchasable, or ever presented as a
/// "mystery" unlock.
struct CompanionWardrobeView: View {
    @ObservedObject var progressStore: ProgressStore
    let onDismiss: () -> Void

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 14)]

    private var totalActivitiesCompleted: Int {
        progressStore.companion.totalActivitiesCompleted
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    CompanionView(progressStore: progressStore, size: 150)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(CompanionAccessory.allCases) { accessory in
                            accessoryTile(accessory)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Dress Up \(CompanionAbilityCatalog.companionName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                }
            }
        }
    }

    private func accessoryTile(_ accessory: CompanionAccessory) -> some View {
        let isUnlocked = accessory.isUnlocked(totalActivitiesCompleted: totalActivitiesCompleted)
        let isSelected = progressStore.companion.selectedAccessory == accessory

        return Button {
            guard isUnlocked else { return }
            Haptics.shared.tap()
            progressStore.companion.selectedAccessory = accessory
        } label: {
            VStack(spacing: 6) {
                Text(accessory.emoji ?? "🚫")
                    .font(.system(size: 34))
                    .opacity(isUnlocked ? 1 : 0.3)
                Text(accessory.displayName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(isUnlocked ? .primary : .secondary)
                if !isUnlocked {
                    Text("At \(accessory.unlockThreshold) activities")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.fernbyCorrect.opacity(0.2) : Color.accentColor.opacity(isUnlocked ? 0.16 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.fernbyCorrect : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
        .accessibilityLabel(isUnlocked ? accessory.displayName : "\(accessory.displayName), locked until \(accessory.unlockThreshold) activities")
    }
}
