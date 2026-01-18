import AppKit
import HotKey
import SwiftUI

struct ShortcutRecorder: View {
    @Binding var shortcut: Hotkey.Shortcut
    @State private var isFocused: Bool = false
    @Environment(\.theme) var theme

    var body: some View {
        HStack {
            if shortcut.isValid {
                Text(shortcut.displayString)
            } else if isFocused {
                Text("Recording shortcut...")
                    .foregroundStyle(theme.text.secondary)
            } else {
                Text("Click to record shortcut")
                    .foregroundStyle(theme.text.secondary)
            }
        }
        .padding([.vertical], 4)
        .padding([.horizontal], 8)
//        .frame(maxWidth: 220)
        .modifier(OmniStyle.omni.with(visual: .field, active: isFocused))
        .background(
            ShortcutRepresentable(
                isFocused: $isFocused,
                shortcut: $shortcut
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

fileprivate struct ShortcutRepresentable: NSViewRepresentable {
    @Binding var isFocused: Bool
    @Binding var shortcut: Hotkey.Shortcut

    func makeNSView(context: Context) -> ShortcutKeyView {
        let view = ShortcutKeyView()
        view.onKeyDown = { event in
            handleKeyEvent(event)
        }
        view.onFocusChange = { focused in
            DispatchQueue.main.async {
                isFocused = focused
            }
        }
        return view
    }

    func updateNSView(_ nsView: ShortcutKeyView, context: Context) {
        DispatchQueue.main.async {
            if isFocused && nsView.window?.firstResponder != nsView {
                nsView.window?.makeFirstResponder(nsView)
            } else if !isFocused && nsView.window?.firstResponder == nsView {
                nsView.window?.makeFirstResponder(nil)
            }
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        guard !event.isARepeat else { return }
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard let key = Key(carbonKeyCode: UInt32(event.keyCode)) else { return }
        if !modifiers.isEmpty {
            shortcut = Hotkey.Shortcut(key: key, modifiers: modifiers)
            isFocused = false
        }
    }
}

fileprivate class ShortcutKeyView: NSView {
    var onKeyDown: ((NSEvent) -> Void)?
    var onFocusChange: ((Bool) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func becomeFirstResponder() -> Bool {
        let accepted = super.becomeFirstResponder()
        if accepted {
            onFocusChange?(true)
        }
        return accepted
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned {
            onFocusChange?(false)
        }
        return resigned
    }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event)
    }
}
