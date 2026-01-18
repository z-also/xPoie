import AppKit

extension RTex {
    public protocol Config {
        var attributes: [RTex.FormatType: [NSAttributedString.Key: Any]] { get }
        var typingAttributes: [NSAttributedString.Key: Any] { get }
        var imageConfig: ImageConfig { get }
    }
    
    public struct ImageConfig {
        public var maxWidth: CGFloat = 600
        public var maxHeight: CGFloat = 400
        public var quality: CGFloat = 0.8
        public var allowDragDrop: Bool = true
        public var allowPaste: Bool = true
    }
}

public extension RTex.Config {
    func attributes(for format: RTex.FormatType) -> [NSAttributedString.Key: Any] {
        var attrs = attributes[format] ?? [:]
        attrs[.rtexFormat] = format
        return attrs
    }
    
    var imageConfig: RTex.ImageConfig {
        return RTex.ImageConfig()
    }
}

extension RTex {
    @MainActor public protocol Plugin {
        func selectionDidChange(range: NSRange)
        func setup(rtex: RTex, textView: NSTextView, layoutManager: NSTextLayoutManager)
        func process(input: Character, in textStorage: NSTextStorage, at range: NSRange) -> RTex.Editing?
        func handlePaste(_ pasteboard: NSPasteboard, in textView: NSTextView) -> Bool
        func canAcceptDrag(_ sender: NSDraggingInfo) -> Bool
        func handleDragOperation(_ sender: NSDraggingInfo, in textView: NSTextView) -> Bool
        func intercept(input char: Character, at range: NSRange) -> Editing?
        func intercept(enter range: NSRange) -> Editing?
        func intercept(delete range: NSRange) -> Editing?
    }
}

public extension RTex.Plugin {
    func setup(rtex: RTex, textView: NSTextView, layoutManager: NSTextLayoutManager) {}
    func selectionDidChange(range: NSRange) {}
    func handlePaste(_ pasteboard: NSPasteboard, in textView: NSTextView) -> Bool { false }
    func canAcceptDrag(_ sender: NSDraggingInfo) -> Bool { false }
    func handleDragOperation(_ sender: NSDraggingInfo, in textView: NSTextView) -> Bool { false }
    func intercept(input char: Character, at range: NSRange) -> RTex.Editing? { nil }
    func intercept(enter range: NSRange) -> RTex.Editing? { nil }
    func intercept(delete range: NSRange) -> RTex.Editing? { nil }
    func process(input: Character, in textStorage: NSTextStorage, at range: NSRange) -> RTex.Editing? { nil }
}

extension RTex {
    public struct Editing {
        enum Behavior {
            case ignore
            case accept
            case handled
            case terminate
        }
        var behavior: Behavior = .accept
        var selectedRange: NSRange? = nil
        var typingAttributes: [NSAttributedString.Key: Any]? = nil
        var paragraphStyle: NSMutableParagraphStyle? = nil
        
        var postBlock: (() -> Void)?

        public static var accept: Self {
            return .init(behavior: .accept)
        }
        
        public static var ignore: Self {
            return .init(behavior: .ignore)
        }
        
        public static var terminate: Self {
            return .init(behavior: .terminate)
        }
    }
}

extension RTex {
    public struct Paragraph {
        let range: NSRange
        let content: NSAttributedString
        var format: FormatType
    }
    
//    public protocol Hosting {
//        var storage: NSTextContentStorage { get }
//        func remove(format: FormatType, at range: NSRange)
//        func paragraph(at: NSRange) -> Paragraph
//        func set(typingAttributes: [NSAttributedString.Key: Any])
//        func set(selectedRange: NSRange)
//        func insert(_ attrString: NSAttributedString, at loc: Int)
//        func format(forTypingParagraph paragraph: Paragraph) -> FormatType
//        func config(forType: FormatType) -> [NSAttributedString.Key: Any]
//        func toggle(fontTrait trait: NSFontDescriptor.SymbolicTraits, at range: NSRange)
//        func performEditingTransaction(_ action: () -> Void)
//    }
}


extension RTex {
    public protocol Hosting {
        var storage: NSTextContentStorage { get }
        func remove(format: FormatType, at range: NSRange)
        func paragraph(at: NSRange) -> Paragraph
        func set(typingAttributes: [NSAttributedString.Key: Any])
        func set(selectedRange: NSRange)
        func insert(_ attrString: NSAttributedString, at loc: Int)
        func format(forTypingParagraph paragraph: Paragraph) -> FormatType
        func config(forType: FormatType) -> [NSAttributedString.Key: Any]
        func toggle(fontTrait trait: NSFontDescriptor.SymbolicTraits, at range: NSRange)
        func performEditingTransaction(_ action: () -> Void)
        func replace(characters: NSAttributedString, in range: NSRange)
        func set(attributes: [NSAttributedString.Key: Any], range: NSRange)
        func attributedSubstring(from: NSRange) -> NSAttributedString

        @MainActor func textView(_ textView: NSTextView, afterKeyDown event: NSEvent)
        @MainActor func textView(_ textView: NSTextView, interceptKeyDown event: NSEvent) -> Editing
        @MainActor func textView(_ textView: NSTextView, becomeFirstResponder _: NSTextView)
        @MainActor func textView(_ textView: NSTextView, resignFirstResponder _: NSTextView)
    }
    
    @MainActor public protocol Delegate: AnyObject {
        func rtex(_ rtex: RTex, didMount textView: NSTextView)
        func rtex(_ rtex: RTex, becomeFirstResponder textView: NSTextView)
        func rtex(_ rtex: RTex, resignFirstResponder textView: NSTextView)
        func rtex(_ rtex: RTex, intercept textView: NSTextView, keyDown event: NSEvent) -> Editing?
        
        func rtex(_ rtex: RTex, onSizeChanged size: CGSize)
        func rtex(_ rtex: RTex, didChange text: NSAttributedString)
        
        func rtex(_ rtex: RTex, keyDown event: NSEvent) -> Editing?
        func rtex(_ rtex: RTex, didChangeSelection range: NSRange)
    }
}

public extension RTex.Delegate {
    func rtex(_ rtex: RTex, didMount textView: NSTextView) {}
    func rtex(_ rtex: RTex, becomeFirstResponder textView: NSTextView) {}
    func rtex(_ rtex: RTex, resignFirstResponder textView: NSTextView) {}
    func rtex(_ rtex: RTex, intercept textView: NSTextView, keyDown event: NSEvent) -> RTex.Editing? { nil }

    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {}
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {}

    func rtex(_ rtex: RTex, keyDown event: NSEvent) -> RTex.Editing? { nil }
    func rtex(_ rtex: RTex, input char: Character, at range: NSRange) -> RTex.Editing {
        return .accept
    }
    
    func rtex(_ rtex: RTex, didChangeSelection range: NSRange) {}
    
//    func rtex(_ rtex: RTex, flagsChangedWith event: NSEvent) {}
}

