import Llmx
import SwiftUI

struct PadFeatureToolbar: View {
    @Environment(\.pads) private var pads
    
    let resetIntent: () -> Void
    let takeSnapshot: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Button(action: newNote) {
                    Label("New Note", systemImage: "text.rectangle.page")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.omni)
                Button(action: takeSnapshot) {
                    Label("New Note", systemImage: "text.rectangle.page")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.omni)
                
                Button(action: tryLlmx) {
                    Label("New Note", systemImage: "text.rectangle.page")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.omni)
                
                Button(action: {}) {
                    Label("New Note", systemImage: "text.rectangle.page")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.omni)
                
                if pads.immersive {
                    Button(action: toggleNodeSticky) {
                        Label("Sticky", systemImage: "pin")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.omni.with(active: true))
                }
                
                Button(action: toggleGlim) {
                    Label("New Note", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.omni.with(active: true))
            }
            .padding(6, 10)
            .controlSize(.regular)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress { keyPress in
            if keyPress.key == .escape && pads.intent != .none {
                resetIntent()
                return .handled
            }
            return .ignored
        }

        .frame(maxWidth: .infinity)
    }
    
    private func newNote() {
        pads.set(intent: .new)
    }
    
    private func toggleNodeSticky() {
        if let note = pads.editingNote {
            NotesFeatureSticky.shared.toggleSticky(for: note)
        }
    }
    
    private func tryLlmx() {
    }
    
    private func toggleGlim() {
        Modules.glim.present(Modules.glim.presentation == .none ? .inapp : .none)
    }
}
