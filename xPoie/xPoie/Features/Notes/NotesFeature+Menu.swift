import SwiftUI

struct NotesFeatureMenu: View {
    let note: Models.Note
    let visible: Bool
    let scenary: Scenary
    
    @State private var active = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        Button(action: { active.toggle() }) {
            Image(systemName: "ellipsis")
                .resizable()
                .frame(width: 15, height: 3)
                .padding(6.5, 4)
        }
        .opacity(visible || active ? 1 : 0)
        .buttonStyle(.omni.with(active: active))
        .popover(isPresented: $active) {
            VStack(alignment: .leading) {
                Button(action: sticky) {
                    Label("Sticky", systemImage: "pin.fill")
                        .imageScale(.small)
                    Spacer()
                }
                .buttonStyle(.omni.with(padding: .md))
                
                Button(action: pin) {
                    let pinned = !note.pinned.isEmpty
                    Label(pinned ? "Unpin" : "Pin to top", systemImage: pinned ? "pin.slash" : "pin")
                        .imageScale(.small)
                    Spacer()
                }
                .buttonStyle(.omni.with(padding: .md))
                
                if scenary != .panel {
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                            .imageScale(.small)
                        Spacer()
                    }
                    .buttonStyle(.omni.with(padding: .md))
                }

                Section {
                    FormSectionHeader(title: "Note Theme")
                    
                    VisualSelect(value: note.visual, options: Consts.visuals, onSelect: onSetNoteVisual)
                }
                
                Slider(
                    value: Binding(
                        get: { note.stickyOpacity },
                        set: { note.stickyOpacity = $0 }
                    ),
                    in: 0...1,
                    onEditingChanged: { editing in
                        //
                    }
                )
            }
            .padding(16, 12, 16, 12)
        }
        .confirmationDialog(
            "Delete Note",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteNote()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func sticky() {
        NotesFeatureSticky.shared.toggleSticky(for: note)
        active.toggle()
    }
    
    private func pin() {
        if note.pinned.isEmpty {
            // Pin the note: find the highest pinned rank and assign next rank
            let pinneds = Modules.notes.notes.values.filter { !$0.pinned.isEmpty }
            let highestPinnedRank = pinneds.max(by: { $0.pinned < $1.pinned })?.pinned ?? ""
            note.pinned = LexoRank.next(curr: highestPinnedRank)
        } else {
            // Unpin the note
            note.pinned = ""
        }
        active.toggle()
    }
    
    private func onSetNoteVisual(visual: Option<String, Visual>) {
        note.visual = visual.id
    }
    
    private func onSetNotePresenter(presenter: Option<String, Presenter>) {
        note.presenter = presenter.value.name
    }

    private func onDelete() {
        active = false
        showDeleteConfirmation = true
    }
    
    private func deleteNote() {
        // Close sticky window if it exists
        NotesFeatureSticky.shared.closeSticky(for: note)
        Modules.notes.delete(note: note)
    }
}
