import AppKit
import SwiftUI

struct OmniField: View {
    private let value: String
    private var field: Field?
    private var focus: Bool = true
    private var placeholder: String
    private var actions: Actions?
    private var behavior: Behavior = .auto
    private var typography: Typography = .body

    init(_ value: String, placeholder: String) {
        self.value = value
        self.placeholder = placeholder
    }

    var body: some View {
        if behavior.editable == .always || focus {
            Editor(
                value: value,
                field: field,
                focus: focus,
                placeholder: placeholder,
                actions: actions,
                behavior: behavior,
                typography: typography
            )
        } else {
            Text(value.isEmpty ? placeholder : value)
                .typography(typography)
                .opacity(value.isEmpty ? 0.78 : 1)
                .contentShape(Rectangle())
        }
    }
}

extension OmniField {
    struct Behavior {
        var editable: Editable
        var autofocus: Bool = true
        
        enum Editable {
            case auto
            case always
        }
    }
    
    struct Actions {
        var focus: (() -> Void)?
        var blur: (() -> Void)?
        var edit: ((String) -> Void)?
        var submit: (() -> Bool)?
        var tab: (() -> Bool)?
    }
}

extension OmniField.Behavior {
    static let auto: Self = .init(editable: .auto)
    static let always: Self = .init(editable: .always)
    static let alwaysEditable: Self = .init(editable: .always, autofocus: false)
    static let autofocusAlwaysEditable: Self = .init(editable: .always, autofocus: true)
}

extension OmniField {
    func field(_ field: Field, focus: Bool) -> Self {
        var this = self
        this.field = field
        this.focus = focus
        return this
    }
    
    func behavior(_ v: OmniField.Behavior) -> Self {
        var this = self
        this.behavior = v
        return this
    }

    func on(
        focus: @escaping () -> Void,
        blur: (() -> Void)? = nil,
        edit: ((String) -> Void)? = nil,
        submit: (() -> Bool)? = nil,
        tab: (() -> Bool)? = nil
    ) -> Self {
        var this = self
        this.actions = .init(focus: focus, blur: blur, edit: edit, submit: submit, tab: tab)
        return this
    }
    
    func style(typography: Typography) -> Self {
        var this = self
        this.typography = typography
        return this
    }
}

