import AppKit
import ServiceManagement

struct LoginItemService {
    var status: SMAppService.Status {
        SMAppService.mainApp.status
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if status != .enabled {
                try SMAppService.mainApp.register()
            }
        } else if status == .enabled {
            try SMAppService.mainApp.unregister()
        }
    }

    func openLoginItemsSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }
}
