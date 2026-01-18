import SwiftUI

struct NotesFeatureBrowse: View {
    var search: String
    
    @Environment(\.notes) var notes
    @State private var candidate: Models.Note?
    
    var body: some View {
        HStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        Text("Pinneds").typography(.caption, weight: .medium)
                        Spacer()
                    }
                    .padding(0, 4)
                    
                    ForEach(notes.pinneds.data, id: \.uuidString) { id in
                        if let note = notes.notes[id] {
                            NoteEntry(note: note, hovered: candidate?.id == id)
                                .onHover{ yes in
                                    if yes {
                                        candidate = note
                                    }
                                }
                        }
                    }
                }
                .padding(8)
            }
            if !search.isEmpty && candidate != nil {
                NotePreview(note: candidate!)
                    .frame(width: 480)
            }
        }
        .padding(4, 0)
        .frame(idealHeight: 160, maxHeight: 260)
    }
}

fileprivate struct NoteEntry: View {
    let note: Models.Note
    
    let hovered: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(note.title)
                Spacer()
            }
            .padding(6, 12)
        }
        .buttonStyle(.omni.with(active: hovered))
    }
}

fileprivate struct NotePreview: View {
    let note: Models.Note
    
    var body: some View {
        VStack {
            NoteEditorTitle(note: note)
        }
    }
}
