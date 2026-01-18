import SwiftUI

struct SpotlightDock: View {
    @Environment(\.spotlight) var spotlight
    
    var body: some View {
        HStack {
            if spotlight.collapsed {
                Spacer()
            }
            
            HStack {
                Logo()
                    .padding(4)
                
                if !spotlight.collapsed {
                    MainControl()
                }
            }
            .padding(0, 6)
            .glassEffect(.regular, in: .capsule)
            
            Extra()
                .glassEffect(.regular, in: .capsule)
        }
    }
}

fileprivate struct MainControl: View {
    @State private var search = ""
    
    @Environment(\.input) private var input
    @Environment(\.spotlight.scene) private var scene
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { `switch`(scene: .ai) }) {
                Label("", systemImage: "wand.and.sparkles")
                    .labelStyle(.iconOnly)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.omni.with(active: scene == .ai))
            
            Button(action: { `switch`(scene: .tasks) }) {
                Label("", systemImage: "checklist")
                    .labelStyle(.iconOnly)
                    .padding(.vertical, 2)
            }
            .buttonStyle(.omni.with(active: scene == .tasks))
            
            Button(action: { `switch`(scene: .notes) }) {
                Label("", systemImage: "pencil.and.scribble")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.omni.with(active: scene == .notes))

            Divider().frame(height: 18)
            
            Search(search: $search)
        }
    }
    
    private func `switch`(scene: Modules.Spotlight.Scene) {
        Modules.spotlight.set(scene: scene)
        if input.focus == .search {
            withAnimation { input.focus = .none }
        }
    }
}

fileprivate struct Logo: View {
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        Button(action: openMainWindow) {
            Image("logo")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(5.5)
        }
        .buttonStyle(.omni.with(padding: .zero))
    }
    
    private func openMainWindow() {
        if NSApplication.shared.mainWindow == nil {
            openWindow(id: "main")
        }
        NSApp.activate(ignoringOtherApps: true)
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
}

fileprivate struct Search: View {
    @Binding var search: String
    
    @Environment(\.input) private var input
    @Environment(\.spotlight.scene) private var scene

    var body: some View {
        OmniField(search, placeholder: "Search ...")
            .behavior(.alwaysEditable)
            .field(.search, focus: input.focus == .search)
            .on(focus: onFocus, blur: onBlur, edit: onEdit, submit: onSubmit)
            .frame(minWidth: 160, maxWidth: scene == .search ? .infinity : 160)
            .opacity(scene == .search ? 1 : 0.6)
    }
    
    private func onFocus() {
        Modules.spotlight.set(scene: .search)
        withAnimation { input.focus = .search }
    }
    
    private func onBlur() {
        if input.focus == .search {
            withAnimation { input.focus = .none }
        }
    }
    
    private func onEdit(value: String) {
        search = value
    }
    
    private func onSubmit() -> Bool {
        return true
    }
}

fileprivate struct Extra: View {
    @Environment(\.spotlight) var spotlight
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: togglePin) {
                Image(systemName: spotlight.collapsed ? "arrow.down.backward.and.arrow.up.forward" : "arrow.up.forward.and.arrow.down.backward")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .padding(4, 4)
            }
            .buttonStyle(.omni.with(padding: .sm))
        }
        .padding(4, 12)
    }
    
    private func togglePin() {
        spotlight.toggle(collapse: !spotlight.collapsed)
    }
}
