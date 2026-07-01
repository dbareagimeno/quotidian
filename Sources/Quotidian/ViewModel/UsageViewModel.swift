import Foundation
import Observation

@MainActor
@Observable
final class UsageViewModel {
    private(set) var state: UsageLoadState = .idle
    private(set) var lastUpdated: Date?

    var loginItemEnabled: Bool {
        didSet {
            guard oldValue != loginItemEnabled else { return }
            applyLoginItemChange()
        }
    }

    private var lastGoodSnapshot: UsageSnapshot?
    private var pollingTask: Task<Void, Never>?
    private let keychain = KeychainService()
    private let apiClient = UsageAPIClient()
    private let loginItems = LoginItemService()

    init() {
        // First launch ever: default "Launch at Login" to on. Later launches
        // just reflect whatever the user last chose (including a manual opt-out).
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: Self.hasSetInitialLoginItemDefaultKey) {
            defaults.set(true, forKey: Self.hasSetInitialLoginItemDefaultKey)
            try? loginItems.setEnabled(true)
        }
        loginItemEnabled = loginItems.status == .enabled
    }

    private static let hasSetInitialLoginItemDefaultKey = "hasSetInitialLoginItemDefault"

    func startPolling(interval: Duration = AppConstants.pollInterval) {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.refresh()
                try? await Task.sleep(for: interval)
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func refresh() async {
        state = .loading
        do {
            let data = try keychain.loadCredentialData()
            guard let credential = CredentialParser.parse(data) else {
                applyFailure(.error("Could not parse stored Claude Code credential"))
                return
            }
            let snapshot = try await apiClient.fetchUsage(token: credential.accessToken)
            lastGoodSnapshot = snapshot
            lastUpdated = snapshot.fetchedAt
            state = .loaded(snapshot)
        } catch let error as KeychainError {
            handle(keychainError: error)
        } catch let error as UsageAPIError {
            handle(apiError: error)
        } catch {
            applyFailure(.error(error.localizedDescription))
        }
    }

    private func handle(keychainError: KeychainError) {
        switch keychainError {
        case .itemNotFound:
            applyFailure(.keychainItemNotFound)
        case .accessDenied:
            applyFailure(.keychainAccessDenied)
        case .unexpected(let status):
            applyFailure(.error("Unexpected Keychain error (OSStatus \(status))"))
        }
    }

    private func handle(apiError: UsageAPIError) {
        switch apiError {
        case .tokenExpired:
            applyFailure(.tokenExpired)
        case .http(let code):
            applyFailure(.error("Usage endpoint returned HTTP \(code)"))
        case .network(let error):
            applyFailure(.error(error.localizedDescription))
        case .decoding(let error):
            applyFailure(.error("Could not parse usage response: \(error.localizedDescription)"))
        }
    }

    private func applyFailure(_ fallback: UsageLoadState) {
        if let snapshot = lastGoodSnapshot {
            state = .stale(snapshot, reason: describeReason(fallback))
        } else {
            state = fallback
        }
    }

    private func describeReason(_ fallback: UsageLoadState) -> String {
        switch fallback {
        case .keychainItemNotFound: return "Claude Code credentials not found"
        case .keychainAccessDenied: return "Keychain access denied"
        case .tokenExpired: return "Session expired"
        case .error(let message): return message
        default: return "Unknown error"
        }
    }

    private func applyLoginItemChange() {
        do {
            try loginItems.setEnabled(loginItemEnabled)
        } catch {
            loginItemEnabled = loginItems.status == .enabled
        }
    }
}
