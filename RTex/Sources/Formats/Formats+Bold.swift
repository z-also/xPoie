import AppKit

extension RTex {
    public class BoldFormatRule: MarkdownInlineLevelFormatRule {
        public let type = FormatType.bold
        public let marker: String = "**"
//        public let triggerCharacters: Set<Character> = ["`"]

        public init() {}
        public func match(_ hosting: Hosting, range: NSRange) -> Bool {
            let content = hosting.storage.attributedString!
            return Utilities.is(attributedString: content, hasFontTrait: .bold, in: range)
        }
        public func remove(from attr: NSMutableAttributedString, range: NSRange, config: RTex.Config) {
            let attrs = config.attributes(for: .body)
            attr.addAttributes(attrs.merging([.rtexFormat: FormatType.body], uniquingKeysWith: { $1 }), range: range)
        }
        
        public func `break`(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
            nil
        }
        
        public func delete(_ hosting: any RTex.Hosting, at range: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
            nil
        }
        
        public func transform(content: NSAttributedString) -> NSMutableAttributedString {
            let res = RTex.U.add(fontTrait: .bold, content: content)
            
            let range = NSRange(location: 0, length: res.length)
            
            res.addAttributes([.foregroundColor: NSColor.red], range: range)
            
            return res
        }
    }
}