fileprivate class _TextField: NSTextField {
    var actions: OmniField.Actions?
    
    var behavior: OmniField.Behavior?
    
//    private var speechSkill: SpeechSkill?
    
//    private var isSpeechActive = false
    
    private var lastMeasuredWidth: CGFloat = 0
    
    override var acceptsFirstResponder: Bool { return true }
    
//    private var fnKeyIsDown = false
    
    var liveStream: ((AttributedString) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        lineBreakMode = .byWordWrapping
        usesSingleLineMode = false
        cell?.wraps = true
        cell?.isScrollable = false
    }
    
//    override func flagsChanged(with event: NSEvent) {
//        super.flagsChanged(with: event)
//        let fnKeyIsDown = event.modifierFlags.contains(.function)
//        if fnKeyIsDown != self.fnKeyIsDown {
//            self.fnKeyIsDown = fnKeyIsDown
//            toggleSpeechRecognition(active: fnKeyIsDown)
//        }
//    }
    
//    private func toggleSpeechRecognition(active: Bool) {
//        if !active {
//            // Stop speech recognition if already active
//            Task {
//                try await stopSpeechRecognition()
//            }
//        } else {
//            // Start speech recognition
//            startSpeechRecognition()
//        }
//    }
    
//    private func startSpeechRecognition() {
//        isSpeechActive = true
//        speechSkill = SpeechSkill.shared
//        
//        Task {
//            do {
//                try await speechSkill?.start(consume: process)
//            } catch {
//                print("Speech recognition setup failed: \(error)")
//                self.isSpeechActive = false
//            }
//        }
//    }
    
    private func process(finalized: AttributedString, volatile: AttributedString, isFinal: Bool) {
        print("bbbkkkkk", isFinal, finalized)
//        if isFinal {
            liveStream?(finalized)
//        }
    }
    
//    private func stopSpeechRecognition() async throws {
//        try await speechSkill?.stop()
//        isSpeechActive = false
//        speechSkill = nil // Release speech skill to stop recognition
//    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            actions?.focus?()
            setCursorToEnd()
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            actions?.blur?()
//            Task {
//                try await stopSpeechRecognition()
//            }
        }
        return result
    }
    
    override func viewDidMoveToWindow() {
        if let focus = behavior?.autofocus, focus {
            self.becomeFirstResponder()
        }
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        actions?.edit?(stringValue)
        invalidateIntrinsicContentSize()
    }
    
    override var font: NSFont? {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override var placeholderString: String? {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    // Track width changes from SwiftUI/AppKit layout to recalc intrinsic height
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        if abs(newSize.width - lastMeasuredWidth) > 0.5 {
            lastMeasuredWidth = newSize.width
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: NSSize {
        // Width is provided by layout; height should fit content.
        let width = lastMeasuredWidth > 0 ? lastMeasuredWidth : bounds.width
        let effectiveWidth = max(0, width)
        let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let lineHeight = ceil((font.ascender - font.descender) + font.leading)
        let content: NSAttributedString = {
            if !self.attributedStringValue.string.isEmpty {
                return self.attributedStringValue
            } else if let ph = self.placeholderString {
                return NSAttributedString(string: ph, attributes: [.font: font])
            } else {
                return NSAttributedString(string: " ", attributes: [.font: font])
            }
        }()
        var height: CGFloat = lineHeight
        if effectiveWidth > 0 {
            let rect = content.boundingRect(
                with: NSSize(width: effectiveWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading]
            )
            height = max(lineHeight, ceil(rect.height))
        }
        return NSSize(width: NSView.noIntrinsicMetric, height: height)
    }
    
    func setCursorToEnd() {
        if let textEditor = currentEditor() as? NSTextView {
            textEditor.setSelectedRange(NSRange(location: stringValue.count, length: 0))
            textEditor.scrollRangeToVisible(NSRange(location: stringValue.count, length: 0))
        }
    }
}

@MainActor fileprivate class Coordinator: NSObject, NSTextFieldDelegate {
    let editor: _TextField
    private var holder: Editor
    private var value: String

    init(_ holder: Editor) {
        let editor = _TextField()
        editor.isBordered = false
        editor.isBezeled = false
        editor.drawsBackground = false
        editor.stringValue = holder.value
        editor.placeholderString = holder.placeholder
        editor.focusRingType = .none
        editor.actions = holder.actions
        editor.behavior = holder.behavior
        editor.font = NSFont.systemFont(
            ofSize: holder.typography.size.rawValue,
            weight: holder.typography.weight.nsWeight
        )
        
        self.holder = holder
        self.editor = editor
        self.value = holder.value

        super.init()

        editor.delegate = self
        editor.liveStream = { content in
            let x = self.value + String(content.characters)
            self.holder.actions?.edit?(x)
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            value = textField.stringValue
            holder.actions?.edit?(value)
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            return holder.actions?.submit?() ?? false
        } else if commandSelector == #selector(NSResponder.insertTab(_:)) {
            return holder.actions?.tab?() ?? false
        }
        return false
    }
    
    func receive(focus: Bool) {
        guard self.holder.focus != focus else {
            return
        }
        if focus {
            editor.window?.makeFirstResponder(editor)
        } else if editor.currentEditor() != nil {
            editor.window?.makeFirstResponder(nil)
        }
    }

    func receive(value: String, placeholder: String) {
        if value != self.value {
            self.value = value
            editor.stringValue = value
            editor.setCursorToEnd()
        }
        
        if editor.placeholderString != placeholder {
            editor.placeholderString = placeholder
        }
    }
    
    func update(holder: Editor) {
        receive(focus: holder.focus)
        receive(value: holder.value, placeholder: holder.placeholder)
        self.holder = holder
    }
}

fileprivate struct Editor: NSViewRepresentable {
    let value: String
    let field: Field?
    let focus: Bool
    let placeholder: String
    let actions: OmniField.Actions?
    let behavior: OmniField.Behavior
    let typography: Typography

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSView {
        return context.coordinator.editor
    }

    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.update(holder: self)
    }
}
