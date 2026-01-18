import SwiftUI

struct InboxToday: View {
    @Environment(\.theme) var theme
    @Environment(\.agenda) var agenda

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today")
                        .typography(.h5)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            AgendaLineup(tasks: agenda.tasks)

//            Line()
//              .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
//              .foregroundStyle(theme.text.secondary.opacity(0.6))
//              .frame(height: 1)
//              .padding(.horizontal, 12)
        }
        .padding(10)
//        .background(RoundedRectangle(cornerRadius: 12).fill(theme.fill.tertiary))
    }
}

fileprivate struct TasksDrawer: View {
    let icon: String
    let title: String
    let expanded: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            BreadHeader(icon: icon, title: title, expanded: expanded)
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
