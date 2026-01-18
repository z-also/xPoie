import SwiftUI

struct ProjectsCatalog: View {
    @State private var filterText: String = ""
    
    var onSelect: (UUID) -> Void
    var onToggle: (UUID, Bool) -> Void
    var filterTypes: [Models.Project.`Type`] = [.group, .pad, .task]

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $filterText)
                    .textFieldStyle(.plain)
                    .padding(20, 16, 2, 16)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .buttonStyle(.omni)
            }
            
            ScrollView {
                ProjectsCatalogWithoutFilterField(
                    filter: filterText,
                    types: filterTypes,
                    onSelect: onSelect
                )
            }
        }
    }
}

struct ProjectsCatalogWithoutFilterField: View {
    var filter: String
    var types: [Models.Project.`Type`] = [.pad, .task, .group]
    var onSelect: (UUID) -> Void

    @Environment(\.theme) var theme
    @Environment(\.projects) var projects
    
    @State private var result: [UUID: Collection<UUID>] = [:]
    @State private var localExpandeds: [UUID: Bool] = [:]

    var body: some View {
        CatalogsExplorer(
            catalogs: result,
            rootId: Consts.uuid,
            currentId: projects.scene == .none ? projects.currentProject?.id : nil,
            expandeds: localExpandeds,
            onToggle: { id, expand in localExpandeds[id] = expand },
            onMove: nil,
            movingIndicator: { DropMoveCursor(color: theme.semantic.brand) }
        ) { id, currentId, movingTo, group, expanded, _onToggle  in
            HStack(alignment: .top, spacing: 2) {
                CatalogsExplorerRowCtrl(id: id, group: group, expanded: expanded, onToggle: _onToggle)
                    .padding(.top, 3.5)
                
                let proj = projects.projects[id]!
                ProjectsCatalogItem(project: proj)
            }
            .modifier(id == currentId ? OmniStyle.hovered : movingTo != nil ? OmniStyle.normal.with{ $0.hoverable = false } : OmniStyle.normal)
            .onTapGesture { onSelect(id) }
        }
        .task {
            revalidateFilter()
            ensureAllGroupsExpanded(catalogs: projects.catalogs, projects: projects.projects)
        }
        .onChange(of: filter) { old, new in
            revalidateFilter()
        }
    }
    
    func ensureAllGroupsExpanded(catalogs: [UUID: Collection<UUID>], projects: [UUID: Models.Project]) {
        guard let root = catalogs[Consts.uuid]?.data else { return }
        var stack = root
        while let id = stack.popLast() {
            guard let project = projects[id], project.type == .group else { continue }
            if localExpandeds[id] == nil { localExpandeds[id] = true }
            if let children = catalogs[id]?.data {
                stack.append(contentsOf: children)
            }
        }
    }
    
    func revalidateFilter() {
        result = Modules.Projects.filter(
            projs: projects.projects,
            of: types,
            using: filter,
            catalogs: projects.catalogs
        )
    }
}

struct ProjectsCatalogItem: View {
    var project: Models.Project
    var body: some View {
        HStack(spacing: 6) {
            IconPicker(icon: project.icon, color: project.color) { i, c in
                project.icon = i
                project.color = c
            }
            Text(project.title).typography(.p)
                .lineLimit(1)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

