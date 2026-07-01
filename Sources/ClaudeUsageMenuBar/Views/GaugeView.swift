import SwiftUI

// Two small vertical bars used both as the menu bar icon (rasterized to an
// NSImage) and potentially elsewhere. Drawn with plain shapes rather than
// Canvas, because Canvas content frequently renders blank inside a
// MenuBarExtra label / ImageRenderer.
struct GaugeBars: View {
    let fiveHour: Double
    let sevenDay: Double
    var dimmed: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            GaugeBar(percentage: fiveHour)
            GaugeBar(percentage: sevenDay)
        }
        .opacity(dimmed ? 0.5 : 1)
        .padding(2)
    }
}

struct GaugeBar: View {
    let percentage: Double // 0...100

    // Real usage is often single digits, which would be an invisible sliver.
    // Floor the drawn fill so the bar always reads; the exact number lives in
    // the dropdown, so this never misrepresents the value.
    private static let minVisibleFill: CGFloat = 0.14

    private var color: Color {
        switch percentage {
        case ..<AppConstants.Threshold.amber: return .green
        case ..<AppConstants.Threshold.red: return .orange
        default: return .red
        }
    }

    var body: some View {
        let clamped = min(max(percentage, 0), 100) / 100
        let fraction = max(CGFloat(clamped), Self.minVisibleFill)
        // Track uses a faded version of the SAME color (not .primary), so a
        // colored shape is always visible on both light and dark menu bars.
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 2).fill(color.opacity(0.28))
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 14 * fraction)
        }
        .frame(width: 7, height: 14)
    }
}
