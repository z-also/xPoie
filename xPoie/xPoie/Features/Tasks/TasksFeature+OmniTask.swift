import SwiftUI

struct TasksOmniTask: View {
    var data: Models.Task
    let active: Bool
    let expanded: Bool
    var onSubmit: (Models.Task) -> Void
    var onTab: (Models.Task) -> Void
    var onDelete: (Models.Task) -> Void
    let onToggleExpand: (UUID, Bool) -> Void
    
    @Environment(\.theme) var theme
    @Environment(\.input) var input

    @State private var inited = false
    @State private var height: CGFloat = 32
    @State private var hovered: Bool = false
    
    let titleField: Field
    let notesField: Field

    init(
        data: Models.Task,
        active: Bool,
        expanded: Bool,
        onSubmit: @escaping (Models.Task) -> Void,
        onTab: @escaping (Models.Task) -> Void,
        onDelete: @escaping (Models.Task) -> Void,
        onToggleExpand: @escaping (UUID, Bool) -> Void) {
        self.data = data
        self.active = active
        self.expanded = expanded
        self.onSubmit = onSubmit
        self.onTab = onTab
        self.onDelete = onDelete
        self.onToggleExpand = onToggleExpand
            
        titleField = .title(id: data.id)
        notesField = .content(id: data.id)
    }

    var body: some View {
        HStack(alignment: .top) {
            let done = data.status == .done
            let editing = input.focus == titleField || input.focus == notesField
            
            Button(action: { onToggle(done: !done) }) {
                TaskIcon(task: data).padding(2, 6)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 0) {
                TasksOmniTaskHeader(
                    data: data,
                    field: titleField,
                    menu: !editing && hovered,
                )
                
                if editing || active || !data.notes.characters.isEmpty {
                    TasksOmniTaskNotes(
                        data: data,
                        field: notesField
                    )
                }
                
                if editing || active || (data.startAt != nil && data.endAt != nil) {
                    TasksOmniToolbar(data: data, active: editing || hovered)
                }
            }
        }
        .onHover { hovered = $0 }
    }

    private func onTitleTab() -> Bool {
        input.focus = notesField
        return true
    }
    
    func onToggle(done: Bool) {
        Modules.tasks.toggle(task: data, done: done)
    }
    
    private var schedule: String {
        var components: [String] = []
        
        if let start = data.startAt {
            components.append(Cal.format(date: start))
        }
        
        if let end = data.endAt {
            components.append(Cal.format(date: end))
        }
        
        return components.isEmpty ? "" : components.joined(separator: " - ")
    }
    
}

fileprivate struct Progress: View {
    let task: Models.Task
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            let stats = Modules.tasks.stats(task: task)
            RoundedRectangle(cornerRadius: 2)
                .fill(theme.fill.secondary)
                .frame(width: 26, height: 4)
                .background(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.semantic.brand)
                        .frame(width: 26 * stats.percent, height: 4)
                }
            
            Text("\(stats.dones)/\(stats.total)")
                .font(size: .xs)
                .foregroundStyle(theme.text.tertiary)
        }
    }
}

fileprivate struct TaskIcon: View {
    var task: Models.Task
    
    @Environment(\.theme) var theme

    var body: some View {
        Image(systemName: iconName)
            .resizable()
            .frame(width: 13, height: 13)
            .foregroundStyle(task.status == .done ? theme.semantic.brand : theme.text.quaternary)
    }
    
    var iconName: String {
        if task.status == .done {
            return task.type == .task ? "checkmark.circle.fill" : "checkmark.diamond.fill"
        }
        
        switch task.type {
        case .task:
            return "circle.dashed"
        case .milestone:
            return "diamond.inset.filled"
        }
    }
}

fileprivate struct MenuControl: View {
    let data: Models.Task
    
    var body: some View {
        HStack {
            TasksOmniToolbarExtraMenu(data: data)
        }
    }
}

struct TasksOmniTaskHeader: View {
    let data: Models.Task
    let field: Field
    let menu: Bool
    private let onTab: (() -> Bool)?
    @Environment(\.input) var input

    init(
        data: Models.Task,
        field: Field,
        menu: Bool,
        onTab: (() -> Bool)? = nil
    ) {
        self.data = data
        self.menu = menu
        self.field = field
        self.onTab = onTab
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            OmniField(data.title, placeholder: "Title")
                .behavior(.auto)
                .style(typography: .body)
                .field(field, focus: input.focus == field)
                .on(focus: handleFocus, blur: handleBlur, edit: handleEdit, submit: handleSubmit, tab: handleTab)

            Spacer().frame(width: 6)
            
            if data.count > 0 && input.focus != field {
                Progress(task: data)
                    .frame(width: 60)
                    .padding(.top, 2)
            }
            
            HStack {
                if (data.startAt == nil || data.endAt == nil) {
                    MenuControl(data: data)
                }
            }
            .opacity(menu ? 1 : 0)

            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { input.focus = field }
        }
    }
    
    private func handleFocus() {
        input.focus = field
    }
    
    private func handleBlur() {
        if input.focus == field {
            input.focus = .none
        }
    }
    
    private func handleEdit(value: String) {
        data.title = value
    }

    private func handleSubmit() -> Bool {
        input.focus = .none
        return true
    }
    
    private func handleTab() -> Bool {
        input.focus = .content(id: data.id)
        return true
    }
}

struct TasksOmniTaskNotes: View {
    let data: Models.Task
    let field: Field
    @Environment(\.input) var input
    
    var body: some View {
        HStack {
            OmniRTex(data.notes, placeholder: "Notes", height: 15)
                .field(field, focus: input.focus == field)
                .on(focus: handleFocus, edit: handleEdit, submit: handleSubmit)
                .style(typography: .tip)
            
            Spacer()
        }
        .padding(0, 0, 6, 0)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { input.focus = field }
        }
    }
    
    private func handleFocus() {
        input.focus = field
    }
    
    private func handleEdit(value: AttributedString) {
        data.notes = value
    }
    
    private func handleSubmit() -> Bool {
        input.focus = .none
        return true
    }
}
