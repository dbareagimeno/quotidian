import SwiftUI
import AppKit

struct MenuBarIconView: View {
    let state: UsageLoadState
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        // Rasterize to an NSImage with isTemplate = false. A live custom
        // SwiftUI label (especially Canvas) often renders blank in the menu
        // bar even though the status item stays clickable; an NSImage does not.
        Image(nsImage: renderIcon())
            .renderingMode(.original)
    }

    private var bars: GaugeBars {
        switch state {
        case .loaded(let snapshot):
            return GaugeBars(fiveHour: snapshot.fiveHour.utilization,
                             sevenDay: snapshot.sevenDay.utilization)
        case .stale(let snapshot, _):
            return GaugeBars(fiveHour: snapshot.fiveHour.utilization,
                             sevenDay: snapshot.sevenDay.utilization,
                             dimmed: true)
        default:
            return GaugeBars(fiveHour: 0, sevenDay: 0, dimmed: true)
        }
    }

    @MainActor
    private func renderIcon() -> NSImage {
        let renderer = ImageRenderer(content: bars)
        renderer.scale = displayScale > 0 ? displayScale : 2
        guard let image = renderer.nsImage else {
            return NSImage(size: NSSize(width: 18, height: 16))
        }
        image.isTemplate = false
        return image
    }
}
