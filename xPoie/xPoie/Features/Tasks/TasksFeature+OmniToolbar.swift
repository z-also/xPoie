import SwiftUI
import UserNotifications

struct TasksOmniToolbar: View {
    @Bindable var data: Models.Task
    let active: Bool

    var body: some View {
        HStack(spacing: 16) {
            ScheduleSetter(dates: [data.startAt, data.endAt], set: schedule)
            
//            ReminderSetter(reminders: $data.reminders).opacity(active || data.reminders.count > 0 ? 1 : 0)
            
            TasksOmniToolbarExtraMenu(data: data).opacity(active ? 1 : 0)
        }
        .padding(0, 34, 0, 0)
    }

    func schedule(dates: [Date]) {
        let task = data
        Task {
            await Modules.tasks.schedule(task: task, startAt: dates[0])
            await Modules.tasks.schedule(task: task, endAt: dates[1])
        }
    }
}

struct TasksOmniToolbarExtraMenu: View {
    var data: Models.Task
    
    @Environment(\.vars) var vars
    
    @State private var isDeleteAcking = false
    @State private var pendingDelete = false

    var body: some View {
        Menu {
            Button(action: addTaskAbove) {
                Label("Add task above", systemImage: "arrow.up.circle")
            }
            Button(action: addTaskBelow) {
                Label("Add task below", systemImage: "arrow.down.circle")
            }
            if data.parent == nil {
                Button(action: addSubtask) {
                    Label("Add subtask", systemImage: "arrow.turn.down.right.circle")
                }
            }
            Section {
                Button(role: .destructive, action: { isDeleteAcking = true }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            
            
//            Divider().frame(height: 0.5)
//            
//            Picker("Task Type", selection: Binding(get: { data.type }, set: { data.type = $0 })) {
//                Button {
//                    // Duplicate action.
//                } label: {
//                    Label("Normal Task", systemImage: "circle.dashed")
////                    Text("what is normal task")
//                }.tag(Modules.Tasks.`_Type`.task)
//                
//                Button {
//                    // Duplicate action.
//                } label: {
//                    Label("Mileston", systemImage: "diamond.inset.filled")
////                    Text("what is mileston")
//                }.tag(Modules.Tasks.`_Type`.milestone)
//            }
//            .pickerStyle(.inline)
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .frame(width: 15, height: 3)
                .padding(6.5, 4)
        }
        .menuStyle(.button)
        .buttonStyle(.omni.with(padding: .zero))
        .foregroundColor(vars.theme.text.secondary)
        .confirmationDialog("Delete this task?", isPresented: $isDeleteAcking) {
            Button(role: .destructive, action: deleteTask) {
                Text("Yes, delete")
            }
        } message: {
            Text("This action cannot be undone.").typography(.desc)
        }
    }
    
    func addSubtask() {
        let task = Modules.tasks.createSubTask(in: data)
        Modules.input.focus = .title(id: task!.id)
    }
    
    func addTaskAbove() {
        addSibTask(offset: 0)
    }
    func addTaskBelow() {
        addSibTask(offset: 1)
    }
    
    private func addSibTask(offset: Int) {
        let task = Modules.tasks.createTask(near: data, offset: offset)
        Modules.input.focus = .title(id: task!.id)
    }
    
    private func deleteTask() {
        Modules.tasks.delete(task: data)
    }
}

fileprivate struct ScheduleSetter: View {
    let dates: [Date?]
    let set: ([Date]) -> Void

    @State private var editing = false
    @Environment(\.theme) var theme

    var body: some View {
        let _label = label
        ToolbarItem(icon: "calendar.badge.clock", title: _label ?? "Schedule", active: _label != nil) {
            editing.toggle()
        }
        .popover(isPresented: $editing, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                OmniDatePicker(value: dates, onCancel: cancel, onConfirm: confirm)
            }
            .background(theme.fill.popover.padding(-80))
        }
    }
    
    private var label: String? {
        if dates.isEmpty || dates.allSatisfy({ $0 == nil }) {
            return nil
        }
        
        guard let start = dates[0], let end = dates[1] else {
            return nil
        }

        let s = Cal.format(date: start)
        
        return "\(s), \(Cal.duration(from: start, to: end))"
    }
    
    func cancel() {
        editing = false
    }
    func confirm(dates: [Date]) {
        editing = false
        set(dates)
    }
}

fileprivate struct ToolbarItem: View {
    var icon: String?
    var title: String
    var active: Bool = false
    var action: () -> Void
    
    @Environment(\.theme) var theme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 11, height: 11)
                }
                Text(title).font(.system(size: 11))
            }
            .padding(2, 0)
            .foregroundStyle(active ? .orange : theme.text.tertiary)
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct ReminderSetter: View {
    @State var editing = false
    @Binding var reminders: [Models.Task.Reminder]
    
    @State private var isShowingPopover = false
    
    @Environment(\.theme) var theme
    
    init(reminders: Binding<[Models.Task.Reminder]>) {
        self._reminders = reminders
    }
    
    var body: some View {
        Button(action: {
            isShowingPopover.toggle()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "bell")
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Text(reminderText)
                    .font(.system(size: 11))
            }
            .padding(4, 0, 6, 0)
            .foregroundColor(theme.text.tertiary)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isShowingPopover, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reminders")
                    .typography(.h6)
                
                // 显示已设置的提醒列表
                if !reminders.isEmpty {
                    ForEach(reminders, id: \.id) { reminder in
//                        HStack {
//                            OmniDatePicker(
//                                value: [nil],
//                                onCancel: {
//                                   //
//                                },
//                                onConfirm: {
//                                   //
//                                }
//                            )
//                        }
                        OmniDatePickerPresenter(
                            dates: [reminder.time],
                            trigger: {
                                
                            },
                            reset: {
                                
                            }
                        )
                    }
                    Divider().frame(height: 0.5)
                }
                
                OmniDatePickerPresenter(
                    dates: [],
                    trigger: {
                        editing.toggle()
                    },
                    reset: {
                        
                    }
                )
                .popover(isPresented: $editing, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 16) {
                        OmniDatePicker(value: [nil], onCancel: {
                            
                        }, onConfirm: { v in
                            Task {
                                await onConfirm(date: v[0])
                                editing = false
                            }
                        })
                    }
                    .background(theme.fill.primary.padding(-80))
                }

                // 添加新提醒的日期选择器
//                OmniDatePicker(
//                    onConfirm: { date in
//                        Task {
//                            await onConfirm(date: date)
//                        }
//                    },
//                    presenter: {
//                        OmniDatePickerPresenter(date: $0, trigger: $1, reset: onReset)
//                    }
//                )
            }
            .padding(16)
            .frame(width: 240, alignment: .leading)
            .background(theme.fill.primary.padding(-80))
        }
    }
    
    private var reminderText: String {
        if reminders.isEmpty {
            return "Add Reminder"
        } else if reminders.count == 1 {
            return "1 Reminder"
        } else {
            return "\(reminders.count) Reminders"
        }
    }
    
    func onConfirm(date: Date) async {
        // 检查权限
        guard await Notifications.checkAuthorizationStatus() == .authorized else {
            // 请求权限
            guard ((try? await Notifications.requestAuthorization()) != nil) else { return }
            return
        }
        
        // 创建新的 Reminder
        let reminder = Models.Task.Reminder(time: date)
        reminders.append(reminder)
        
        // 创建系统通知
        let identifier = "task_reminder_\(reminder.id)"
        try? await Notifications.scheduleNotification(
            at: date,
            title: "Task Reminder",
            body: "Your task is due now",
            identifier: identifier
        )
    }
    
    func onReset() {
        // 取消所有相关的系统通知
        Task {
            let notifications = await Notifications.getPendingNotifications()
            let identifiers = notifications.map { $0.identifier }
                                          .filter { $0.hasPrefix("task_reminder_") }
            Notifications.cancelNotification(withIdentifiers: identifiers)
        }
        reminders.removeAll()
    }
    
    func removeReminder(_ reminder: Models.Task.Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        // 取消对应的系统通知
        let identifier = "task_reminder_\(reminder.id)"
        Notifications.cancelNotification(withIdentifier: identifier)
    }
    func updateReminder(_ reminder: Models.Task.Reminder, with date: Date) async {
        // 取消旧的通知
        let oldIdentifier = "task_reminder_\(reminder.id)"
        Notifications.cancelNotification(withIdentifier: oldIdentifier)
        
        // 更新提醒时间
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].time = date
            
            // 创建新的系统通知
            try? await Notifications.scheduleNotification(
                at: date,
                title: "Task Reminder",
                body: "Your task is due now",
                identifier: oldIdentifier
            )
        }
    }
}

