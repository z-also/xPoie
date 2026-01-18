import SwiftUI

struct SettingsGeneralView: View {
    @State private var shortcut = Preferences[.spotlightHotkey]
    var body: some View {
        Form {
            LabeledContent("Spotlight shortcut") {
                ShortcutRecorder(shortcut: $shortcut)
            }
            .onChange(of: shortcut) { old, new in
                if new.isValid {
                    Hotkey.registerSpotlightHotkey(new)
                    Preferences[.spotlightHotkey] = new
                }
            }
        }
        .frame(width: 400)
    }
}
