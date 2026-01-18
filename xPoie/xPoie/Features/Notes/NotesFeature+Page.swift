import SwiftUI

struct NotesFeaturePage: View {
//    let note: Models.Note
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: 32)
            
            VStack {
//                Header(note: note)
//                NoteEditorContent(note: note)
                Text("haha")
            }
                .frame(maxWidth: 620, maxHeight: .infinity)

            Spacer()
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.white)
    }
}

fileprivate struct Header: View {
    let note: Models.Note
    
    var body: some View {
        HStack {
            IconPicker(icon: note.icon, color: note.color, size: 16) { i, c in
                note.icon = i
                note.color = c
            }
            
            NoteEditorTitle(note: note, behavior: .alwaysEditable)
                .padding(4, 16)
        }
    }
}
