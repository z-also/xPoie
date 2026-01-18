import AppKit

public extension Utilities {
    static func add(fontTrait: NSFontDescriptor.SymbolicTraits,
                    content: NSAttributedString) -> NSMutableAttributedString {
        let res = NSMutableAttributedString(attributedString: content)
        let range = NSRange(location: 0, length: res.length)
        let defaultFont = NSFont.systemFont(ofSize: 16.7)
        
        // 1. 先确保所有地方都有字体（使用默认字体填充缺失的部分）
        res.enumerateAttribute(.font, in: range) { value, range, stop in
            if value == nil {
                let fontToUse = defaultFont
                res.addAttribute(.font, value: fontToUse, range: range)
            }
        }
        
        content.enumerateAttribute(.font, in: range) { value, range, _ in
            guard let font = value as? NSFont else { return }
            
            var traits = font.fontDescriptor.symbolicTraits
            
            if !traits.contains(fontTrait) {
                traits.insert(fontTrait)
            }
            
            let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits)
            guard let newFont = NSFont(descriptor: newDescriptor, size: font.pointSize) else {
                return
            }
            
            res.addAttribute(.font, value: newFont, range: range)
        }

        return res
    }
}
