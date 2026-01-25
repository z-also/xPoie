import SwiftUI

fileprivate typealias R = (
    icon: String, title: String, scene: Modules.Settings.Scene
)

fileprivate let accountRoutes: [R] = [
    (icon: "gear", title: "Subscription", scene: .subscription),
]

fileprivate let generalRoutes: [R] = [
    (icon: "gear", title: "General", scene: .general),
//    (icon: "paintpalette", title: "Appearance", scene: .appearance),
    (icon: "slider.horizontal.below.circle.lefthalf.filled", title: "Appearance", scene: .appearance),
    (icon: "command", title: "Shortcuts", scene: .shortcuts),
]

fileprivate let advancedRoutes: [R] = [
    (icon: "sparkles", title: "Local Models", scene: .localModels),
]

struct SettingsSceneSidebar: View {
    @Environment(\.settings.scene) var scene
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Spacer().frame(height: 60)
            
            Section {
                ForEach(accountRoutes, id: \.scene) { route in
                    Route(info: route, active: route.scene == scene)
                }
            } header: {
                Text("Account")
                    .typography(.h6, size: .p)
                    .padding(6)
            }
            
            Spacer().frame(height: 16)
            
            Section {
                ForEach(generalRoutes, id: \.scene) { route in
                    Route(info: route, active: route.scene == scene)
                }
            } header: {
                Text("General Settings")
                    .typography(.h6, size: .p)
                    .padding(6)
            }
            
            Spacer().frame(height: 16)

            Section {
                ForEach(advancedRoutes, id: \.scene) { route in
                    Route(info: route, active: route.scene == scene)
                }
            } header: {
                Text("Advanced Settings")
                    .typography(.h6, size: .p)
                    .padding(6)
            }

            Spacer()
            
            AccountFeature_SignOutBtn()
        }
        .padding(10)
    }
}

fileprivate struct ProfileCard: View {
    var body: some View {
        VStack {
            
        }
    }
}

fileprivate struct Route: View {
    let info: R
    let active: Bool
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: `switch`) {
            Image(systemName: info.icon)
                .foregroundStyle(theme.text.tertiary)
            
            Text(info.title)
                .font(size: .sm)
            
            Spacer()
        }
        .buttonStyle(.omni.with(visual: .secondaryRoute, padding: .lg, active: active))
    }
    
    private func `switch`() {
        Modules.settings.switch(scene: info.scene)
    }
}
