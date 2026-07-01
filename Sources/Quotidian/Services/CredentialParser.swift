import Foundation

// Claude Code's Keychain storage format is undocumented. Handle every shape
// the community has reported: a JSON wrapper under "claudeAiOauth", a flat
// JSON object, or a plain-text token — falling back through each in turn.
enum CredentialParser {
    private struct ClaudeAIOAuthWrapper: Decodable {
        struct OAuth: Decodable {
            let accessToken: String
        }
        let claudeAiOauth: OAuth
    }

    private struct FlatToken: Decodable {
        let accessToken: String
    }

    static func parse(_ data: Data) -> StoredCredential? {
        if let wrapper = try? JSONDecoder().decode(ClaudeAIOAuthWrapper.self, from: data) {
            return StoredCredential(accessToken: wrapper.claudeAiOauth.accessToken)
        }
        if let flat = try? JSONDecoder().decode(FlatToken.self, from: data) {
            return StoredCredential(accessToken: flat.accessToken)
        }
        if let text = String(data: data, encoding: .utf8) {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return StoredCredential(accessToken: trimmed)
            }
        }
        return nil
    }
}
