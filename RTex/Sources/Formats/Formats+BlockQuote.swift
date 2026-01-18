import AppKit

extension RTex {
    public class BlockQuoteFormatRuleWithMarkdownSupport: MarkdownLineLevelFormatRule {
        public var type: FormatType { .blockquote }
        public let marker: String = "> "
        public let breakStragety = FormatBreak(
            empty: .regress,
            leading: .split,
            trailing: .continue
        )
        public init() {}
        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
            attr.removeAttribute(.rtexFormat, range: range)
        }
    }
}
