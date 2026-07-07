import SwiftUI

/// The trust layer: the same mastery and session data that drives the
/// companion, narrated in plain language instead of a chart. No account,
/// no server round-trip — everything here is read straight out of
/// ProgressStore and SessionLog, both of which live only on this device.
struct ParentDashboardView: View {
    @ObservedObject private var progressStore = ProgressStore.shared
    @ObservedObject private var sessionLog = SessionLog.shared

    private var learnedAbilities: [CompanionAbility] {
        SkillGraph.all
            .filter { progressStore.progress(for: $0.id).mastered }
            .compactMap { CompanionAbilityCatalog.ability(for: $0.id) }
    }

    private var recentSessions: [SessionEntry] {
        Array(sessionLog.entries.reversed().prefix(10))
    }

    var body: some View {
        List {
            Section {
                summaryText
                    .font(.system(size: 16))
                    .padding(.vertical, 4)
            } header: {
                Text("What \(CompanionAbilityCatalog.companionName) Has Learned")
            }

            if !recentSessions.isEmpty {
                Section("Recent Quests") {
                    ForEach(recentSessions) { entry in
                        sessionRow(entry)
                    }
                }
            }

            Section {
                Text("Everything here — quest progress, mastery, session history — lives only on this device. Nothing is sent anywhere, and it can be deleted any time from Settings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Privacy")
            }
        }
        .navigationTitle("\(CompanionAbilityCatalog.companionName)'s Progress")
    }

    @ViewBuilder
    private var summaryText: some View {
        if learnedAbilities.isEmpty {
            Text("\(CompanionAbilityCatalog.companionName) hasn't learned anything yet — finish a quest together to get started.")
                .foregroundStyle(.secondary)
        } else {
            Text("So far, \(CompanionAbilityCatalog.companionName) has learned to \(learnedAbilities.map(\.verb).formattedList()).")
        }
    }

    private func sessionRow(_ entry: SessionEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 15, weight: .semibold))
                Text(durationText(entry.durationSeconds))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(entry.correctCount)/\(entry.totalCount) correct")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private func durationText(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds.rounded())
        if totalSeconds < 60 { return "\(totalSeconds)s" }
        return "\(totalSeconds / 60)m \(totalSeconds % 60)s"
    }
}
