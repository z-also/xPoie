import AppKit

extension RTex: @MainActor RTex.Hosting {
    public var storage: NSTextContentStorage {
        contentStorage
    }
    
    public func set(selectedRange: NSRange) {
        textView.selectedRange = selectedRange
    }
    
    public func set(typingAttributes: [NSAttributedString.Key : Any]) {
        textView.typingAttributes = typingAttributes
    }
    
    public func config(forType: FormatType) -> [NSAttributedString.Key : Any] {
        return config.attributes(for: forType)
    }

    public func insert(_ attrString: NSAttributedString, at loc: Int) {
        contentStorage.textStorage!.insert(attrString, at: loc)
    }
    
    public func remove(format: FormatType, at range: NSRange) {
        let attrs: [NSAttributedString.Key: Any] = [.rtexFormat: FormatType.body]
        performEditingTransaction {
            contentStorage.textStorage?.setAttributes(attrs, range: range)
        }
        textView.typingAttributes = attrs
    }
    
    public func paragraph(at: NSRange) -> Paragraph {
        let ats = contentStorage.attributedString!
        let range = (ats.string as NSString).paragraphRange(for: at)
        let content = ats.attributedSubstring(from: range)
        
        var format: FormatType?
        
        if !content.string.isEmpty {
            format = content.attribute(.rtexFormat, at: 0, effectiveRange: nil) as? FormatType
        }
        
        return .init(range: range, content: content, format: format ?? .body)
    }
    
    public func format(forTypingParagraph paragraph: Paragraph) -> FormatType {
        var format = paragraph.format
        if format == .body && paragraph.content.string.isEmpty {
            format = textView.typingAttributes[.rtexFormat] as? FormatType ?? .body
        }
        return format
    }
    
    public func toggle(fontTrait trait: NSFontDescriptor.SymbolicTraits, at range: NSRange) {
        guard let content = storage.attributedString else {
            return
        }
        content.enumerateAttribute(.font, in: range) { font, range, _ in
            if let font = font as? NSFont {
                var traits = font.fontDescriptor.symbolicTraits
                
                if traits.contains(trait) {
                    traits.remove(trait)
                } else {
                    traits.insert(trait)
                }
                
                let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits)
                guard let newFont = NSFont(descriptor: newDescriptor, size: font.pointSize) else {
                    return
                }
                storage.textStorage?.addAttribute(.font, value: newFont, range: range)
            }
        }
    }
    
    public func attributedSubstring(from range: NSRange) -> NSAttributedString {
        storage.attributedString!.attributedSubstring(from: range)
    }
    
    public func performEditingTransaction(_ action: () -> Void) {
        undoManager?.beginUndoGrouping()
        action()
        undoManager?.endUndoGrouping()
    }
    
    public func set(attributes: [NSAttributedString.Key : Any], range: NSRange) {
        storage.textStorage?.setAttributes(attributes, range: range)
    }
    
    public func replace(characters: NSAttributedString, in range: NSRange) {
        storage.textStorage!.replaceCharacters(in: range, with: characters)
    }

    public func textView(_ textView: NSTextView, becomeFirstResponder _: NSTextView) {
        delegate?.rtex(self, becomeFirstResponder: textView)
    }
    
    public func textView(_ textView: NSTextView, resignFirstResponder _: NSTextView) {
        delegate?.rtex(self, resignFirstResponder: textView)
    }
    
    public func textView(_ textView: NSTextView, afterKeyDown event: NSEvent) {
        revalidatePlaceholderViewVisibility()
    }
    
    public func textView(_ textView: NSTextView, interceptKeyDown event: NSEvent) -> Editing {
        if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "z" {
            if event.modifierFlags.contains(.shift) {
                undoManager?.redo()
            } else {
                undoManager?.undo()
            }
            return .ignore
        }
        
        let range = textView.selectedRange()
        
        if let delegated = delegate?.rtex(self, intercept: textView, keyDown: event) {
            return delegated
        }
        
        for plugin in plugins {
            var result: Editing?
           
            // enter
            if event.keyCode == 36 {
                result = plugin.intercept(enter: range)
            } else if event.keyCode == 51 {
                result = plugin.intercept(delete: range)
            } else if let chars = event.characters, !chars.isEmpty {
                result = plugin.intercept(input: chars.first!, at: range)
            }
            
            if let result = result {
                if result.behavior == .accept {
                    editing = result
                } else {
                    process(result: result)
                }
                return result
            }
        }

        return .accept
    }
}
