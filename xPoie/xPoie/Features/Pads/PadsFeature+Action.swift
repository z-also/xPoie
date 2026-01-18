import SwiftUI

struct PadsFeatureAction: View {
    let pad: Models.Pad
    let project: Models.Project
    
    @Environment(\.theme) var theme
    @Environment(\.pads.activeNote) var note

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Section {
                FormSectionHeader(title: "Note")
                
                Button(action: sticky) {
                    Label("Pin as floating window", systemImage: "pin.fill")
                        .imageScale(.small)
                    Spacer()
                }
                .buttonStyle(.omni.with(visual: .static, padding: .md))
            }
            
            Line().background(theme.fill.secondary).frame(height: 1)
            
            Section {
                FormSectionHeader(title: "Info")
                
                HStack {
                    Image(systemName: "calendar")
                    Text("Created")
                    Spacer()
                    Text(project.createdAt, style: .relative)
                }
                .foregroundStyle(theme.text.secondary)
            }
            
            Line().background(theme.fill.secondary).frame(height: 1)
        }
    }
    
    private func sticky() {
        if let note = note {
            NotesFeatureSticky.shared.toggleSticky(for: note)
        }
    }
}
