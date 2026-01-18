import SwiftUI

struct NotesProjectPicker: View {
    let project: Models.Project?
    let onSelect: (UUID) -> Void
    let onToggle: (UUID, Bool) -> Void

    @State private var selecting = false
    
    var body: some View {
        Button(action: { selecting.toggle() }) {
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
        .popover(isPresented: $selecting) {
            ProjectsCatalog(
                onSelect: { id in
                    onSelect(id)
                    selecting.toggle()
                },
                onToggle: onToggle,
                filterTypes: [.pad]
            )
                .padding(6)
                .frame(width: 320, height: 480)
        }
    }
}
