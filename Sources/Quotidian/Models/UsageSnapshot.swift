import Foundation

struct UsageSnapshot: Equatable {
    let fiveHour: WindowUsage
    let sevenDay: WindowUsage
    let fetchedAt: Date
}
