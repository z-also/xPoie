import SwiftUI

struct ProjectsSceneMain: View {
    @Environment(\.projects) var projects
    @Environment(\.pads.immersive) var immersive

    @State private var isMetasEditorPresented = false
    @State var metas: Models.Project.Metas = .init(type: .group)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let project = projects.currentProject {
                if project.type == .group {
                    ProjectsSceneGroup(project: project)
                }
                if project.type == .pad {
                    ProjectsScenePad(project: project)
                        .toolbar {
                            if immersive {
                                ToolbarItem(placement: .navigation) {
                                    Button(action: exitDetail) {
                                        Label("Back", systemImage: "arrow.left")
                                    }
                                }
                            } else {
                                ToolbarItem(placement: .navigation) {
                                    ProjectsFeatureTitleSetter(project: project)
                                }
                                .sharedBackgroundVisibility(.hidden)
                            }
                            
                            ToolbarSpacer(.flexible)
                            
                            
                            ToolbarItem {
                                ExtraMenu {
                                    if immersive {
                                        Button(action: {}) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    } else {
                                        Button(action: openMetasEditor) {
                                            Label("Edit", systemImage: "pencil.and.scribble")
                                        }
                                        Button(action: {} ) {
                                            Label("Show notes", systemImage: "chevron.up.chevron.down")
                                        }
                                        Button(action: {}) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .sharedBackgroundVisibility(.hidden)
                        }
                }
                if project.type == .task {
                    ProjectsSceneTasks(project: project)
//                        .toolbar {
//                            ToolbarItemGroup(placement: .principal) {
//                                MainNavigator()
//                            }
//                        }
                        .toolbar {
                            ToolbarItem(placement: .navigation) {
                                ProjectsFeatureTitleSetter(project: project)
                            }
                            .sharedBackgroundVisibility(.hidden)
                            
                            ToolbarSpacer(.flexible)
                            
                            ToolbarItem {
                                SearchBox()
                            }
//                            .sharedBackgroundVisibility(.hidden)

                            ToolbarItem {
                                ExtraMenu {
                                    Button(action: openMetasEditor) {
                                        Label("Edit", systemImage: "pencil.and.scribble")
                                    }
                                    Button(action: {} ) {
                                        Label("Show notes", systemImage: "chevron.up.chevron.down")
                                    }
                                    Button(action: {}) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .sharedBackgroundVisibility(.hidden)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $isMetasEditorPresented) {
            ProjectMetasEditor(
                mode: .edit,
                metas: $metas,
                onCancel: onMetasEditCancel,
                onSubmit: onMetasEditSubmit
            )
        }
    }
    
    private func toggleNotesPresented() {
        if let project = projects.currentProject {
            Modules.projects.toggleNotesPresented(project: project)
        }
    }
    
    private func exitDetail() {
        Modules.pads.toggle(immersive: false)
    }
    
    private func openMetasEditor() {
        if let project = projects.currentProject {
            metas = Models.Project.metas(for: project)
            isMetasEditorPresented = true
        }
    }
    
    private func onMetasEditCancel() {
        isMetasEditorPresented = false
    }
    
    private func onMetasEditSubmit(metas: Models.Project.Metas) {
        
    }
}
