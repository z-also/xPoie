import AppKit
import SwiftUI
import RTex

@MainActor class NotesFeatureSticky {
    static let shared = NotesFeatureSticky()
    private var sticky: [UUID: OmniPanel] = [:]
    
    typealias Move = (note: Models.Note, frame: CGRect)
    
    let moveHandler = Throttler<Move>()
    
    init() {
        moveHandler.set(interval: 0.5, action: onMove)
    }
    
    func toggleSticky(for note: Models.Note) {
        if sticky[note.id] != nil {
            close(id: note.id)
            note.sticky = .zero
        } else {
            let content = NoteStickyView(note: note, onClose: close)
            
            if note.sticky == .zero {
                note.sticky = idleFrame(note: note)
            }
            
            let window = OmniPanel(
                content: content,
                frame: note.sticky,
                styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView, .resizable]
            )
            window.omniDelegate = self
            window.pin()
            window.hasShadow = true
            window.makeKeyAndOrderFront(nil)
            sticky[note.id] = window
            
            print("========= sticky", note.content)
        }
    }
    
    private func idleFrame(note: Models.Note) -> CGRect {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return CGRect(x: 60, y: 60, width: 380, height: 520)
        }
        
        let screenFrame = screen.visibleFrame
        let width: CGFloat = 380
        let height: CGFloat = 520
        let margin: CGFloat = 60
        
        let x = screenFrame.maxX - width - margin
        let y = screenFrame.maxY - height - margin
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func closeSticky(for note: Models.Note) {
        close(id: note.id)
        note.sticky = .zero
    }
    
    private func close(id: UUID) {
        guard let window = sticky.removeValue(forKey: id) else { return }
        window.hide()
        window.orderOut(nil)
        window.close()
        Modules.notes.notes[id]?.sticky = .zero
    }
    
    private func onMove(data: Move) {
        data.note.sticky = data.frame
    }
    
    private func find(panel: OmniPanel) -> Models.Note? {
        guard let noteId = sticky.first(where: { $0.value == panel })?.key,
              let note = Modules.notes.notes[noteId] else {
            return nil
        }
        return note
    }
}

extension NotesFeatureSticky: OmniPanel.Delegate {
    func omniPanel(_ panel: OmniPanel, didMove frame: CGRect) {
        if let note = find(panel: panel) {
            moveHandler.exec(params: (note, frame))
        }
    }
}

private struct NoteStickyView: View {
    let note: Models.Note
    let onClose: (UUID) -> Void
    
    @State var hovered = false
    @State private var menuPresented = false
    
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: 4) {
            Titlebar(note: note, active: hovered, onClose: onClose, toggleMenu: toggleMenu)

            ScrollView {
                NoteEditorTitle(note: note, behavior: .alwaysEditable)
                    .padding(4, 16)
                
                NoteEditorContent(note: note)
                    .padding(4, 16)
                
                Spacer()
            }
            .frame(idealHeight: 200)
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(theme.fill.window.opacity(0.6)))
        .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
        .frame(minWidth: 380, idealWidth: 400, minHeight: 80, idealHeight: 400)
        .ignoresSafeArea()
        .overlay {
            if menuPresented {
                VStack {
                    MenuControl(dismiss: toggleMenu)
                        .containerRelativeFrame([.horizontal, .vertical], alignment: .center) { length, axis in
                            axis == .horizontal ? min(length - 48, 348) : min(length - 100, 480)
                        }
                }
                .containerRelativeFrame([.horizontal, .vertical])
                .contentShape(Rectangle())
                .onTapGesture(perform: toggleMenu)
            }
        }
        .onHover { active in
            withAnimation { hovered = active }
        }
    }
    
    private func toggleMenu() {
        withAnimation { menuPresented.toggle() }
    }
}

private struct Titlebar: View {
    let note: Models.Note
    let active: Bool
    let onClose: (UUID) -> Void
    let toggleMenu: () -> Void

    @State var closeHovered = false
    
    var body: some View {
        HStack {
            Text(note.title.isEmpty ? "Note" : note.title)
                .typography(.desc, size: .xs)
                .opacity(active ? 1 : 0.4)
                .lineLimit(1)
                .containerRelativeFrame(.horizontal, alignment: .center) { width, axis in
                    width - 100
                }
        }
        .frame(height: 26)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .leading) {
            Image(systemName: closeHovered ? "xmark.circle.fill" : "circle.fill")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.red)
                .opacity(active ? 1 : 0)
                .onHover{ v in closeHovered = v }
                .padding(.leading, 8)
                .onTapGesture {
                    onClose(note.id)
                }
        }
        .overlay(alignment: .trailing) {
            HStack {
                Button(action: toggleMenu) {
                    Text("⌘+K")
                        .typography(.desc, size: .xs)
                        .opacity(active ? 1 : 0)
                }
                .buttonStyle(.omni.with(padding: .sm))
                .keyboardShortcut("k", modifiers: .command)
            }
            .padding(.horizontal, 6)
        }
    }
}

private struct MenuControl: View {
    let dismiss: () -> Void
    
    @State private var keyword: String = ""
    @State private var current: NotesAction = NotesAction.new
    @State private var isRuningAction = false

    private let items: [[NotesAction]] = [
        [.new, .moveTo],
        [.delete, .focus]
    ]
    
    @FocusState private var focused
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("search", text: $keyword)
                .focused($focused)
                .textFieldStyle(.plain)
                .padding(12)
                .onKeyPress(.escape) {
                    onEscape()
                    return .handled
                }
                .onKeyPress(.downArrow) {
                    onNavKey(step: 1)
                }
                .onKeyPress(.upArrow) {
                    onNavKey(step: -1)
                }
                .onSubmit {
                    onSubmit()
                }
                .onAppear {
                    focused = true
                }
            
            Divider()
                .padding(.bottom, 4)
            
            if !isRuningAction {
                ScrollView(.vertical) {
                    ActionMenus(
                        groups: items,
                        hoveredActionId: current.id,
                        onActionHover: onActionHover
                    )
                }
            } else if current == .moveTo {
                MoveToBrowse(filter: keyword)
            }
        }
        .glassEffect(in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 12)
    }
    
    private func onActionHover(action: NotesAction) {
        current = action
    }
    
    private func onEscape() {
        if isRuningAction {
            isRuningAction = false
            return
        }
        dismiss()
    }
    
    private func onSubmit() {
        keyword = ""
        withAnimation { isRuningAction = true }
    }
    
    private func onNavKey(step: Int) -> KeyPress.Result {
        if isRuningAction {
            return .ignored
        }
        
        current = NotesActionProvider.next(in: items.flatMap{ $0 }, current: current, step: step)!
        return .handled
    }
}

private struct ActionMenus: View {
    let groups: [[NotesAction]]
    let hoveredActionId: String
    let onActionHover: (NotesAction) -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(groups.indices, id: \.self) { i in
                if i != 0 {
                    Divider()
                }
                
                Section {
                    ForEach(groups[i]) { action in
                        ShortActionEntry(
                            config: action,
                            selected: hoveredActionId == action.id,
                            onHover: onActionHover
                        )
                    }
                }
                .padding(0, 12)
            }
        }
    }
}

private struct MoveToBrowse: View {
    let filter: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("move to").font(size: .sm, weight: .bold)
                Spacer()
            }
            
            ScrollView {
                ProjectsCatalogWithoutFilterField(
                    filter: filter,
                    types: [.pad],
                    onSelect: { id in
                    }
                )
            }
        }
    }
}
