import SwiftUI

/// Bonus round — Toca-Boca-style open-ended creative play: no goal, no
/// score, no failure state. Pick a decoration, tap the garden to place it,
/// tap a placed decoration to remove it. The palette is free for everyone
/// (unlike the companion's earned wardrobe) since this is meant as pure
/// unstructured play, not a milestone reward. Persists across sessions via
/// GardenStore, so it stays a real creative space, not a disposable canvas.
struct GardenView: View {
    let onDone: () -> Void

    @ObservedObject private var gardenStore = GardenStore.shared
    @State private var selectedEmoji: String = "🌸"

    private let palette = ["🌸", "🌼", "🌻", "🍄", "🪨", "🦋", "🐌", "⭐️"]
    private let paletteNames: [String: String] = [
        "🌸": "Cherry blossom", "🌼": "Daisy", "🌻": "Sunflower", "🍄": "Mushroom",
        "🪨": "Rock", "🦋": "Butterfly", "🐌": "Snail", "⭐️": "Star",
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Decorate Fern's Garden")
                .font(.system(size: 22, weight: .heavy, design: .rounded))

            canvas

            paletteRow

            Button("Done") { onDone() }
                .buttonStyle(.bigTap)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Voice.shared.speak("Pick something and tap the garden to decorate it!", interrupt: true)
        }
    }

    private var canvas: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(red: 0.87, green: 0.93, blue: 0.82))

                ForEach(gardenStore.items) { item in
                    Text(item.emoji)
                        .font(.system(size: 34))
                        .position(x: item.x * geo.size.width, y: item.y * geo.size.height)
                        .onTapGesture {
                            Haptics.shared.tap()
                            gardenStore.remove(id: item.id)
                        }
                        .accessibilityLabel("\(paletteNames[item.emoji] ?? "Decoration") in the garden")
                        .accessibilityHint("Double tap to remove")
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let x = min(max(value.location.x / geo.size.width, 0.05), 0.95)
                        let y = min(max(value.location.y / geo.size.height, 0.05), 0.95)
                        Haptics.shared.tap()
                        gardenStore.add(emoji: selectedEmoji, x: x, y: y)
                    }
            )
        }
        .frame(height: 300)
    }

    private var paletteRow: some View {
        HStack(spacing: 10) {
            ForEach(palette, id: \.self) { emoji in
                Button {
                    selectedEmoji = emoji
                } label: {
                    Text(emoji)
                        .font(.system(size: 26))
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedEmoji == emoji ? Color.fernbyCorrect.opacity(0.25) : Color.accentColor.opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(selectedEmoji == emoji ? Color.fernbyCorrect : .clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(paletteNames[emoji] ?? "Decoration")
                .accessibilityHint(selectedEmoji == emoji ? "Selected. Tap the garden to place it." : "Double tap to select")
            }
        }
    }
}
