import Foundation

enum Formatting {
    static func relativeReset(_ date: Date?, now: Date = Date()) -> String {
        guard let date else { return "reset time unknown" }
        let interval = date.timeIntervalSince(now)
        if interval <= 0 { return "resets soon" }
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        let formatted = formatter.string(from: interval) ?? "?"
        return "resets in \(formatted)"
    }

    static func percent(_ value: Double) -> String {
        "\(Int(value.rounded()))%"
    }
}
