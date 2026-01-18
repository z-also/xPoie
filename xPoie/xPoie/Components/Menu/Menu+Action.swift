import SwiftUI

struct ShortActionEntry: View {
    let config: ShortAction
    let selected: Bool
    let onHover: (ShortAction) -> Void
    
    var body: some View {
        let entry = Button(action: onAction) {
            HStack {
                Image(systemName: config.icon)
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Text(config.label)
                
                Spacer()
                
                if let sc = config.shortcut {
                    Text(shortcutLabel(modifiers: sc.modifiers, key: sc.key))
                        .opacity(0.7)
                }
            }
            .padding(4, 4)
        }
        .buttonStyle(.omni.with(visual: config.destructive ? .destructiveMenuAction : .menuAction, active: selected))
        .onHover{ yes in
            if yes {
                onHover(config)
            }
        }
        
        if let sc = config.shortcut {
            entry.keyboardShortcut(KeyEquivalent(sc.key), modifiers: sc.modifiers)
        } else {
            entry
        }
    }
    
    private func onAction() {
        
    }
    
    private func shortcutLabel(modifiers: EventModifiers, key: Character) -> String {
        var sym = ""
        if modifiers.contains(.command) { sym += "⌘" }
        if modifiers.contains(.shift) { sym += "⇧" }
        if modifiers.contains(.option) { sym += "⌥" }
        if modifiers.contains(.control) { sym += "⌃" }
        let keyStr = String(key).uppercased()
        return sym + keyStr
    }
}
