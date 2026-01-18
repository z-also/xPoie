import SwiftUI

struct SpotlightNotes: View {
    @State private var search: String = ""
    
    @Environment(\.spotlight) private var spotlight

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ActionBar()
            
            if spotlight.noteScene == .create {
                Create(onSubmit: submitNewNoteCreate)
            }
            if spotlight.noteScene == .research {
                Research()
            }
            if spotlight.noteScene == .browse {
                VStack {
                    NotesFeatureBrowse(search: search)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func submitNewNoteCreate() {
        if let note = Modules.spotlight.submitNewNoteCreate() {
            //
        }
    }
}

fileprivate struct ActionBar: View {
    @Environment(\.spotlight) var spotlight

    var body: some View {
        HStack {
            if spotlight.noteScene != .browse {
                Button(action: { `switch`(scene: .browse) }) {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 16, height: 12)
                }
                    .buttonStyle(.omni)
            }
            
            Button(action: { `switch`(scene: .create) }) {
                Label("Note", systemImage: "plus")
                    .padding(.vertical, 2)
            }
            .buttonStyle(.omni.with(active: spotlight.noteScene == .create))
            
            Button(action: { `switch`(scene: .research) }) {
                Label("Research", systemImage: "wand.and.sparkles.inverse")
                    .padding(.vertical, 2)
            }
            .buttonStyle(.omni.with(active: spotlight.noteScene == .research))

            Spacer()
        }
        .padding(6, 12)
        .font(.system(size: 12))
    }
    
    private func `switch`(scene: Modules.Spotlight.NoteScene) {
        Modules.spotlight.set(noteScene: scene)
    }
}

fileprivate struct Create: View {
    let onSubmit: () -> Void
    
    @Environment(\.spotlight.newNote) var newNote
    
    let field: Field = .content(id: Consts.uuid)

    var body: some View {
        VStack(spacing: 6) {
            let project = newNote.parent == nil ? nil : Modules.projects.projects[newNote.parent!]
            HStack(alignment: .center, spacing: 0) {
                ProjectsFeaturePicker(
                    project: project,
                    types: [.pad],
                    onSelect: { id in
                        Modules.spotlight.newNote.parent = id
                    }
                )
                Spacer()
            }
            .padding(6, 12, 0, 12)
            
            ScrollView {
                NoteEditor(note: newNote, active: true)
                    .padding(4, 10)
                Spacer()
            }
            .frame(idealHeight: 120, maxHeight: 200)
            .overlay(alignment: .bottomTrailing) {
                Button(action: onSubmit) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6, 6)
                }
                .offset(x: -12, y: -12)
                .keyboardShortcut(.return)
                .buttonStyle(.omni.with(visual: .primaryBtn.circled))
                .disabled(newNote.content.characters.isEmpty)
            }
        }
    }
    
    private func onEdit(value: AttributedString) {
        Modules.spotlight.newNote.content = value
    }
}

fileprivate struct Research: View {
    @State private var content = ""
    @Environment(\.input) private var input
    @Environment(\.theme) private var theme

    let field: Field = .misc(tag: "research")
    
    var body: some View {
        VStack {
            OmniField(content, placeholder: "Topic")
                .behavior(.always)
                .field(field, focus: input.focus == field)
                .style(typography: .medium)
                .on(focus: onFocus, edit: onEdit, submit: onSubmit, tab: onTab)
                .padding(12, 16, 6, 16)

            HStack(alignment: .bottom) {
                Button(action: {}) {
                    Label("Note", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.omni)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6, 6)
                }
                .keyboardShortcut(.return)
                .buttonStyle(.omni.with(visual: .primaryBtn.circled))
                .disabled(content.isEmpty)
            }
            .padding(6, 16)
//            .background(theme.fill.tertiary)
        }
    }
    
    private func onFocus() {
        withAnimation { input.focus = field }
    }
    
    private func onEdit(value: String) {
        content = value
    }
    
    private func onSubmit() -> Bool {
        return true
    }
    
    private func onTab() -> Bool {
        return true
    }
}
