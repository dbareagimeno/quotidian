import Testing
@testable import Quotidian
import Foundation

struct CredentialParserTests {
    @Test func parsesNestedClaudeAiOauthWrapper() {
        let json = """
        {"claudeAiOauth": {"accessToken": "abc123", "refreshToken": "r1", "expiresAt": 1234567890}}
        """.data(using: .utf8)!

        let credential = CredentialParser.parse(json)

        #expect(credential?.accessToken == "abc123")
    }

    @Test func parsesFlatJSONToken() {
        let json = """
        {"accessToken": "flat-token"}
        """.data(using: .utf8)!

        let credential = CredentialParser.parse(json)

        #expect(credential?.accessToken == "flat-token")
    }

    @Test func parsesPlainTextToken() {
        let data = "  sk-ant-raw-token  \n".data(using: .utf8)!

        let credential = CredentialParser.parse(data)

        #expect(credential?.accessToken == "sk-ant-raw-token")
    }

    @Test func returnsNilForEmptyData() {
        let credential = CredentialParser.parse(Data())

        #expect(credential == nil)
    }
}
