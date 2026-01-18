import AppKit

extension RTex {
    public class HeadingFormatRuleWithMarkdownSupport: MarkdownLineLevelFormatRule {
        public let level: Int
        public let type: FormatType
        public let marker: String
        public let breakStragety = FormatBreak(
            empty: .regress,
            leading: .split,
            trailing: .break
        )
        public init(level: Int) {
            self.level = level
            self.type = .heading(level)
            self.marker = String(repeating: "#", count: level) + " "
        }
        
        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
            let attrs = config.attributes(for: .body)
            attr.setAttributes(attrs.merging([.rtexFormat: FormatType.body], uniquingKeysWith: { $1 }), range: range)
        }
    }
}
