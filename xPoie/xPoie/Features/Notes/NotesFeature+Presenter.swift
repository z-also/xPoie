import SwiftUI

struct NotesFeaturePresenter: View {
    let note: Models.Note
    let active: Bool
    var onSelectionChanged: (() -> Void)? = nil
    
    @State private var hovered = false

    var body: some View {
        NoteEditor(note: note, active: active, onSelectionChanged: onSelectionChanged)
            .modifier(InApp(note: note, active: active, hovered: hovered))
            .onHover { hovered = $0 }
    }
}

private struct InApp: ViewModifier {
    let note: Models.Note
    let active: Bool
    let hovered: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
//                .overlay(alignment: .topLeading) {
//                    Circle().frame(width: 8, height: 8).background(.red)
//                        .padding(12, 0, 0, 0)
//                }
            
            NotesFeatureMenu(note: note, visible: active || hovered, scenary: .app)
                .offset(x: -8, y: 8)
        }
            .modifier(OmniStyle.omni.with(visual: Visual.named(note.visual), active: active))
    }
}

private struct AsPanel: ViewModifier {
    let note: Models.Note
    let active: Bool
    let hovered: Bool
    
    @Environment(\.theme) var theme
    
    @State private var hoveringThumbtack = false
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            let visual = Visual.named(note.visual)
            
            content
                .padding(8)
                .ifLet(visual?.background) {
                    let shape = RoundedRectangle(cornerRadius: 10)
                    return $0.background(AnyView($1(theme, hovered, active, shape)))
                }
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                .padding(10)

            NotesFeatureMenu(note: note, visible: active || hovered, scenary: .panel)
                .offset(x: -18, y: 16)
        }
        .opacity(note.stickyOpacity)
    }
}

struct NotesFeaturePresenterSelect: View {
    var value: String
    var options: [Option<String, Presenter>]
    var onSelect: (Option<String, Presenter>) -> Void
    
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(options, id: \.id) { option in
                HStack {
                    Text(option.value.name)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(option)
                }
            }
        }
    }
}
