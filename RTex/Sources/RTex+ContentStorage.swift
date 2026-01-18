import AppKit

extension RTex: @MainActor NSTextStorageDelegate {
    public func textStorage(
        _ textStorage: NSTextStorage,
        didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
        DispatchQueue.main.async {
            self.revalidateSize()
        }
        
        guard editedMask.contains(.editedCharacters) && delta > 0 else {
            return
        }
        
        let newText = textStorage.attributedSubstring(from: editedRange).string
        
        if let char = newText.last {
            let charRange = NSRange(location: editedRange.location + editedRange.length - 1, length: 1)
            
            for plugin in plugins {
                if let result = plugin.process(input: char, in: textStorage, at: charRange) {
                    editing = result
                    break
                }
            }
        }
        
//        print("==============", newText)
//        
//        for (offset, char) in newText.enumerated() {
//            let charRange = NSRange(location: editedRange.location + offset, length: 1)
//            
//            for plugin in plugins {
//                if let result = plugin.process(input: char, in: textStorage, at: charRange) {
//                    editing = result
//                    break
//                }
//            }
//        }
    }
}

extension RTex: @MainActor NSTextContentStorageDelegate {
    public func textContentStorage(_ textContentStorage: NSTextContentStorage,
                                   textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard let content = textContentStorage.attributedString?.attributedSubstring(from: range) else {
            print("[ContentStorageDelegate] textParagraphWith range: \(range), nil !!")
            return nil
        }
        
        let formatAttr = content.attribute(.rtexFormat, at: 0, effectiveRange: nil)

        print("[ContentStorageDelegate] textParagraphWith range: \(range), content: '\(content)', formatAttr: \(formatAttr)")
        
        if let format = formatAttr as? FormatType, case .heading(let level) = format {
            let attrs = config.attributes(for: .heading(level))
            let textWithDisplayAttributes = NSMutableAttributedString(attributedString: content)
            let rangeForParagraph = NSRange(location: 0, length: textWithDisplayAttributes.length)
            textWithDisplayAttributes.addAttributes(attrs, range: rangeForParagraph)

            return NSTextParagraph(attributedString: textWithDisplayAttributes)
        }
        
        if let format = formatAttr as? FormatType, case .blockquote = format {
            let attrs = config.attributes(for: .blockquote)
            let textWithDisplayAttributes = NSMutableAttributedString(attributedString: content)
            let rangeForParagraph = NSRange(location: 0, length: textWithDisplayAttributes.length)
            textWithDisplayAttributes.addAttributes(attrs, range: rangeForParagraph)
            
            return NSTextParagraph(attributedString: textWithDisplayAttributes)
        }
        
        if let format = formatAttr as? FormatType, case .ul = format {
            let attrs = config.attributes(for: .ul)
            let textWithDisplayAttributes = NSMutableAttributedString(attributedString: content)
            let rangeForParagraph = NSRange(location: 0, length: textWithDisplayAttributes.length)
            textWithDisplayAttributes.addAttributes(attrs, range: rangeForParagraph)
            
            return NSTextParagraph(attributedString: textWithDisplayAttributes)
        }

        let attrs = config.attributes(for: .body)
//        let attrs: [NSAttributedString.Key: Any] = [.rtexFormat: RTex.FormatType.body]
        
        var merged = attrs.merging([.rtexFormat: FormatType.body], uniquingKeysWith: { $1 })

        let textWithDisplayAttributes = NSMutableAttributedString(attributedString: content)
//        let rangeForParagraph = NSRange(location: 0, length: textWithDisplayAttributes.length)
//        textWithDisplayAttributes.addAttributes(merged, range: rangeForParagraph)
        
        print("[RTex] bbb", textWithDisplayAttributes)
        
        return NSTextParagraph(attributedString: textWithDisplayAttributes)
    }
    
    public func textContentManager(_ textContentManager: NSTextContentManager, shouldEnumerate textElement: NSTextElement, options: NSTextContentManager.EnumerationOptions = []) -> Bool {
        true
    }
}
