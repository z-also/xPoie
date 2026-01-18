import SwiftUI

struct TasksFeatureTaskList: View {
    var catalogId: UUID
    
    @Environment(\.tasks) var tasks
    @Environment(\.input) var input
    @Environment(\.theme) var theme
    
    var currentTaskId: UUID? {
        if case let .title(id) = input.focus {
            return id
        }
        if case let .content(id) = input.focus {
            return id
        }
        return nil
    }
    
    var body: some View {
        CatalogsExplorer(
            catalogs: tasks.catalogs,
            rootId: catalogId,
            currentId: currentTaskId,
            expandeds: tasks.expandeds,
            onToggle: onToggle,
            onMove: onTaskMove,
            movingIndicator: { DropMoveCursor(color: theme.semantic.brand) }
        ) { id, currentId, movingTo, group, expanded, _onToggle  in
            HStack(alignment: .top, spacing: 0) {
                CatalogsExplorerRowCtrl(id: id, group: group, expanded: expanded, onToggle: _onToggle)
                    .padding(2, 2, 0, 0)
                if let task = tasks.tasks[id] {
                    TasksOmniTask(
                        data: task,
                        active: id == currentId,
                        expanded: expanded ?? false,
                        onSubmit: onTaskEditSubmit,
                        onTab: onTaskTab,
                        onDelete: onTaskEditDelete,
                        onToggleExpand: _onToggle
                    )
                }
            }
            .if(id == tasks.lastInsertedTaskId) { $0.transition(.expand) }
            .modifier(id == currentId ? OmniStyle.hovered.with(padding: .md) : OmniStyle.normal.with(padding: .md))
            .padding(2, 0)
        }
    }
    
    func onTaskSelect(id: UUID) {
        if let task = tasks.tasks[id], task.parent != nil {
            Modules.tasks.loadTasks(parent: task.id, block: task.block, project: task.project)
        }
    }
    
    func onToggle(id: UUID, expand: Bool) {
        guard let task = tasks.tasks[id] else { return }
        Modules.tasks.toggle(task: task, expand: expand)
        Modules.tasks.loadTasks(parent: task.id, block: task.block, project: task.project)
    }
    
    func onTaskMove(id: UUID, to: UUID, edge: Edge) {
    }
    
    func onTaskEditDelete(t: Models.Task) {
        if t.title.isEmpty {
//            if t.parent == nil {
//                Modules.tasks.delete(task: t, for: data)
//            } else {
//                t.parent = nil
//            }
            return
        }
    }
    
    func onTaskEditSubmit(t: Models.Task) {
        if t.title.isEmpty {
            onTaskEditDelete(t: t)
            return
        }
        
//        let task = Modules.tasks.create(for: data, prev: t)
//        print("b", task?.title, Modules.tasks.tasks[task!.id]!.title)
//        vars.focus = .row(id: task?.id.uuidString ?? "")
        input.focus = .none
    }
    
    func onTaskTab(task: Models.Task) {
        Modules.tasks.sub(task: task)
    }
    
    func onCreateTask() {
        let task = Modules.tasks.createTaskAtEnd(catalogId: catalogId)
        input.focus = .row(id: task?.id ?? Consts.uuid)
    }
}

struct TasksFeatureTaskListFooter: View {
    var catalogId: UUID
    
    @Environment(\.input) var input

    var body: some View {
        HStack {
            Button(action: createTask) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Spacer().frame(width: 10)
                
                Text("New Task")
            }
            .buttonStyle(.omni.with(visual: .secondary, padding: .md))
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
    
    func createTask() {
        let task = Modules.tasks.createTaskAtEnd(catalogId: catalogId)
        input.focus = .title(id: task?.id ?? Consts.uuid)
    }
}
