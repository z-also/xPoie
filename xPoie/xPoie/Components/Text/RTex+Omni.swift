import RTex
import SwiftUI

struct OmniRTex: View {
    private var field: Field?
    private var focus: Bool = false
    private var config: RTexc?
    private var actions: Actions?
    private var behavior: Behavior = .inline
    private var typography: Typography = .body
    private var placeholder: String
    private var debugId: String
    
    @State private var height: CGFloat
    @State private var attributedString: AttributedString
    @Environment(\.theme) var theme
    
    init(_ attributedString: AttributedString, placeholder: String, height: CGFloat = 100, id: String = "") {
        self._height = State(initialValue: height)
        self.placeholder = placeholder
        self.attributedString = attributedString
        self.debugId = id
    }

    var body: some View {
        if focus || behavior.editable == .always {
            Editor(coordinator: coordinator, focus: focus)
                .frame(height: height, alignment: .top)
        } else {
            if attributedString.characters.isEmpty {
                Text(placeholder)
                    .typography(typography)
            } else {
                Text(attributedString)
                    .typography(typography)
            }
        }
    }

    private func coordinator() -> Coordinator {
        let coordinator = Coordinator(
            field: field,
            config: config!,
            behavior: behavior,
            height: $height,
            attributedString: $attributedString,
            placeholder: placeholder,
            debugId: debugId
        )
        coordinator.actions = actions
        return coordinator
    }
}

extension OmniRTex {
    struct Behavior {
        var lines: Lines
        var editable: Editable
        var autofocus: Bool = true

        enum Lines {
            case any
            case single
        }
        
        enum Editable {
            case auto
            case always
        }
        
        func with(autofocus: Bool) -> Self {
            var this = self
            this.autofocus = autofocus
            return this
        }
    }
}

fileprivate struct Actions {
    var focus: (() -> Void)?
    var blur: (() -> Void)?
    var edit: ((AttributedString) -> Void)?
    var submit: (() -> Bool)?
    var selectionChanged: (() -> Void)?
}

extension OmniRTex.Behavior {
    static let omni: Self = .init(lines: .any, editable: .always)
    static let inline: Self = .init(lines: .any, editable: .auto)
    static let minimal: Self = .init(lines: .any, editable: .always, autofocus: false)
}

extension OmniRTex {
    func field(_ field: Field, focus: Bool) -> Self {
        var this = self
        this.field = field
        this.focus = focus
        return this
    }
    
    func behavior(_ v: OmniRTex.Behavior) -> Self {
        var this = self
        this.behavior = v
        return this
    }
    
    func on(
        focus: @escaping () -> Void,
        blur: (() -> Void)? = nil,
        edit: ((AttributedString) -> Void)? = nil,
        submit: (() -> Bool)? = nil,
        selectionChanged: (() -> Void)? = nil
    ) -> Self {
        var this = self
        this.actions = .init(focus: focus, blur: blur, edit: edit, submit: submit, selectionChanged: selectionChanged)
        return this
    }
    
    func style(typography: Typography) -> Self {
        var this = self
        this.typography = typography
        if this.config == nil {
            let config = RTexcOmni(typography: typography)
            config.revalidate(theme: Modules.vars.theme)
            this.config = config
        }
        return this
    }
}

