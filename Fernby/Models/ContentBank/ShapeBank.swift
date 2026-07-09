import Foundation

/// K-level 2D shape identification — the first of the new CCSS-mapped math
/// nodes beyond arithmetic. Shapes are rendered as real SwiftUI Shape
/// views (see ShapeGlyph), not emoji stand-ins, so the geometry a child
/// sees is actually accurate rather than an approximation.
enum ShapeKind: String, CaseIterable {
    case circle, square, triangle, rectangle, star, oval

    var displayName: String { rawValue.capitalized }
}

enum ShapeBank {
    static func random() -> ShapeKind {
        ShapeKind.allCases.randomElement()!
    }

    static func decoys(excluding target: ShapeKind, count: Int) -> [ShapeKind] {
        Array(ShapeKind.allCases.filter { $0 != target }.shuffled().prefix(count))
    }
}
