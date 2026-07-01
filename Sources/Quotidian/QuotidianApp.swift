import SwiftUI

@main
struct QuotidianApp: App {
    @State private var viewModel = UsageViewModel()

    var body: some Scene {
        MenuBarExtra {
            UsageMenuContentView(viewModel: viewModel)
        } label: {
            MenuBarIconView(state: viewModel.state)
                .task {
                    viewModel.startPolling()
                }
        }
        .menuBarExtraStyle(.window)
    }
}
