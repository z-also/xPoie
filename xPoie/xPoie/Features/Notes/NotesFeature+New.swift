import SwiftUI

struct NotesFeatureNew: View {
    @Environment(\.theme) var theme
    @Environment(\.input) var input
    
    let pid: UUID
    let titleField: Field = .title(id: Consts.uuid)
    let contentField: Field = .content(id: Consts.uuid)

    @State var title: String = ""
    @State var content = AttributedString("")

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            OmniField(title, placeholder: "Type a title")
                .behavior(.always)
                .field(titleField, focus: input.focus == titleField)
                .style(typography: .h4)
                .on(focus: onTitleFocus, edit: onTitleEdit, submit: onTitleSubmit, tab: onTitleTab)
            
            OmniRTex(content, placeholder: "contents ...", height: 100)
                .field(contentField, focus: input.focus == contentField)
                .behavior(.omni.with(autofocus: false))
                .on(focus: onContentFocus, edit: onContentEdit, submit: onSubmit)
                .style(typography: .body)
                .padding(10, 0, 0, 10)
                .modifier(OmniStyle.omni.with(visual: .embedField, padding: .zero, active: input.focus == contentField))

            HStack {
                Spacer()
                Button(action: onCreate) {
                    Text("create")
                }
                .buttonStyle(.omni.with(visual: .brand))
            }
        }
    }
    
    private func onTitleFocus() {
        input.focus = titleField
    }
    
    private func onTitleEdit(value: String) {
        title = value
    }
    
    private func onTitleSubmit() -> Bool {
        return true
    }
    
    private func onTitleTab() -> Bool {
        input.focus = contentField
        return true
    }
    
    private func onContentFocus() {
        input.focus = contentField
    }
    
    private func onContentEdit(value: AttributedString) {
        content = value
    }
    
    private func onCreate() {
        if let note = Modules.notes.createNote(at: 0, in: pid, frame: .zero) {
            note.title = title
            note.content = content
        }
    }
    
    private func onSubmit() -> Bool {
        onCreate()
        return true
    }
}
