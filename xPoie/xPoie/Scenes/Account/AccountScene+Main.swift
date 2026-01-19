import SwiftUI

struct AccountSceneMain: View {
    var body: some View {
        VStack(alignment: .leading) {
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
