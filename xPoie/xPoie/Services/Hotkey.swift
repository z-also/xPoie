import AppKit
import HotKey

@MainActor
class Hotkey {
    static var spotlight: HotKey?
    
    static var spotlightScene: SpotlightScene?
    
    static func registerSpotlightHotkey(_ shortcut: Shortcut) {
        guard shortcut.isValid else {
            return
        }
        unregisterSpotlightHotkey()
        spotlight = HotKey(key: shortcut.key!, modifiers: shortcut.modifiers) {
            if spotlightScene == nil {
                spotlightScene = SpotlightScene()
            }
            spotlightScene!.toggle()
        }
    }
    
    static func unregisterSpotlightHotkey() {
        spotlight = nil
    }
    
    static func setup() {
        registerSpotlightHotkey(Preferences[.spotlightHotkey])
    }

    struct Shortcut: Equatable {
        var key: Key?
        var modifiers: NSEvent.ModifierFlags

        var isValid: Bool { key != nil && !modifiers.isEmpty }

        var displayString: String {
            guard let key = key else { return "" }
            var parts: [String] = []
            if modifiers.contains(.command) { parts.append("⌘") }
            if modifiers.contains(.option) { parts.append("⌥") }
            if modifiers.contains(.shift) { parts.append("⇧") }
            if modifiers.contains(.control) { parts.append("⌃") }
            parts.append(key.description.uppercased())
            return parts.joined(separator: "")
        }
    }
}
