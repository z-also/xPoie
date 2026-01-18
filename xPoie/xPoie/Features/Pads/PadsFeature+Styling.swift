import SwiftUI

struct PadsFeatureStyling: View {
    let pad: Models.Pad
    
    @Environment(\.theme) var theme
    @Environment(\.pads.activeNote) var note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Section {
                FormSectionHeader(title: "Page Layout")
                
                PickerButtons(options: Consts.padLayoutOptions, selection: pad.layout, onSelect: selectLayout)
            }
            
            Line().background(theme.fill.secondary).frame(height: 1)

            Section {
                FormSectionHeader(title: "Note Theme")
                
                VisualSelect(value: note?.visual ?? "", options: Consts.visuals, onSelect: onSetNoteVisual)
                    .padding(0, 8)

            }
            
            Line().background(theme.fill.secondary).frame(height: 1)
            
            Section {
                FormSectionHeader(title: "Card Appearance")
                
                NotesFeaturePresenterSelect(value: note?.presenter ?? "", options: Consts.presenters, onSelect: onSetNotePresenter)
            }
        }
    }
    
    private func selectLayout(v: PadLayoutOption) {
        withAnimation {
            pad.layout = v.value
        }
    }
    
    private func onSetNoteVisual(visual: Option<String, Visual>) {
        note?.visual = visual.id
    }
    
    private func onSetNotePresenter(presenter: Option<String, Presenter>) {
        note?.presenter = presenter.value.name
    }
}
