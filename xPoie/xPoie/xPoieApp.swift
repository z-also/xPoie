import Llmx
import Infy
import RTex
import Combine
import SwiftUI
import UserNotifications
import AuthenticationServices

@main
struct xPoieApp: App {
    @Environment(\.account) var account
    
    var body: some Scene {
        WindowGroup(id: "main") {
            if account.signedIn {
                MainScene()
                    .modifier(PlasticWindow())
            } else {
                WelcomeScene(onSignIn: onSignIn)
                    .modifier(PlasticWindow())
            }
        }
        .defaultSize(width: 1200, height: 780)
        .windowResizability(.contentSize) // 允许窗口根据内容调整大小
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") {
                    Modules.main.switch(scene: .settings)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        MenuBarExtra("xPoie", systemImage: "clock") {
            MenuBarScene()
        }
        .menuBarExtraStyle(.window)
    }
    
    init() {
        Modules.boot()
        Hotkey.setup()
        print("0000", Preferences[.signedIn])
        UNUserNotificationCenter.current().delegate = Notifications.shared
        Modules.notes.sticky.data.forEach {
            if let note = Modules.notes.notes[$0] {
                NotesFeatureSticky.shared.toggleSticky(for: note)
            }
        }
        
        Task {
            let vv = try await APIs.auth()
            print("ddd ", vv)
        }
        
        Llmx.ModelManager.shared.initStates(models: Llmx.ModelRegistry.textLlms + Llmx.ModelRegistry.visionLlms)
    }
    
    private func onSignIn(authorization: ASAuthorization) {
        try? accountService.handleSuccessfulLogin(authorization: authorization)
        account.set(signedIn: true)
        print("after====", Preferences[.signedIn])
    }
}
