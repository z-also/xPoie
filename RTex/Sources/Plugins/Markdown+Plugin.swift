//import AppKit
//
//extension RTex.Markdown {
//    public class Plugin: RTex.Plugin {
//        private let rules: [FormatRule]
//        private weak var rtex: RTex!
//
//        public init(rules: [FormatRule]) {
//            self.rules = rules
//        }
//        
//        public func setup(rtex: RTex, textView: NSTextView, layoutManager: NSTextLayoutManager) {
//            self.rtex = rtex
//        }
//        
//        public func process(input: Character,
//                            in textStorage: NSTextStorage,
//                            at range: NSRange) -> RTex.Editing? {
//            let string = textStorage.string as NSString
//            let lineRange = string.lineRange(for: range)
//            let paragraphRange = string.paragraphRange(for: range)
//
//            print("[Debug] Markdown plugin process input: '\(input)' at range: \(range), lineRange:\(lineRange), paragraphRange: \(paragraphRange), paragraph text: '\(string.substring(with: paragraphRange))'")
//            
//            // 处理当前行的规则
//            for rule in rules(for: input) {
//                print("[Debug] Trying rule: \(type(of: rule)), marker: '\(rule.marker)'")
//                if let result = rule.process(text: string, paragraphRange: paragraphRange, at: range, config: rtex.config) {
//                    print("[Debug] Rule matched! Type: \(result.type), range: \(result.range), replacement: '\(result.replacement)', cursor: \(result.cursor)")
//                    
//                    rtex.performEditingTransaction {
//                        rule.apply(to: rtex.contentStorage, with: result)
//                    }
//                    
//                    return RTex.Editing(
//                        selectedRange: NSRange(location: result.cursor ?? 0, length: 0),
////                        typingAttributes: [.rtexFormat: result.type]
//                        typingAttributes: rtex.config.attributes(for: result.type)
//                    )
//                }
//            }
//            
//            return nil
//        }
//        
//        // Tab/Shift+Tab 在无序列表中缩进/反缩进为次级列表（使用 NSParagraphStyle.textLists）
////        public func intercept(input char: Character, at range: NSRange, modifierFlags: NSEvent.ModifierFlags) -> RTex.Editing? {
////            guard char == "\t" else { return nil }
////            guard let textStorage = rtex.contentStorage.textStorage else { return nil }
////            
////            let nsString = textStorage.string as NSString
////            let paragraphRange = nsString.paragraphRange(for: range)
////            
////            // 仅当当前段落是无序列表时才处理
////            let formatAttr = textStorage.attribute(.rtexFormat, at: paragraphRange.location, effectiveRange: nil)
////            guard let format = formatAttr as? RTex.FormatType, format == .ul else { return nil }
////            
////            let currentStyle = (textStorage.attribute(.paragraphStyle, at: paragraphRange.location, effectiveRange: nil) as? NSParagraphStyle) ?? rtex.config.defaultParagraphStyle
////            let newStyle = (currentStyle.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
////            
////            var lists = newStyle.textLists
////            if modifierFlags.contains(.shift) {
////                // 反缩进：至少保留一级列表；若只有一级则退出列表
////                if lists.count > 1 {
////                    lists.removeLast()
////                } else {
////                    // 退出列表：清空 textLists 并恢复正文格式
////                    newStyle.textLists = []
////                    var attrs = rtex.config.attributes(for: .body)
////                    attrs[.paragraphStyle] = newStyle
////                    rtex.performEditingTransaction { textStorage.addAttributes(attrs, range: paragraphRange) }
////                    return .ignore
////                }
////            } else {
////                // 缩进：增加一个嵌套列表
////                lists.append(NSTextList(markerFormat: .disc, options: 0))
////            }
////            newStyle.textLists = lists
////            
////            var attrs = rtex.config.attributes(for: .ul)
////            attrs[.rtexFormat] = RTex.FormatType.ul
////            attrs[.paragraphStyle] = newStyle
////            
////            rtex.performEditingTransaction {
////                textStorage.addAttributes(attrs, range: paragraphRange)
////            }
////            
////            // 不插入制表符字符
////            return .ignore
////        }
//        
//        private func rules(for inputChar: Character) -> [FormatRule] {
//            rules.filter { $0.triggerCharacters.contains(inputChar) }
//        }
//    }
//}
