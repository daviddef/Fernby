import SwiftUI

/// A five-pointed star, since SwiftUI has no built-in star Shape.
struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.42
        var path = Path()
        for i in 0..<10 {
            let angle = (Double(i) * .pi / 5) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

/// Renders a `ShapeKind` as a real SwiftUI shape rather than an emoji
/// stand-in, so the geometry a child sees (corners, curves, side lengths)
/// is actually accurate.
struct ShapeGlyph: View {
    let kind: ShapeKind
    var size: CGFloat = 140
    var color: Color = .accentColor

    var body: some View {
        Group {
            switch kind {
            case .circle:
                Circle().fill(color)
            case .square:
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(color)
            case .triangle:
                TriangleShape().fill(color)
            case .rectangle:
                RoundedRectangle(cornerRadius: 6, style: .continuous).fill(color)
            case .star:
                StarShape().fill(color)
            case .oval:
                Ellipse().fill(color)
            }
        }
        .frame(width: framedWidth, height: framedHeight)
    }

    private var framedWidth: CGFloat {
        switch kind {
        case .rectangle: return size * 1.5
        case .oval: return size * 1.4
        default: return size
        }
    }

    private var framedHeight: CGFloat {
        switch kind {
        case .rectangle: return size * 0.75
        case .oval: return size * 0.85
        default: return size
        }
    }
}
