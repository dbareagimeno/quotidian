import Testing
@testable import Quotidian
import Foundation

struct UsageAPIClientDecodingTests {
    @Test func decodesValidUsageResponse() throws {
        // Field names/date format below match the live endpoint response observed
        // during development: fractional seconds with a "+00:00" offset, plus extra
        // unrelated top-level fields the app doesn't need (must be ignored, not error).
        let json = """
        {
          "five_hour": {"utilization": 42.0, "resets_at": "2026-07-01T12:00:00.005003+00:00", "limit_dollars": null},
          "seven_day": {"utilization": 68.5, "resets_at": "2026-07-07T00:00:00.005022+00:00", "limit_dollars": null},
          "extra_usage": {"is_enabled": false},
          "limits": []
        }
        """.data(using: .utf8)!

        let snapshot = try UsageAPIClient.decode(json)

        #expect(snapshot.fiveHour.utilization == 42.0)
        #expect(snapshot.sevenDay.utilization == 68.5)
        #expect(snapshot.fiveHour.resetsAt != nil)
        #expect(snapshot.sevenDay.resetsAt != nil)
    }

    @Test func malformedResponseFailsToDecodeWithoutCrashing() {
        let json = """
        {"unexpected": "shape"}
        """.data(using: .utf8)!

        #expect(throws: (any Error).self) {
            try UsageAPIClient.decode(json)
        }
    }
}
