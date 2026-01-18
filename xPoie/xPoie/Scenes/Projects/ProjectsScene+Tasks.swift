import AppKit
import SwiftUI

struct ProjectsSceneTasks: View {
    var project: Models.Project
    
    @State var editingBlock: Models.Task.Block?
    @State var draggingBlock: Models.Task.Block?

    @Environment(\.theme) var theme
    @Environment(\.tasks) var tasks
    @Environment(\.input) var input

    var body: some View {
        VStack {
            let blockCatalog = tasks.projects[project.id] ?? .init(data: [])
            let projectTasks = tasks.catalogs[project.id] ?? .init(data: [])
            
//            TasksFeatureNavbar(project: project, onCreateBlock: createBlock)
            
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    if project.notesPresented {
                        ProjectsFeatureNotes(notes: project.notes)
                    }

                    LazyVStack {
                        if !projectTasks.data.isEmpty {
                            DefaultSection(projectId: project.id)
                        }
                        
                        // 显示项目下的blocks
                        ForEach(blockCatalog.data, id: \.uuidString) { id in
                            let block = tasks.blocks[id]!
                            let focused = input.focus == .row(id: id)
                            
                            TasksOmniBlock(
                                data: block,
                                catalog: tasks.catalogs[block.id]!,
                                expanded: tasks.expandeds[block.id] ?? false
                            )
                                .id(id)
                                .onDrag {
                                    self.draggingBlock = block
                                    return NSItemProvider()
                                }
                                .onDrop(of: [.text],
                                        delegate: DropViewDelegate()
                                )
                        }
                    }
                    .padding(8, 6)

                    if blockCatalog.data.isEmpty && projectTasks.data.isEmpty {
                        StarterGuide(
                            icon: "projects/start_to_write",
                            title: "Light-up your efficient organized life & work",
                            desc: "Organize your daily tasks of life and work, using a tasks block to help your agenda clear and focused",
                            action: createBlock
                        )
                    } else {
                        TasksBlockCreateControl(action: createBlock)
                            .padding(.bottom, 48)
                    }
                }
//                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
                .background(theme.fill.glass, in: .rect(cornerRadius: 18))
                .padding(1, 8, 8, 8)
                .onChange(of: editingBlock) { _, newValue in
                    if let item = newValue {
                        withAnimation {
                            proxy.scrollTo(item.id, anchor: .center)
                        } completion: {
                            _ = delay(seconds: 0.3) { input.focus = .title(id: editingBlock?.id ?? Consts.uuid) }
                            _ = delay(seconds: 3) { editingBlock = nil }
                        }
                    }
                }
            }
        }
    }
    
    func createBlock() {
        if let block = tasks.createBlock(at: 0, in: project.id) {
            editingBlock = block
        }
    }
    
    func onToggleBlock(block: Models.Task.Block) {
        tasks.toggle(block: block)
    }
}

fileprivate struct DefaultSection: View {
    let projectId: UUID

    @State private var expanded = true
    @State private var hovered = false

    @Environment(\.theme) private var theme: Theme
    
    private var tasks: [Models.Task] {
        Modules.tasks.catalogs[projectId]?.data.compactMap { Modules.tasks.tasks[$0] } ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { toggleExpand() }) {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6, height: 9)
                        .foregroundStyle(theme.text.secondary)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                }
                .buttonStyle(.omni.with(size: .xs))
                .padding(.top, 1)

                Text("uncatagoried")
                    .font(size: .h4, weight: .medium)
                    .foregroundStyle(theme.text.secondary)
                    .onTapGesture { toggleExpand() }

                Spacer().frame(width: 16)

                Button(action: { createTask() }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 10, height: 10)
                }
                .buttonStyle(.omni.with(size: .btn))
                .opacity(hovered ? 1.0 : 0)

                Spacer()
            }
            .padding(0, 32, 0, 12)
            .contentShape(Rectangle())
            .onHover { h in hovered = h }
            
            if expanded {
                TasksFeatureTaskList(catalogId: projectId)
                    .padding(.leading, 8)
            }
        }
    }

    func toggleExpand() {
        withAnimation {
            expanded.toggle()
        }
    }

    func createTask() {

    }
}

struct DropViewDelegate: DropDelegate {
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
    }
}
