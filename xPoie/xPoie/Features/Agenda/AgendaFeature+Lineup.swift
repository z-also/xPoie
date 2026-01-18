import SwiftUI

struct AgendaLineup: View {
    let tasks: [Models.Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "sun.max")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundStyle(.orange)
                .padding(.leading, 12)
            
            ForEach(tasks, id: \.id) { task in Task(task: task) }
        }
    }
}

fileprivate struct Task: View {
    let task: Models.Task
    
    @Environment(\.theme) var theme
    
    var body: some View {
        let done = task.status == .done
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(task.startAt!, format: .dateTime.hour().minute())
                    .font(size: .xxs)
                    .foregroundStyle(theme.text.secondary)

                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 3, height: 3)
                    .foregroundStyle(theme.text.quaternary)

                Text(Cal.duration(from: task.startAt!, to: task.endAt!))
                    .font(size: .xxs, weight: .light)
                    .foregroundStyle(theme.text.secondary)
            }

            HStack {
                TasksOmniTaskHeader(
                    data: task,
                    field: .title(id: task.id),
                    menu: false
                )
                
                Spacer()
                
                Button(action: { onToggle(done: !done) }) {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle.dashed")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundStyle(done ? theme.semantic.brand : theme.text.quaternary)
                }
                .buttonStyle(.plain)
            }
            .padding(4, 6, 6, 10)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.red)
                    .frame(width: 3)
                    .padding(.leading, 2)
            }
        }
        .contentShape(Rectangle())
        .modifier(OmniStyle(visual: .btn))
    }
    
    private func onToggle(done: Bool) {
        task.status = done ? .done : .none
    }
    
    func onTaskEditSubmit(t: Models.Task) {
    }
    
    func onTaskTab(task: Models.Task) {
        Modules.tasks.sub(task: task)
    }
    func onTaskEditDelete(t: Models.Task) {
    }
    func onToggle(id: UUID, expand: Bool) {
//        guard let task = tasks.tasks[id] else { return }
//        Modules.tasks.toggle(task: task, expand: expand)
//        Modules.tasks.loadTasks(parent: task.id, block: task.block, project: task.project)
    }
}
