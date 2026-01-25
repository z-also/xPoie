import SwiftUI

struct SettingsSceneMain: View {
    @Environment(\.settings.scene) private var scene
    
    var body: some View {
        VStack(alignment: .leading) {
            switch scene {
            case .general:
                Text("")
            case .appearance:
                Text("")
            case .shortcuts:
                Text("")
            case .localModels:
                SettingsSceneLocalModels()
            case .subscription:
                SettingsSceneSubscription()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//        .background(.white, in: .rect(cornerRadius: 16))
//        .padding(16)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: goBack) {
                    Label("Back", systemImage: "arrow.left")
                }
            }
        }
    }
    
    private func goBack() {
        Modules.main.switch(scene: .projects)
    }
}
