import RTex
import SwiftUI
import SwiftData

struct NoteEditor: View {
    var note: Models.Note
    var active: Bool
    var onSelectionChanged: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading) {
            NoteEditorTitle(note: note)
            NoteEditorContent(note: note)
        }
        .padding(8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func onTap() {
        Modules.pads.active(note: note)
    }
}

struct NoteEditorTitle: View {
    let note: Models.Note
    let field: Field
    let behavior: OmniField.Behavior
    
    @Environment(\.input) var input
    
    init(note: Models.Note, behavior: OmniField.Behavior = .auto) {
        self.note = note
        self.behavior = behavior
        field = .title(id: note.id)
    }

    var body: some View {
        HStack(spacing: 0) {
            OmniField(note.title, placeholder: "title of note")
                .behavior(behavior)
                .field(field, focus: input.focus == field)
                .style(typography: .h3)
                .on(focus: onFocus, edit: onEdit, submit: onSubmit, tab: onTab)
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { input.focus = field }
    }
    
    private func onFocus() {
        input.focus = field
        Modules.pads.active(note: note)
    }
    
    private func onEdit(value: String) {
        note.title = value
    }
    
    private func onTab() -> Bool {
        input.focus = .content(id: note.id)
        return true
    }
    
    private func onSubmit() -> Bool {
        input.focus = .content(id: note.id)
        return true
    }
}

struct NoteEditorContent: View {
    var note: Models.Note
    let field: Field

    @Environment(\.input) var input
    
    init(note: Models.Note) {
        self.note = note
        field = .content(id: note.id)
    }

    var body: some View {
        OmniRTex(note.content, placeholder: "contents ...", height: 100)
            .field(field, focus: input.focus == field)
            .behavior(.omni)
            .on(focus: onFocus, edit: onEdit)
            .style(typography: .body)
    }
    
    private func onFocus() {
        input.focus = field
        Modules.pads.active(note: note)
    }
    
    private func onEdit(value: AttributedString) {
        note.content = value
    }
}
