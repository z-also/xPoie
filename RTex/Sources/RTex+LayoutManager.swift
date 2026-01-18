import AppKit

extension RTex: @MainActor NSTextLayoutManagerDelegate {
    // 检查指定位置的段落是否具有指定格式
    private func isParagraph(at location: Int, hasFormat formatType: RTex.FormatType) -> Bool {
        guard let textStorage = contentStorage.textStorage, location >= 0, location < textStorage.length else {
            return false
        }
        
        let nsString = textStorage.string as NSString
        // 获取包含该位置的段落范围
        let paraRange = nsString.paragraphRange(for: NSRange(location: location, length: 0))
        
        // 检查目标段落是否为指定格式
        if paraRange.location >= 0 && paraRange.location < textStorage.length {
            let attr = textStorage.attribute(.rtexFormat, at: paraRange.location, effectiveRange: nil)
            if let format = attr as? RTex.FormatType, format == formatType {
                return true
            }
        }
        
        return false
    }

    @MainActor public func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        textLayoutFragmentFor location: any NSTextLocation,
        in textElement: NSTextElement
    ) -> NSTextLayoutFragment {
        var format: FormatType?
        let range = textElement.elementRange
        
        if let para = textElement as? NSTextParagraph, para.attributedString.length > 0 {
            format = para.attributedString.attribute(.rtexFormat, at: 0, effectiveRange: nil) as? FormatType
        } else {
//            format = textView.typingAttributes[.rtexFormat] as? FormatType
        }
        
        print("[LayoutManager] Creating fragment for format: \(format), range: \(range), textElement: \((textElement as? NSTextParagraph)?.attributedString)")
        
        if format == .blockquote {
            return BlockQuoteLayoutFragment(textElement: textElement, range: range)
        }
        
        if format == .ul {
            return UnorderedListLayoutFragment(textElement: textElement, range: range)
        }
        
        if case .heading(let _) = format {
            return HeadingLayoutFragment(textElement: textElement, range: range)
        }

        return ParagraphLayoutFragment(textElement: textElement, range: range)
    }
}
