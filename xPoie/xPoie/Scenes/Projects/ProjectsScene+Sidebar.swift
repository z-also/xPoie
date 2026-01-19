import SwiftUI

struct ProjectsSceneSidebar: View {
    @State var creating = false
    @State var isDeleteAcking = false
    @State var metas: Models.Project.Metas = .init(type: .group)

    @Environment(\.main) var main
    @Environment(\.theme) var theme
    @Environment(\.projects) var projects

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AccountFeature_ProfileLink()
                .padding(.bottom, 12)

            StaticRoutes(scene: main.scene)
            
            Spacer().frame(height: 16)
            
            ScrollView {
                CatalogsCtrlbar(title: "Projects") {
                    ProjectsCatalogMenu(project: nil, onCreate: openCreate, onDelete: openDelete)
                }
                    .padding(.leading, 8)
                
                Spacer().frame(height: 4)
                
                CatalogsExplorer(
                    catalogs: projects.catalogs,
                    rootId: Consts.uuid,
                    currentId: projects.scene == .none ? projects.currentProject?.id : nil,
                    expandeds: projects.expandeds,
                    onToggle: onToggle,
                    onMove: onMove,
                    movingIndicator: { DropMoveCursor(color: theme.semantic.brand) }
                ) { id, currentId, movingTo, group, expanded, _onToggle  in
                    HStack(alignment: .top, spacing: 2) {
                        CatalogsExplorerRowCtrl(id: id, group: group, expanded: expanded, onToggle: _onToggle)
                            .padding(.top, 2)
//                            .background(.red)
                        
                        let proj = projects.projects[id]!
                        ProjectsCatalogItem(project: proj)
                            .contextMenu {
                                ProjectsCatalogMenu(project: proj, onCreate: openCreate, onDelete: openDelete)
                            }
                    }
                    .modifier(id == currentId ? OmniStyle.hovered : movingTo != nil ? OmniStyle.normal.with{ $0.hoverable = false } : OmniStyle.normal)
                    .padding(.vertical, 2)
                    .onTapGesture { onSelect(id: id) }
                }
                
//                CatalogsCtrlbar(title: "Tags") {
//                    ProjectsCatalogMenu(project: nil, onCreate: openCreate, onDelete: openDelete)
//                }
//                    .padding(.leading, 8)
            }
        }
        .padding(8)
//        .onHover { active in
//            if !active && Modules.main.sidebarWidth > 0 && Modules.main.shouldHideSidebarWhenInactive {
//                Modules.main.toggle(sidebar: false)
//            }
//        }
        .sheet(isPresented: $creating) {
            ProjectMetasEditor(
                mode: .new,
                metas: $metas,
                onCancel: { creating = false },
                onSubmit: create
            )
        }
        .confirmationDialog("Delete project \"\(metas.title)\"?", isPresented: $isDeleteAcking) {
            Button(role: .destructive, action: onDeleteAcked) {
                Text("Yes, delete")
            }
        } message: {
            Text("All contents in the project will be deleted and not able to recover").typography(.desc)
        }
        .dialogIcon(Image("logo"))
    }
    
    func openDelete(proj: Models.Project) {
        isDeleteAcking = true
        metas = .init(id: proj.id, type: proj.type, title: proj.title)
    }
    
    func onDeleteAcked() {
        if let id = metas.id, let proj = Modules.projects.projects[id] {
            projects.delete(project: proj)
        }
    }

    func onSelect(id: UUID) {
        projects.select(id: id)
        projects.set(scene: .none)
        Modules.main.switch(scene: .projects)
//        if let proj = projects.projects[id], proj.type == .note {
//            Modules.main.sidebar(hideWhenInactive: true)
//        }
    }
    
    func onToggle(id: UUID, expand: Bool) {
        projects.toggle(id: id, expand: expand)
        if let cate = projects.catalogs[id], cate.data.isEmpty {
            projects.load(catalog: id)
        }
    }
    
    func onMove(id: UUID, to: UUID, edge: Edge) {
        projects.move(by: id, to: to, edge: edge)
    }
    
    private func create(metas: Models.Project.Metas) {
        creating = false
        var parent: Models.Project?
        if let pid = metas.parentId, let p = Modules.projects.projects[pid] {
            parent = p
        }
        if let proj = projects.create(metas: metas, at: 0, in: parent) {
            //
        }
    }
    
    private func openCreate(type: Models.Project.`Type`, in parent: Models.Project?) {
        metas = Modules.Projects.initialMetas(for: type)
        metas.parentId = parent?.id
        creating = true
    }
}

fileprivate struct StaticRoutes: View {
    let scene: Modules.Main.Scene
    
    var body: some View {
        VStack(spacing: 6) {
            route(icon: "questionmark.circle.dashed", title: "Inbox", scene: .inbox)
            route(icon: "calendar", title: "Calendar", scene: .calendar)
//            route(icon: "note.text.badge.plus", title: "Ai Assistant", scene: .brain)
        }
    }
    
    @ViewBuilder func route(icon: String, title: String, scene: Modules.Main.Scene) -> some View {
        Button(action: { set(scene: scene) }) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 14, height: 14)
                .padding(.leading, 2)
            
            Text(title).typography(.label)
            
            Spacer()
        }
        .buttonStyle(.omni.with(padding: .nav, active: self.scene == scene))
    }
    
    func set(scene: Modules.Main.Scene) {
        Modules.main.switch(scene: scene)
    }
}
