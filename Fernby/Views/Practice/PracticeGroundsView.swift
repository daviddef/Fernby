import SwiftUI

/// The unbounded half of "somewhere to go once today's quest is done" (see
/// the roadmap's two-engine strategy) — every node the child has actually
/// already met, playable again with no mastery tracking, no streak, no
/// first-attempt scoring. Nothing here can be "won" or "finished"; it's
/// closer to re-reading a favorite book than doing homework again.
struct PracticeGroundsView: View {
    let onDismiss: () -> Void

    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var selectedNode: SkillNode?

    /// Only nodes the child has actually encountered — mastered, or
    /// currently in progress. Never a node they haven't reached yet; that
    /// would just be the quest with extra steps, not "practice."
    private var availableNodes: [SkillNode] {
        SkillGraph.all.filter { node in
            guard SkillGraph.playableIDs.contains(node.id) else { return false }
            let progress = progressStore.progress(for: node.id)
            return progress.mastered || progress.totalAttempts > 0
        }
    }

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                if availableNodes.isEmpty {
                    Text("Finish a quest first, then come back to practice anything you've learned!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 60)
                        .padding(.horizontal, 32)
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(availableNodes) { node in
                            Button {
                                Haptics.shared.tap()
                                selectedNode = node
                            } label: {
                                VStack(spacing: 8) {
                                    Text(node.subject == .reading ? "📖" : "🔢")
                                        .font(.system(size: 34))
                                    Text(node.title)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.accentColor.opacity(0.16))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Practice Grounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                }
            }
        }
        .fullScreenCover(item: $selectedNode) { node in
            PracticeSessionView(node: node, onDone: { selectedNode = nil })
        }
    }
}
