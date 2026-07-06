import SwiftUI

/// One growth stage of the companion — structured like Duck-n-Roll's
/// EvolutionStage.swift (a form the character takes, keyed by stage index).
struct CompanionStage {
    let index: Int
    let name: String
    let bodyColor: Color
    let scale: CGFloat
    let hasLeaf: Bool
    let hasSparkle: Bool

    static let all: [CompanionStage] = [
        CompanionStage(index: 0, name: "Sprout", bodyColor: Color(red: 0.55, green: 0.80, blue: 0.55), scale: 0.7, hasLeaf: false, hasSparkle: false),
        CompanionStage(index: 1, name: "Budding Sprout", bodyColor: Color(red: 0.50, green: 0.78, blue: 0.52), scale: 0.82, hasLeaf: true, hasSparkle: false),
        CompanionStage(index: 2, name: "Bloom", bodyColor: Color(red: 0.98, green: 0.72, blue: 0.55), scale: 0.94, hasLeaf: true, hasSparkle: false),
        CompanionStage(index: 3, name: "Bright Bloom", bodyColor: Color(red: 0.98, green: 0.63, blue: 0.65), scale: 1.05, hasLeaf: true, hasSparkle: true),
        CompanionStage(index: 4, name: "Radiant", bodyColor: Color(red: 0.75, green: 0.55, blue: 0.95), scale: 1.18, hasLeaf: true, hasSparkle: true),
    ]

    static func stage(for index: Int) -> CompanionStage {
        all[min(max(index, 0), all.count - 1)]
    }
}

/// A single creature, drawn entirely with SwiftUI's Canvas (no shipped
/// image assets) — following TextureFactory.swift's procedural-art
/// philosophy, translated from Core Graphics/SpriteKit textures to a
/// resolution-independent live-drawn shape.
struct CompanionArtView: View {
    let stage: CompanionStage
    var size: CGFloat = 140

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let bodyRadius = canvasSize.width * 0.34 * stage.scale

            // Body
            let bodyRect = CGRect(
                x: center.x - bodyRadius, y: center.y - bodyRadius * 0.9,
                width: bodyRadius * 2, height: bodyRadius * 2
            )
            context.fill(Path(ellipseIn: bodyRect), with: .color(stage.bodyColor))

            // Belly highlight
            let bellyRect = bodyRect.insetBy(dx: bodyRadius * 0.55, dy: bodyRadius * 0.55)
                .offsetBy(dx: 0, dy: bodyRadius * 0.25)
            context.fill(Path(ellipseIn: bellyRect), with: .color(.white.opacity(0.35)))

            // Eyes
            let eyeRadius = bodyRadius * 0.12
            let eyeY = center.y - bodyRadius * 0.15
            for dx in [-bodyRadius * 0.35, bodyRadius * 0.35] {
                let eyeRect = CGRect(x: center.x + dx - eyeRadius, y: eyeY - eyeRadius, width: eyeRadius * 2, height: eyeRadius * 2)
                context.fill(Path(ellipseIn: eyeRect), with: .color(.black.opacity(0.75)))
            }

            // Smile
            var smile = Path()
            smile.addArc(
                center: CGPoint(x: center.x, y: eyeY + bodyRadius * 0.18),
                radius: bodyRadius * 0.22,
                startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false
            )
            context.stroke(smile, with: .color(.black.opacity(0.6)), lineWidth: max(2, bodyRadius * 0.05))

            // Leaf accessory
            if stage.hasLeaf {
                var leaf = Path()
                let leafTop = CGPoint(x: center.x, y: center.y - bodyRadius * 0.95)
                leaf.move(to: leafTop)
                leaf.addQuadCurve(to: CGPoint(x: center.x + bodyRadius * 0.28, y: leafTop.y + bodyRadius * 0.28), control: CGPoint(x: center.x + bodyRadius * 0.32, y: leafTop.y - bodyRadius * 0.05))
                leaf.addQuadCurve(to: leafTop, control: CGPoint(x: center.x + bodyRadius * 0.02, y: leafTop.y + bodyRadius * 0.15))
                context.fill(leaf, with: .color(Color(red: 0.35, green: 0.62, blue: 0.35)))
            }

            // Sparkle accessory
            if stage.hasSparkle {
                let sparkleCenter = CGPoint(x: center.x + bodyRadius * 0.75, y: center.y - bodyRadius * 0.65)
                let s = bodyRadius * 0.16
                var sparkle = Path()
                sparkle.move(to: CGPoint(x: sparkleCenter.x, y: sparkleCenter.y - s))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x + s * 0.3, y: sparkleCenter.y - s * 0.3))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x + s, y: sparkleCenter.y))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x + s * 0.3, y: sparkleCenter.y + s * 0.3))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x, y: sparkleCenter.y + s))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x - s * 0.3, y: sparkleCenter.y + s * 0.3))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x - s, y: sparkleCenter.y))
                sparkle.addLine(to: CGPoint(x: sparkleCenter.x - s * 0.3, y: sparkleCenter.y - s * 0.3))
                sparkle.closeSubpath()
                context.fill(sparkle, with: .color(Color(red: 1.0, green: 0.85, blue: 0.4)))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
