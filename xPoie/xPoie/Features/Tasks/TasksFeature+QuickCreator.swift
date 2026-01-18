import SwiftUI

struct TasksFeatureQuickCreator: View {
    var task: Models.Task
    var project: Models.Project?
    let onCreate: () -> Void
    let onSelectProject: (UUID) -> Void
    
    @State private var schedule: [Date?] = [nil, nil]
    @State private var isSchedulePickerPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                ProjectsFeaturePicker(
                    project: project,
                    types: [.task],
                    onSelect: onSelectProject
                )
                Spacer()
            }
            .padding(6, 12, 12, 12)
            
            Editor(
                title: task.title,
                onEdit: onEdit,
                onSubmit: onSubmit,
                onPressTab: onPressTab
            )
                .padding(0, 20)
            
            // 底部栏
            Footer(
                title: task.title,
                schedule: $schedule,
                isSchedulePickerPresented: $isSchedulePickerPresented,
                onCreate: handleCreate,
                onSetSchedule: onSetSchedule,
                onCancelSchedule: onCancelSchedule
            )
        }
    }
    
    private func handleCreate() {
        let trimmed = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var block: Models.Task.Block? = nil
        
        if let project = project {
            // 如果有选中的项目，不使用block
        } else {
            // 如果没有选中项目，使用默认的block
            block = Modules.tasks.blocks[Consts.uuid2]
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            let task = Modules.tasks.createTask(at: 0, parent: nil, block: block, project: project)
            task.title = trimmed
            if let pid = project?.id {
                Modules.projects.select(id: pid)
            }
            Task {
                await Modules.tasks.schedule(task: task, startAt: schedule[0])
                await Modules.tasks.schedule(task: task, endAt: schedule[1])
            }
            Modules.main.switch(scene: project == nil ? .inbox : .projects)
        }

        onCreate()
    }
    
    private func onEdit(title: String) {
        task.title = title
    }
    
    private func onSubmit() {
        
    }
    
    private func onPressTab() {
        isSchedulePickerPresented = true
    }
    
    private func onCancelSchedule() {
        isSchedulePickerPresented = false
    }
    
    private func onSetSchedule(schedule: [Date?]) {
        self.schedule = schedule
        isSchedulePickerPresented = false
    }
}

fileprivate struct Editor: View {
    var title: String
    
    let onEdit: (String) -> Void
    let onSubmit: () -> Void
    let onPressTab: () -> Void
    
    @FocusState private var focus: Bool
    
    @Environment(\.spotlight) private var spotlight
    
    var body: some View {
        OmniField(title, placeholder: "Title")
            .behavior(.auto)
            .style(typography: .body)
//            .field(field, focus: input.focus == field)
            .on(focus: handleFocus, edit: handleEdit, submit: handleSubmit, tab: handlePressTab)
    }
    
    private func handleFocus() {
        
    }
    
    private func handleEdit(value: String) {
        onEdit(value)
    }
    
    private func handleSubmit() -> Bool {
        onSubmit()
        return true
    }
    
    private func handlePressTab() -> Bool {
        onPressTab()
        return true
    }
}

fileprivate struct Footer: View {
    let title: String
    @Binding var schedule: [Date?]
    @Binding var isSchedulePickerPresented: Bool
    
    let onCreate: () -> Void
    let onSetSchedule: ([Date?]) -> Void
    let onCancelSchedule: () -> Void
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { isSchedulePickerPresented.toggle() }) {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 10, height: 10)
                Text(schedule.allSatisfy { $0 == nil } ? "Schedule" : formattedDate)
                    .font(size: .xs, weight: .regular)
            }
            .buttonStyle(.omni.with(padding: .md))
            .popover(isPresented: $isSchedulePickerPresented, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    OmniDatePicker(value: schedule, onCancel: onCancelSchedule, onConfirm: onSetSchedule)
                }
//                .background(theme.fill.primary.padding(-80))
            }
            
            Spacer()
            
            Button(action: onCreate) {
                Text("Create")
            }
            .buttonStyle(.omni.with(visual: .brand.capsule, padding: .lg))
            .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(8, 12, 12, 12)
    }
    
    private var formattedDate: String {
        guard let start = schedule.first ?? nil else { return "Schedule" }
        if schedule.count > 1, let end = schedule[1] {
            return "\(Cal.format(date: start)), \(Cal.duration(from: start, to: end))"
        } else {
            return Cal.format(date: start)
        }
    }
}
