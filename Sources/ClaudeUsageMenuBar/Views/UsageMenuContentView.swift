import SwiftUI

struct UsageMenuContentView: View {
    @Bindable var viewModel: UsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
            Divider()
            if let lastUpdated = viewModel.lastUpdated {
                Text("Last updated \(lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Refresh Now") {
                Task { await viewModel.refresh() }
            }
            .disabled(isLoading)
            Divider()
            Toggle("Launch at Login", isOn: $viewModel.loginItemEnabled)
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(width: 260)
    }

    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .controlSize(.small)
        case .loaded(let snapshot):
            usageRows(snapshot, dimmed: false, footnote: nil)
        case .stale(let snapshot, let reason):
            usageRows(snapshot, dimmed: true, footnote: reason)
        case .keychainItemNotFound:
            ErrorStateView(message: "Claude Code credentials not found. Make sure Claude Code is installed and you're signed in.")
        case .keychainAccessDenied:
            ErrorStateView(message: "Keychain access denied. Relaunch and choose \u{201C}Always Allow\u{201D}, or open Keychain Access.app and adjust access for \u{201C}Claude Code-credentials\u{201D}.")
        case .tokenExpired:
            ErrorStateView(message: "Session expired. Sign in again with Claude Code.")
        case .error(let message):
            ErrorStateView(message: message)
        }
    }

    @ViewBuilder
    private func usageRows(_ snapshot: UsageSnapshot, dimmed: Bool, footnote: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            usageRow(title: "5 hour", window: snapshot.fiveHour)
            usageRow(title: "Weekly", window: snapshot.sevenDay)
            if let footnote {
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .opacity(dimmed ? 0.6 : 1)
    }

    private func usageRow(title: String, window: WindowUsage) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(Formatting.percent(window.utilization)).font(.headline)
            }
            ProgressView(value: min(max(window.utilization, 0), 100), total: 100)
            Text(Formatting.relativeReset(window.resetsAt))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
