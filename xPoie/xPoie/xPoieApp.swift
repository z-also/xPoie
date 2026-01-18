import Infy
import Combine
import SwiftUI
import UserNotifications
import RTex

@main
struct Tik_itApp: App {
    var body: some Scene {
        WindowGroup(id: "main") {
            MainScene()
                .modifier(PlasticWindow())
        }
        .defaultSize(width: 1200, height: 780)
        .windowResizability(.contentSize) // 允许窗口根据内容调整大小
        .windowToolbarStyle(.unified(showsTitle: false))

        Settings {
            SettingsScene().modifier(PlasticWindow())
        }

        MenuBarExtra("xPoie", systemImage: "clock") {
            MenuBarScene()
        }
        .menuBarExtraStyle(.window)
    }
    
    init() {
        Modules.boot()
        Hotkey.setup()
        UNUserNotificationCenter.current().delegate = Notifications.shared
        Modules.notes.sticky.data.forEach {
            if let note = Modules.notes.notes[$0] {
                NotesFeatureSticky.shared.toggleSticky(for: note)
            }
        }
    }
}