fileprivate class Coordinator: NSObject, RTex.Delegate {
    let editor: RTex
    
    private var field: Field?
    private var focus: Bool
    private var config: RTexc
    private let minHeight: CGFloat
    private let behavior: OmniRTex.Behavior

    @Binding private var height: CGFloat
    @Binding private var attributedString: AttributedString
    
    var actions: Actions?
    
    private var debugId: String
    
    // Speech recognition properties
    private var speechSkill: SpeechSkill?
    private var isSpeechActive = false
    private var fnKeyIsDown = false
    private var volatileRange: NSRange? // To track the range of volatile text
    private var placeholder: String

    init(field: Field?,
         config: RTexc,
         behavior: OmniRTex.Behavior,
         height: Binding<CGFloat>,
         attributedString: Binding<AttributedString>,
         placeholder: String = "",
         debugId: String = "") {
        self.field = field
        self._height = height
        self.behavior = behavior
        self.editor = RTex(config: config)
        self.minHeight = height.wrappedValue
        self.placeholder = placeholder
        self._attributedString = attributedString
        self.config = config
        self.focus = behavior.autofocus
        self.debugId = debugId
        super.init()
        self.mount()
        editor.delegate = self
    }
    
    private var editDebounceWork: DispatchWorkItem?
    private let editDebounce: TimeInterval = 0.2

    private func scheduleDebouncedEdit(_ text: NSAttributedString) {
        // Cancel previous pending task
        editDebounceWork?.cancel()

        let work = DispatchWorkItem { [weak self] in
            // Convert on the main thread since it's UI-related
            DispatchQueue.main.async {
                guard let self else { return }
                let converted = AttributedString(text)
                self.actions?.edit?(converted)
            }
        }
        editDebounceWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + editDebounce, execute: work)
    }

    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {
        withAnimation {
            self.height = max(minHeight, size.height)
        }
    }
    
    func rtex(_ rtex: RTex, didChangeSelection range: NSRange) {
        actions?.selectionChanged?()
    }
    
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {
        if let edit = actions?.edit {
            let value = text.toAttributedString()
            edit(value)
            attributedString = value
        }
    }
    
    
    func rtex(_ rtex: RTex, becomeFirstResponder textView: NSTextView) {
        focus = true
        actions?.focus?()
    }

    func rtex(_ rtex: RTex, resignFirstResponder textView: NSTextView) {
        focus = false
        actions?.blur?()
        Task {
            try await stopSpeechRecognition()
        }
    }

    func rtex(_ rtex: RTex, didMount textView: NSTextView) {
        rtex.set(placeholder: NSHostingView(
            rootView: RTex_Placeholder(string: placeholder, typography: config.typography)
        ))

        if behavior.autofocus {
            editor.receive(focus: true)
        }
    }

    func rtex(_ rtex: RTex, input char: Character, at range: NSRange, modifierFlags: NSEvent.ModifierFlags) -> RTex.Editing {
        if char == "\n" || char == "\r" {
            if behavior.lines == .single || modifierFlags.contains(.command) {
                actions?.submit?()
                return .ignore
            }
        }
        
        return .accept
    }
    
//    func rtex(_ rtex: RTex, flagsChangedWith event: NSEvent) {
//        let fnKeyIsDown = event.modifierFlags.contains(.function)
//        if fnKeyIsDown != self.fnKeyIsDown {
//            self.fnKeyIsDown = fnKeyIsDown
//            toggleSpeechRecognition(active: fnKeyIsDown)
//        }
//    }

    func receive(focus: Bool) {
        if focus != self.focus {
            editor.receive(focus: focus)
        }
    }
    
    func mount() {
        editor.register(plugin: RTex.RichEdit.Plugin(
            rules: [
                RTex.BoldFormatRule(),
                RTex.ItalicFormatRule(),
                RTex.BlockQuoteFormatRuleWithMarkdownSupport(),
                RTex.UnorderedListFormatRuleWithMarkdownSupport(),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 1),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 2),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 3),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 4),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 5),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 6)
            ]
        ))
        editor.register(plugin: YoImagePlugin())
        editor.set(text: attributedString.toNSAttributedString())
    }
    
    private func toggleSpeechRecognition(active: Bool) {
        if !active {
            // Stop speech recognition if already active
            Task {
                try await stopSpeechRecognition()
            }
        } else {
            // Start speech recognition
            startSpeechRecognition()
        }
    }
    
    private func startSpeechRecognition() {
        isSpeechActive = true
        speechSkill = SpeechSkill.shared
        
        Task {
            do {
                try await speechSkill?.start(consume: processSpeechResult)
            } catch {
                print("Speech recognition setup failed: \(error)")
                self.isSpeechActive = false
            }
        }
    }
    
    private func processSpeechResult(finalized: AttributedString, volatile: AttributedString, isFinal: Bool) {
    }
    
    private func stopSpeechRecognition() async throws {
        guard let speechSkill = speechSkill else {
            return
        }
        
        try await speechSkill.stop()
        isSpeechActive = false
        self.speechSkill = nil
    }
}

fileprivate struct Editor<C: Coordinator>: NSViewRepresentable {
    let coordinator: () -> C
    let focus: Bool
    
    func makeCoordinator() -> C {
        coordinator()
    }
    
    func makeNSView(context: Context) -> NSView {
        return context.coordinator.editor
    }
    
    func updateNSView(_ view: NSView, context: Context) {
        context.coordinator.receive(focus: focus)
    }
}
