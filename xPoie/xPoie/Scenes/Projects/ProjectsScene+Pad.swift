import Infy
import SwiftUI
//import WaterfallGrid

struct ProjectsScenePad: View {
    var project: Models.Project
    
    @Environment(\.pads) var pads
    @Environment(\.notes) var notes
    
    @State private var size: CGSize = .init(width: 1600, height: 1000)

    var body: some View {
        VStack {
            PadRepresentable(project: project)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func toggleSidebar() {
        pads.toggleSidebar(hidden: !pads.isSidebarHidden)
    }
    
    private func hideSidebar() {
        if Modules.main.navigationSplitViewColumnVisibility != .detailOnly {
            Modules.main.toggle(sidebar: false)
        }
    }
    
    private func createNote() {
        let note = Modules.notes.createNote(at: 0, in: project.id)
    }
    
    private func deleteNote() {
        
    }
    
    private func exitDetail() {
        Modules.pads.toggle(immersive: false)
    }
}

