import AppKit

extension RTex {
    public class UnorderedListFormatRuleWithMarkdownSupport: MarkdownLineLevelFormatRule {
        public let type = FormatType.ul
        public let marker: String = "- "
        public let breakStragety = FormatBreak(
            empty: .regress,
            leading: .split,
            trailing: .continue
        )
        public init() {}
        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
            attr.removeAttribute(.rtexFormat, range: range)
        }
        public func apply(_ hosting: RTex.Hosting, with action: RTex.FormatAction) {
            let attrs = hosting.config(forType: type)
            var merged = attrs.merging([], uniquingKeysWith: { $1 })
            // 默认设置为顶级列表（一个 textList）。后续由 Tab/Shift+Tab 调整嵌套层级。
            let baseStyle = (merged[.paragraphStyle] as? NSParagraphStyle) ?? NSParagraphStyle()
            let style = (baseStyle.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            if style.textLists.isEmpty {
                style.textLists = [NSTextList(markerFormat: .disc, options: 0)]
            }
            merged[.paragraphStyle] = style
            
            let content = action.replacement?.string ?? ""
            let replacement = NSAttributedString(string: content, attributes: merged)

            print("[FormatRule \(action.type)] replaceCharacters in range: \(action.range), replacement: \(replacement)")

            hosting.replace(characters: replacement, in: action.range)
        }
    }
}
