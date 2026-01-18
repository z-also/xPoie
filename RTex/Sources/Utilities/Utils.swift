import AppKit
import SwiftUI

public struct Utilities {
    /// 表示一段文本的选择信息（段落级别）
    public struct ParagraphSelection {
        /// 选区在该段落内的文本内容
        public let selectionText: String
        /// 选区在整个文本中的范围
        public let selectionRange: NSRange
//        public let selectionAttributes: [NSAttributedString.Key: Any]
        
        /// 选区相对于段落的起始位置
        public let startIndex: Int
        /// 选区相对于段落的结束位置
        public let endIndex: Int
        
        /// 该段落完整的文本内容
        public let paragraphText: String
        /// 该段落在整个文本中的范围
        public let paragraphRange: NSRange
    }
    
    public static func isEmpty(_ string: String) -> Bool {
        return string.isEmpty || string == "\n"
    }
    
    public static func isEmpty(_ attributed: NSAttributedString) -> Bool {
        return isEmpty(attributed.string)
    }
    
    private static func extractHeadingLevel(from intentString: String) -> Int? {
        let pattern = #"heading\((\\d+)\)"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: intentString, range: NSRange(intentString.startIndex..., in: intentString)),
           let range = Range(match.range(at: 1), in: intentString) {
            return Int(intentString[range])
        }
        return nil
    }

    public static func lines(of ns: NSAttributedString, in range: NSRange) -> [(String)] {
        var result: [(String)] = []
        let string = ns.string as NSString
        print("vv", range, string.length)

        // 处理 range.length = 0 的情况（光标位置）
        if range.length == 0, range.location < string.length {
            // 获取光标所在的整行
            let lineRange = string.lineRange(for: NSRange(location: range.location, length: 0))
            let lineString = string.substring(with: lineRange)
            result.append(lineString)
        } else {
            // 常规 range 处理
            string.enumerateSubstrings(in: range, options: .byLines) { (substring, range, _, _) in
                if let substring = substring {
                    result.append(substring)
                }
            }
        }

        return result
    }
    
    public static func paragraphSelections(of attributedString: NSAttributedString, in range: NSRange) -> [ParagraphSelection] {
        var result: [ParagraphSelection] = []

        var currentLocation = range.location
        
        let ax = attributedString.string as NSString

        while currentLocation <= range.location + range.length {
            let r = NSRange(location: currentLocation, length: 0)
            let paragraphRange = ax.paragraphRange(for: r)
            let selectionRange = NSIntersectionRange(paragraphRange, range)
            
            let fullParagraphText = attributedString.attributedSubstring(from: paragraphRange).string
            let selectedText = attributedString.attributedSubstring(from: selectionRange).string
            
            let selectionStartInParagraph = selectionRange.location - paragraphRange.location
            let selectionEndInParagraph = selectionStartInParagraph + selectionRange.length
            
            result.append(ParagraphSelection(
                selectionText: selectedText,
                selectionRange: selectionRange,
                startIndex: selectionStartInParagraph,
                endIndex: selectionEndInParagraph,
                paragraphText: fullParagraphText,
                paragraphRange: paragraphRange
            ))
            
            currentLocation = paragraphRange.location + paragraphRange.length + 1
        }
        
        return result
    }
    
    public static func `is`(attributedString: NSAttributedString,
                            hasFontTrait trait: NSFontDescriptor.SymbolicTraits,
                            in range: NSRange) -> Bool {
        var res = false
        attributedString.enumerateAttribute(
            .font,
            in: range,
            options: .longestEffectiveRangeNotRequired) { font, _range, stop in
            guard let font = font as? NSFont else {
                res = false
                stop.pointee = true // 无字体属性，直接终止遍历
                return
            }
            
            res = font.fontDescriptor.symbolicTraits.contains(trait)
            
            if !res {
                stop.pointee = true
            }
        }
        return res
    }
    
    public static func isTab(event: NSEvent) -> Bool {
        if let chars = event.characters, let char = chars.first, char == "\t" {
            return true
        }
        return false
    }
    
    public static func isEnter(event: NSEvent) -> Bool {
        if let chars = event.characters, let char = chars.first, char == "\n" || char == "\r" {
            return true
        }
        return false
    }
}

extension RTex {
    public typealias U = Utilities
}
