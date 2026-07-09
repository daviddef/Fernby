import SwiftUI

/// Once a biome is unlocked, it becomes a small explorable scene instead of
/// just a finished circle on the trail — a few tappable ambient details,
/// no reading/math gating, nothing to get wrong. Purely "look around the
/// place you built."
struct BiomeExploreView: View {
    let biome: Biome
    let onDone: () -> Void

    @State private var wigglingIndex: Int?

    private var details: [BiomeExploreDetail] { BiomeExploreBank.details(for: biome.id) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                Circle()
                    .fill(biome.accentColor.opacity(0.25))
                    .frame(width: 160, height: 160)
                    .overlay(Text(biome.emoji).font(.system(size: 76)))
                    .padding(.top, 20)

                Text("Tap around to see what's here!")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 28) {
                    ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                        Button {
                            tap(index, detail)
                        } label: {
                            Text(detail.emoji)
                                .font(.system(size: 52))
                                .scaleEffect(wigglingIndex == index ? 1.35 : 1.0)
                                .rotationEffect(.degrees(wigglingIndex == index ? 14 : 0))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Explore \(biome.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDone() }
                }
            }
        }
    }

    private func tap(_ index: Int, _ detail: BiomeExploreDetail) {
        Haptics.shared.tap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            wigglingIndex = index
        }
        Voice.shared.speak(detail.line, interrupt: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { wigglingIndex = nil }
        }
    }
}
