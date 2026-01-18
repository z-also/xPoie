import SwiftUI

struct InboxTasks: View {
    @Environment(\.vars) var vars
    @Environment(\.tasks) var tasks
    @Environment(\.theme) var theme
    @Environment(\.agenda) var agenda
    
    @State var expanded = true

    var body: some View {
        VStack(alignment: .leading) {
            Header(expanded: expanded, toggle: toggle)
                .padding(0, 4)
            
            HStack(spacing: 6) {
                BreadHeader(icon: "sun.horizon", title: "随时(2)", expanded: false)
                BreadHeader(icon: "sun.horizon", title: "随时(2)", expanded: false)
                BreadHeader(icon: "sun.horizon", title: "随时(2)", expanded: false)
                BreadHeader(icon: "sun.horizon", title: "随时(2)", expanded: false)
            }
            
            if expanded {
                TasksFeatureTaskList(catalogId: Consts.uuid2)
            }
            
//            AgendaLineup(tasks: agenda.tasks)
        }
        .padding(10)
    }
    
    private func toggle() {
        withAnimation {
            expanded.toggle()
        }
    }
}

fileprivate struct Header: View {
    var expanded: Bool
    var toggle: () -> Void
    
    var body: some View {
        HStack {
            Text("Tasks")
                .typography(.h5)
            
            Button(action: {  }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(.omni.with(size: .btn))

            Spacer()
        }
    }
}

fileprivate struct BreadHeader: View {
    let icon: String
    let title: String
    let expanded: Bool
    
    @Environment(\.theme) var theme
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundStyle(theme.semantic.brand)
            
            Text(title)
            
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 5, height: 9)
                .rotationEffect(.degrees(expanded ? 90 : 0))
        }
        .buttonStyle(.omni.with(visual: .secondary.capsule, padding: .md))
    }
}
