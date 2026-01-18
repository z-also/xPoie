import AppKit

extension RTex {
    public class Markdown {
        public protocol FormatRule {
            var type: FormatType { get }
            var marker: String { get }
            var triggerCharacters: Set<Character> { get }
            func process(text: NSString, paragraphRange: NSRange, at newInputRange: NSRange, config: RTex.Config) -> FormatAction?
            func apply(to storage: NSTextContentStorage, with action: FormatAction)
        }
        
        public protocol LineFormatRule: FormatRule {}
        
        public protocol InlineFormatRule: FormatRule {}
        
        public struct HeadingFormatRule: LineFormatRule {
            public let level: Int
            public let marker: String
            public let type: FormatType
            
            public init(level: Int) {
                self.level = level
                self.marker = String(repeating: "#", count: level) + " "
                self.type = .heading(level)
            }
        }
        
        public struct BlockQuoteFormatRule: LineFormatRule {
            public let marker: String = "> "
            public let type: FormatType = .blockquote
            public init() {}
        }
        
        public struct BoldFormatRule: InlineFormatRule {
            public let marker: String = "**"
            public let type: FormatType = .bold
        }
        
        public struct ItalicFormatRule: InlineFormatRule {
            public let marker: String = "_"
            public let type: FormatType = .italic
        }
        
        public struct UnorderedListFormatRule: LineFormatRule {
            public let marker: String = "- "
            public let type: FormatType = .ul
            public init() {}
            public func apply(to storage: NSTextContentStorage, with action: RTex.FormatAction) {
                
            }
        }
    }
}

public extension RTex.Markdown.FormatRule {
    func apply(to storage: NSTextContentStorage, with action: RTex.FormatAction) {
        let attrs: [NSAttributedString.Key: Any] = [.rtexFormat: action.type]
        let content = action.replacement?.string ?? ""
        let replacement = NSAttributedString(string: content, attributes: attrs)
        print("[FormatRule \(action.type)] replaceCharacters in range: \(action.range), replacement: \(replacement)")
        storage.textStorage!.replaceCharacters(in: action.range, with: replacement)
    }
}

public extension RTex.Markdown.LineFormatRule {
    var triggerCharacters: Set<Character> { [" "] }
    
    func process(text: NSString, paragraphRange: NSRange, at newInputRange: NSRange, config: RTex.Config) -> RTex.FormatAction? {
        let line = text.substring(with: paragraphRange)
        let newInputLocation = newInputRange.location + 1 - paragraphRange.location
        
        print("[Debug] LineFormatRule processing - paragraphRange: \(paragraphRange), line: '\(line)', marker: '\(marker)'")
        print("[Debug] newInputLocation: \(newInputLocation), text length: \(text.length)")
        
        // 获取从行开始到新输入位置的内容
        let endOfMarkerRange = NSRange(location: paragraphRange.location, length: newInputLocation)
        let textUpToCursor = text.substring(with: endOfMarkerRange)
        
        print("[Debug] textUpToCursor: '\(textUpToCursor)' vs marker: '\(marker)'")
        
        // 检查是否以marker开头
        if textUpToCursor == marker {
            var replacementContent = String(line.dropFirst(marker.count))
            
//            if let lastChar = line.last, lastChar != "\n" {
//                replacementContent += "\n"
//            }
            
            
            
//            if replacementContent.isEmpty {
//                replacementContent = Consts.zeroWidthChar
//            }
            
//            if let lastChar = line.last, lastChar == "\n" {
//                cursor = cursor - 1
//            }

            var cursor = paragraphRange.location + replacementContent.count
            
            if let lastChar = replacementContent.last, lastChar == "\n" {
                cursor = cursor - 1
            }
            
            let replacement = NSAttributedString(string: replacementContent, attributes: [:])

            print("[Debug] fullParagraphRange: \(paragraphRange), text length: \(text.length), line content: '\(line)', lineLength: \(line.count), replacement content: '\(replacementContent)', cursor: \(cursor); replacemet length: \(replacement.length), ")

            return RTex.FormatAction(
                type: type,
                range: paragraphRange,
                replacement: replacement,
                cursor: cursor
            )
        }
        
        return nil
    }
}

public extension RTex.Markdown.InlineFormatRule {
    var triggerCharacters: Set<Character> { Set(marker) }
    
    func process(text: NSString, paragraphRange: NSRange, at newInputRange: NSRange, config: RTex.Config) -> RTex.FormatAction? {
        let line = text.substring(with: paragraphRange)
        let nsLine = line as NSString
        let markerLen = marker.count
        
        // 获取新输入的字符在行内的位置
        let newInputLocation = newInputRange.location - paragraphRange.location
        
        // 最小有效模式要求：marker + 至少一个字符 + marker前缀
        let minValidLength = markerLen + 1 + (markerLen - 1)
        guard newInputLocation >= minValidLength else {
            return nil
        }
        
        // 检查新输入位置前的 markerLen-1 个字符是否与标记的前缀匹配
        let prefixStart = newInputLocation - (markerLen - 1)
        guard nsLine.length >= markerLen - 1,
              nsLine.substring(with: NSRange(location: prefixStart, length: markerLen - 1)) == String(marker.dropLast())
        else {
            return nil
        }
        
        // 计算搜索范围：从行开始到前缀开始位置
        let searchRange = NSRange(location: 0, length: prefixStart)
        
        // 查找最后一个匹配的marker
        var start = -1
        for i in stride(from: searchRange.upperBound - markerLen, through: 0, by: -1) {
            let range = NSRange(location: i, length: markerLen)
            if nsLine.substring(with: range) == marker {
                start = i
                break
            }
        }
        
        // 确保找到了开始标记
        guard start != -1 else {
            return nil
        }
        
        // 计算内容范围
        let contentStart = start + markerLen
        let contentLength = (newInputLocation - markerLen + 1) - contentStart
        
        // 确保开始和结束标记之间有内容
        guard contentLength > 0 else {
            return nil
        }
        
        // 提取内容并创建替换字符串
        let content = nsLine.substring(with: NSRange(location: contentStart, length: contentLength))
        let replacement = NSAttributedString(string: content)
        
        // 计算完整范围（包括标记）
        let fullRange = NSRange(
            location: paragraphRange.location + start,
            length: (newInputLocation - start) + 1
        )
        
        return RTex.FormatAction(
            type: type,
            range: fullRange,
            replacement: replacement,
            cursor: fullRange.location
        )
    }
}
