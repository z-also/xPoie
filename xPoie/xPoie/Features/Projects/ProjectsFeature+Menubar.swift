import SwiftUI

struct ProjectsCatalogMenu: View {
    var project: Models.Project?
    
    var onCreate: (Models.Project.`Type`, Models.Project?) -> Void
    var onDelete: (Models.Project) -> Void

    var body: some View {
        Group {
            if project == nil || project!.type == .group {
                Button(action: { onCreate(.group, project) }) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
                Section("Projects") {
                    Button(action: { onCreate(.pad, project) }) {
                        Label("New Chat", systemImage: "text.pad.header.badge.plus")
                    }
                    Button(action: { onCreate(.pad, project) }) {
                        Label("New Notepad", systemImage: "text.pad.header.badge.plus")
                    }
                    Button(action: { onCreate(.task, project) }) {
                        Label("New Task Book", systemImage: "inset.filled.circle.dashed")
                    }
                }
            }
                
            if project != nil {
                Section {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        onDelete(project!)
                    }
                }
            }
        }
    }
}
