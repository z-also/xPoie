import SwiftUI

struct ProjectsFeaturePicker: View {
    let project: Models.Project?
    var types: [Models.Project.`Type`] = [.group, .pad, .task]
    let onSelect: (UUID) -> Void

    @State private var isPopoverPresented = false
    
    var body: some View {
        Button(action: { togglePopover(presented: true) }) {
            HStack {
                Image(systemName: "folder")
                    .resizable()
                    .frame(width: 11, height: 11)
                
                Text(project?.title ?? "Inbox")
                    .font(size: .p, weight: .regular)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 10, height: 6)
            }
        }
        .buttonStyle(.omni.with(padding: .sm))
        .popover(isPresented: $isPopoverPresented) {
            ProjectsCatalog(
                onSelect: onSelect,
                onToggle: onToggle,
                filterTypes: types
            )
                .padding(6)
                .frame(width: 320, height: 480)
        }
    }
    
    private func togglePopover(presented: Bool) {
        withAnimation {
            isPopoverPresented = presented
        }
    }
    
    private func onSelect(id: UUID) {
        onSelect(id)
        togglePopover(presented: false)
    }
    
    private func onToggle(id: UUID, active: Bool) {
        
    }
}
