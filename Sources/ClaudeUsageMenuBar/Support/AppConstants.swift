import Foundation

enum AppConstants {
    static let keychainService = "Claude Code-credentials"
    static let usageEndpoint = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    static let anthropicVersion = "2023-06-01"
    static let pollInterval: Duration = .seconds(120)

    enum Threshold {
        static let amber: Double = 70
        static let red: Double = 90
    }
}
