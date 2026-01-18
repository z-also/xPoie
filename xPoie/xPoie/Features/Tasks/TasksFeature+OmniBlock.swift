import SwiftUI

struct TasksOmniBlock: View {
    var data: Models.Task.Block
    var catalog: Collection<UUID>
    var expanded: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Header(data: data, expanded: expanded, empty: catalog.data.isEmpty)

            if expanded {
                TasksFeatureTaskList(catalogId: data.id)
                    .padding(.leading, 6)
                
                TasksFeatureTaskListFooter(catalogId: data.id)
                    .padding(.leading, 26)
            }
        }
        .padding(4, 2, 4, 2)
    }
}

fileprivate struct Header: View {
    private var data: Models.Task.Block
    private var empty: Bool
    private var expanded: Bool
    private var titleField: Field
    private var notesField: Field
    
    @State var hovered: Bool = false
    @State var descHeight: CGFloat = 60
    
    @Environment(\.theme) var theme
    @Environment(\.input) var input
    
    init(data: Models.Task.Block, expanded: Bool, empty: Bool) {
        self.data = data
        self.empty = empty
        self.expanded = expanded
        self.titleField = .title(id: data.id)
        self.notesField = .notes(id: data.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                Button(action: { toggleExpand() }) {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .frame(width: 6.5, height: 11)
                        .foregroundStyle(theme.text.secondary)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                }
                .buttonStyle(.omni.with(size: .xs))
                
                OmniField(data.title, placeholder: "Untitled")
                    .field(titleField, focus: input.focus == titleField)
                    .style(typography: .h5)
                    .on(focus: onTitleFocus, edit: onTitleEdit, submit: onTitleEditSubmit)
                    .padding(1.5, 0, input.focus == titleField ? 0 : 1, 0)
                    .onTapGesture(perform: toggleExpand)

                Spacer().frame(width: 6)

                Group {
                    Button(action: { createTask() }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 10, height: 10)
                    }
                    .buttonStyle(.omni.with(size: .btn))

                    Menu {
                        Button(action: { rename() }) {
                            Label("Rename", systemImage: "pencil.and.outline")
                        }
                        Button(action: { createBlockAbove() }) {
                            Label("Add Block above", systemImage: "arrow.up.circle")
                        }
                        Button(action: { createBlockBelow() }) {
                            Label("Add Block below", systemImage: "arrow.down.circle")
                        }
                        Button(action: { createTask() }) {
                            Label("Add task", systemImage: "plus.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 15, height: 3)
                    }
                    .buttonStyle(.omni.with(size: .btn))
                }
                .opacity(hovered && input.focus != titleField ? 1.0 : 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(0, 32, 0, 12)
        .contentShape(Rectangle())
        .onHover { h in hovered = h }
    }
    
    func toggleExpand() {
        Modules.tasks.toggle(block: data)
    }
    
    func createTask() {
        if !Modules.tasks.expandeds[data.id, default: false] {
            Modules.tasks.toggle(block: data)
        }
        let task = Modules.tasks.createTask(at: 0, parent: nil, block: data, project: nil)
        input.focus = .title(id: task.id)
    }
    
    func createBlockAbove() {
        guard let pid = data.project else { return }
        if let catalog = Modules.tasks.projects[pid],
           let index = catalog.data.firstIndex(of: data.id) {
            let block = Modules.tasks.createBlock(at: index, in: pid)
            if let block = block {
                input.focus = .title(id: block.id)
            }
        }
    }
    
    func createBlockBelow() {
        guard let pid = data.project else { return }
        if let catalog = Modules.tasks.projects[pid],
           let index = catalog.data.firstIndex(of: data.id) {
            let block = Modules.tasks.createBlock(at: index + 1, in: pid)
            if let block = block {
                input.focus = .title(id: block.id)
            }
        }
    }
    
    private func onTitleFocus() {
    }
    
    private func onTitleEdit(value: String) {
        data.title = value
    }
    
    private func onTitleEditSubmit() -> Bool {
        if data.title.isEmpty {
            return false
        }
        
        if !expanded {
            Modules.tasks.toggle(block: data)
        }
        
        Modules.input.focus = .none
        
        if empty {
            let t = Modules.tasks.createTask(at: 0, parent: nil, block: data, project: nil)
            Modules.input.focus = .title(id: t.id)
        }
        
        return true
    }
    
    private func onDescEditSubmit() {
        if Modules.tasks.catalogs[data.id]!.data.isEmpty {
            let task = Modules.tasks.createTask(at: 0, parent: nil, block: data, project: nil)
            input.focus = .row(id: task.id)
        } else {
            input.focus = .none
        }
    }
    
    private func rename() {
        withAnimation {
            input.focus = titleField
        }
    }
}


fileprivate struct Footer: View {
    var data: Models.Task.Block
    var createTask: () -> Void
    
    var body: some View {
        HStack {
            Button(action: createTask) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Spacer().frame(width: 14)
                
                Text("New Task")
            }
            .buttonStyle(.omni.with(visual: .secondary, padding: .md))
        }
        .padding(.horizontal, 8)
    }
}

struct TasksBlockCreateControl: View {
    var action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "wand.and.sparkles.inverse")
                    .resizable()
                    .fontWeight(.black)
                    .frame(width: 14, height: 14)
                
                Spacer().frame(width: 12)
                
                Text("New block")
            }
            .buttonStyle(.omni.with(padding: .lg))
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
