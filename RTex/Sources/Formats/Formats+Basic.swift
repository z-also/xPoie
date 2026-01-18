import AppKit

extension RTex {
    public class ItalicFormatRule: InlineFormatRule {
        public var type: FormatType { .italic }
        public init() {}
        public func match(_ hosting: Hosting, range: NSRange) -> Bool {
            let content = hosting.storage.attributedString!
            return Utilities.is(attributedString: content, hasFontTrait: .italic, in: range)
        }
        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
            let attrs = config.attributes(for: .body)
            attr.addAttributes(attrs.merging([.rtexFormat: FormatType.body], uniquingKeysWith: { $1 }), range: range)
        }
        public func apply(_ hosting: Hosting, with action: FormatAction) {
            hosting.performEditingTransaction {
                hosting.toggle(fontTrait: .italic, at: action.range)
            }
        }
        public func trigger(by input: Character) -> Bool { false }
        public func process(_ hosting: Hosting, text: NSString, paragraphRange: NSRange, at newInputRange: NSRange) -> FormatAction? {
            nil
        }
        public func `break`(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
            nil
        }
        
        public func delete(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
            nil
        }
    }
    
//    public class ImageFormatRule: FormatRule {
//        public var type: FormatType { .image }
//        public func match(_ hosting: Hosting, range: NSRange) -> Bool {
//            false
//        }
//        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
//            let attrs = config.attributes(for: .body)
//            attr.addAttributes(attrs.merging([.rtexFormat: FormatType.body], uniquingKeysWith: { $1 }), range: range)
//        }
//        public func trigger(by input: Character) -> Bool { false }
//        public func process(text: NSString, paragraphRange: NSRange, at newInputRange: NSRange, config: Config) -> FormatAction? {
//            nil
//        }
//        public func `break`(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
//            nil
//        }
//        
//        public func delete(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
//            nil
//        }
//    }
    
//    public class UnorderedListFormatRule: LineFormatRule {
//        public var type: FormatType { .ul }
//        public let breakStragety = FormatBreak(
//            empty: .regress,
//            leading: .split,
//            trailing: .continue
//        )
//        public init() {}
//        public func apply(to attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
//            let nsString = attr.string as NSString
//            let paraRange = nsString.paragraphRange(for: range)
//            let attrs = config.attributes(for: type)
//            let safeRange = NSRange(
//                location: min(paraRange.location, attr.length),
//                length: min(paraRange.length, attr.length - min(paraRange.location, attr.length))
//            )
//            if safeRange.length > 0 {
//                var merged = attrs.merging([.rtexFormat: type], uniquingKeysWith: { $1 })
//                // 默认设置为顶级列表（一个 textList）。后续由 Tab/Shift+Tab 调整嵌套层级。
//                let baseStyle = (merged[.paragraphStyle] as? NSParagraphStyle) ?? NSParagraphStyle()
//                let style = (baseStyle.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
//                if style.textLists.isEmpty { style.textLists = [NSTextList(markerFormat: .disc, options: 0)] }
//                merged[.paragraphStyle] = style
//                attr.addAttributes(merged, range: safeRange)
//            }
//        }
//        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
//            let attrs = config.attributes(for: .body)
//            attr.setAttributes(attrs.merging([.rtexFormat: RTex.FormatType.body], uniquingKeysWith: { $1 }), range: range)
//        }
//        public func trigger(by input: Character) -> Bool { false }
////        public func onNewline(currentLine: NSAttributedString, config: RTex.Config) -> Editing? {
////            // 非空内容：继续无序列表；空内容交由调用方处理为退出
////            let trimmed = currentLine.string.trimmingCharacters(in: .whitespacesAndNewlines)
////            if trimmed.isEmpty {
////                return Editing(
////                    behavior: .accept,
////                    typingAttributes: config.attributes(for: .body)
////                )
////            }
////            var attrs = config.attributes(for: type).merging([.rtexFormat: type], uniquingKeysWith: { $1 })
////            let currentStyle = (currentLine.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle) ?? config.defaultParagraphStyle
////            let style = (currentStyle.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
////            // 保持当前行的嵌套层级
////            attrs[.paragraphStyle] = style
////            return Editing(
////                behavior: .accept,
////                typingAttributes: attrs
////            )
////        }
//        public func process(text: NSString, paragraphRange: NSRange, at newInputRange: NSRange, config: Config) -> FormatAction? {
//            nil
//        }
//        public func `break`(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
//            nil
//        }
//        
//        public func delete(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
//            nil
//        }
//    }
}

public extension RTex.FormatRule {
}

public extension RTex.LineFormatRule {
    func `break`(_ hosting: RTex.Hosting, at: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
        let from = at.location - paragraph.range.location
        let relRange = NSRange(
            location: from,
            length: paragraph.content.length - from
        )
        let tonext = paragraph.content.attributedSubstring(from: relRange)
        
        if Utilities.isEmpty(paragraph.content) && breakStragety.empty == .regress {
            print("eeeeeeeeeee", paragraph)
            hosting.remove(format: type, at: paragraph.range)
            return .ignore
        }
        
        if !Utilities.isEmpty(paragraph.content) && breakStragety.trailing == .continue {
            let attrs: [NSAttributedString.Key: Any] = [
                .rtexFormat: type
            ]
            let insertAt = paragraph.range.upperBound
            let insertion = NSAttributedString(string: "\n", attributes: attrs)
            hosting.insert(insertion, at: insertAt)
            hosting.set(typingAttributes: attrs)
            hosting.set(selectedRange: NSRange(location: insertAt, length: 0))
            return RTex.Editing(behavior: .ignore)
        }
        
        print("[LineFormatRule] \(type) break at \(at), paragraph: \(paragraph), tonext: \(tonext)")
        
        if tonext.string.isEmpty || tonext.string == "\n" {
            let attrs: [NSAttributedString.Key: Any] = [
                .rtexFormat: RTex.FormatType.body
            ]
            let breaked = tonext.string == "\n"
            let insertAt = at.upperBound + (breaked ? 1 : 0)
            let insertion = NSAttributedString(string: "\n", attributes: attrs)
            hosting.insert(insertion, at: insertAt)
            hosting.set(typingAttributes: attrs)
            hosting.set(selectedRange: NSRange(location: insertAt + (breaked ? 0 : 1), length: 0))
            return RTex.Editing(behavior: .ignore)
        }
        
        return nil
    }
    
    func delete(_ hosting: RTex.Hosting, at: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
        if Utilities.isEmpty(paragraph.content) {
            hosting.remove(format: type, at: paragraph.range)
            hosting.set(typingAttributes: hosting.config(forType: .body))
            return RTex.Editing(behavior: .ignore)
        }
        
        return nil
    }
    
    func match(_ hosting: RTex.Hosting, range: NSRange) -> Bool {
        false
    }
}
