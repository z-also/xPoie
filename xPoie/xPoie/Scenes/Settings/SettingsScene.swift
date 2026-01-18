import SwiftUI

struct SettingsScene: View {
    @Environment(\.theme) var theme
    
    @State private var selected: Modules.Settings.Tabs.Id = .general
    
    var body: some View {
        TabView(selection: $selected) {
            Tab(String(localized: "general"), systemImage: "folder", value: .general) {
                SettingsGeneralView()
            }
            
            Tab(String(localized: "appearance"), systemImage: "paintpalette", value: .appearance) {
                SettingsAppearance()
            }
        }
        .padding()
        .frame(width: 800, height: 600, alignment: .top)
        .overlay(Rectangle().fill(theme.text.quaternary).frame(height: 0.5), alignment: .top)
    }
}
