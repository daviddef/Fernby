import SwiftUI

/// A real analog clock face, drawn with Canvas rather than an emoji or a
/// static image — same "accurate geometry, not a stand-in" reasoning as
/// ShapeGlyph. Only whole hours and half-hours are ever passed in (see
/// TimeBank), matching the K-1 telling-time scope.
struct ClockFaceView: View {
    let hour: Int
    let minute: Int
    var size: CGFloat = 200

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let radius = min(canvasSize.width, canvasSize.height) / 2 - 6

            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(.primary.opacity(0.7)),
                lineWidth: 4
            )

            for tick in 0..<12 {
                let angle = Double(tick) * .pi / 6
                let outer = CGPoint(x: center.x + radius * 0.92 * sin(angle), y: center.y - radius * 0.92 * cos(angle))
                let inner = CGPoint(x: center.x + radius * 0.80 * sin(angle), y: center.y - radius * 0.80 * cos(angle))
                var tickPath = Path()
                tickPath.move(to: inner)
                tickPath.addLine(to: outer)
                context.stroke(tickPath, with: .color(.primary.opacity(0.5)), lineWidth: 3)
            }

            let hourAngle = (Double(hour % 12) + Double(minute) / 60) * .pi / 6
            let hourHandEnd = CGPoint(x: center.x + radius * 0.5 * sin(hourAngle), y: center.y - radius * 0.5 * cos(hourAngle))
            var hourHand = Path()
            hourHand.move(to: center)
            hourHand.addLine(to: hourHandEnd)
            context.stroke(hourHand, with: .color(.primary), style: StrokeStyle(lineWidth: 6, lineCap: .round))

            let minuteAngle = Double(minute) * .pi / 30
            let minuteHandEnd = CGPoint(x: center.x + radius * 0.78 * sin(minuteAngle), y: center.y - radius * 0.78 * cos(minuteAngle))
            var minuteHand = Path()
            minuteHand.move(to: center)
            minuteHand.addLine(to: minuteHandEnd)
            context.stroke(minuteHand, with: .color(Color.accentColor), style: StrokeStyle(lineWidth: 4, lineCap: .round))

            let hub = CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10)
            context.fill(Path(ellipseIn: hub), with: .color(.primary))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
