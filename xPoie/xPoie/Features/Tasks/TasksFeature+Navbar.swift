import SwiftUI

struct TasksFeatureNavbar: View {
    let project: Models.Project
    let onCreateBlock: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            ProjectsFeatureTitleSetter(project: project)

            Spacer()

            HStack(spacing: 16) {
                Button(action: onCreateBlock) {
                    Image(systemName: "plus.circle.dashed")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(2, 0)
                    
                    Text("New Block")
                }
                .buttonStyle(.omni.with(visual: .brand, padding: .md))

                Menu {
                    Button(action: toggleNotesPresented ) {
                        Label(project.notesPresented ? "Hide notes" : "Show notes", systemImage: "chevron.up.chevron.down")
                    }
                    Button(action: {}) {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button(action: {}) {
                        Label("Sticky window", systemImage: "pin")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .frame(width: 15, height: 3)
                        .padding(8, 6)
                }
                .menuStyle(.button)
                .buttonStyle(.omni.with(padding: .zero))
            }
            .padding(0, 4)
        }
        .padding(5, 12, 4, 16)
    }
    
    private func toggleNotesPresented() {
        Modules.projects.toggleNotesPresented(project: project)
    }
}
