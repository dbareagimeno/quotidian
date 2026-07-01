import Foundation

enum UsageAPIError: Error {
    case tokenExpired
    case http(Int)
    case network(Error)
    case decoding(Error)
}

struct UsageAPIClient {
    func fetchUsage(token: String) async throws -> UsageSnapshot {
        var request = URLRequest(url: AppConstants.usageEndpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(AppConstants.anthropicVersion, forHTTPHeaderField: "anthropic-version")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw UsageAPIError.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw UsageAPIError.network(URLError(.badServerResponse))
        }
        guard http.statusCode != 401 else { throw UsageAPIError.tokenExpired }
        guard (200..<300).contains(http.statusCode) else { throw UsageAPIError.http(http.statusCode) }

        do {
            return try Self.decode(data)
        } catch {
            throw UsageAPIError.decoding(error)
        }
    }

    static func decode(_ data: Data) throws -> UsageSnapshot {
        struct RawWindow: Decodable {
            let utilization: Double
            let resetsAt: String?
        }
        struct RawResponse: Decodable {
            let fiveHour: RawWindow
            let sevenDay: RawWindow
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let raw = try decoder.decode(RawResponse.self, from: data)

        // Verified against the live endpoint: utilization is 0-100, and
        // resets_at includes fractional seconds (e.g. "...T13:20:01.005003+00:00"),
        // which the default ISO8601DateFormatter options can't parse.
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        func toWindow(_ window: RawWindow) -> WindowUsage {
            WindowUsage(utilization: window.utilization, resetsAt: window.resetsAt.flatMap { isoFormatter.date(from: $0) })
        }
        return UsageSnapshot(fiveHour: toWindow(raw.fiveHour), sevenDay: toWindow(raw.sevenDay), fetchedAt: Date())
    }
}
