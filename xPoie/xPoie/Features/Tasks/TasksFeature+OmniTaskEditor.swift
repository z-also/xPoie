import SwiftUI

struct TasksOmniTaskEditor: View {
    var task: Models.Task
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    
    @Environment(\.vars) var vars
    @Environment(\.input) var input
    @Environment(\.events) var events
    @Environment(\.calendar) var calendar

    init(task: Models.Task) {
        self.task = task
        self.title = task.title;
        self.startDate = Date.now
        self.endDate = Date.now
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Title").font(size: .p, weight: .medium)
            let titleField: Field = .title(id: task.id)

            OmniField(title, placeholder: "what is your task?")
                .style(typography: .h5)
                .field(titleField, focus: input.focus == titleField)
                .on(
                    focus: {
                        input.focus = titleField
                    },
                    edit: { task.title = $0 },
                    submit: {
                        return true
                    }
                )
                .padding(4, 2)
                .modifier(OmniStyle.omni.with(visual: .field, active: input.focus == titleField))
                .onTapGesture {
                    withAnimation {
                        input.focus = titleField
                    }
                }
                .task {
                    withAnimation {
                        input.focus = titleField
                    }
                }

            ScheduleSetter(
                dates: [task.startAt, task.endAt],
                set: { dates in
                    if dates.count > 0 { self.startDate = dates[0]; task.startAt = dates[0] }
                    if dates.count > 1 { self.endDate = dates[1]; task.endAt = dates[1] }
                }
            )
            
            HStack {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 14, height: 14)
            }
            
            HStack {
                Spacer()
                
                Button(action: {}) {
                    Text("Cancel")
                }
                .buttonStyle(.omni.with(visual: .cancelBtn, padding: .lg))
                
                Button(action: {}) {
                    Text("Confirm")
                }
                .buttonStyle(.omni.with(visual: .brand, padding: .lg))
            }
        }
        .padding(.all, 24)
        .frame(width: 400, alignment: .topLeading)
    }
}

fileprivate struct ScheduleSetter: View {
    let dates: [Date?]
    let set: ([Date]) -> Void

    @State private var editing = false
    @Environment(\.input) var input
    @Environment(\.theme) var theme

    var body: some View {
        HStack {
            Image(systemName: "clock")
                .resizable()
                .frame(width: 14, height: 14)

            Button(action: {
                editing.toggle()
                input.focus = .none
            }) {
                if let (start, end, duration) = label {
                    HStack(spacing: 2) {
                        Text(start)
                            .font(.system(size: 11))
                        
                        Text("-")
                            .foregroundStyle(theme.text.tertiary)
                        
                        Text(end)
                            .font(.system(size: 11))
                        
                        Text(" (\(duration))")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                    }
                    .fixedSize()
                } else {
                    Text("Schedule")
                        .font(.system(size: 11))
                        .foregroundStyle(theme.text.tertiary)
                }
                
                Spacer().frame(height: 22)
            }
            .buttonStyle(.omni.with(visual: .field, padding: .md, active: editing))
            .popover(isPresented: $editing, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    OmniDatePicker(value: dates, onCancel: cancel, onConfirm: confirm)
                }
                .background(theme.fill.popover.padding(-80))
            }
        }
    }
    
    private var label: (String, String, String)? {
        if dates.isEmpty || dates.allSatisfy({ $0 == nil }) {
            return nil
        }
        
        guard let start = dates[0], let end = dates[1] else {
            return nil
        }
        let startStr = Cal.format(date: start)
        let endStr = Cal.format(date: end)
        let durationStr = Cal.duration(from: start, to: end)
        return (startStr, endStr, durationStr)
    }
    
    func cancel() {
        editing = false
    }
    func confirm(dates: [Date]) {
        editing = false
        set(dates)
    }
}
