import AppKit

extension RTex {
    public protocol MarkdownLineLevelFormatRule: LineFormatRule {
        var marker: String { get }
        var triggerCharacters: Set<Character> { get }
    }
    
    public protocol MarkdownInlineLevelFormatRule: InlineFormatRule {
        var marker: String { get }
        var triggerCharacters: Set<Character> { get }
        func transform(content: NSAttributedString) -> NSMutableAttributedString
    }
}

public extension RTex.MarkdownLineLevelFormatRule {
    var triggerCharacters: Set<Character> { [" "] }

    func trigger(by input: Character) -> Bool {
        return triggerCharacters.contains(input)
    }
    
    func process(_ hosting: RTex.Hosting, text: NSString, paragraphRange: NSRange, at newInputRange: NSRange) -> RTex.FormatAction? {
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
    
    func `break`(_ hosting: RTex.Hosting, at: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? {
        let from = at.location - paragraph.range.location
        let relRange = NSRange(
            location: from,
            length: paragraph.content.length - from
        )
        let tonext = paragraph.content.attributedSubstring(from: relRange)
        
        if Utilities.isEmpty(paragraph.content) && breakStragety.empty == .regress {
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
    func apply(_ hosting: RTex.Hosting, with action: RTex.FormatAction) {
        let attrs: [NSAttributedString.Key: Any] = [.rtexFormat: action.type]
        let content = action.replacement?.string ?? ""
        let replacement = NSAttributedString(string: content, attributes: attrs)
        print("[FormatRule \(action.type)] replaceCharacters in range: \(action.range), replacement: \(replacement)")
        hosting.replace(characters: replacement, in: action.range)
    }
    
    func delete(_ hosting: RTex.Hosting, at: NSRange, paragraph: RTex.Paragraph) -> RTex.Editing? { nil }
}

public extension RTex.MarkdownInlineLevelFormatRule {
    var triggerCharacters: Set<Character> { Set(marker) }
    
    func trigger(by input: Character) -> Bool {
        return triggerCharacters.contains(input)
    }
    
    func process(_ hosting: RTex.Hosting, text: NSString, paragraphRange: NSRange, at newInputRange: NSRange) -> RTex.FormatAction? {
        let line = text.substring(with: paragraphRange)
        let nsLine = line as NSString
        let markerLen = marker.count
        
        // 获取新输入的字符在行内的位置
        let newInputLocation = newInputRange.location - paragraphRange.location
        
        // 最小有效模式要求：marker + 至少一个字符 + marker前缀
        let minValidLength = markerLen + 1 + (markerLen - 1)
        guard newInputLocation >= minValidLength else {
            print("[Debug] MarkdownInlineLevelFormatRule \(type) not ok: to short")
            return nil
        }
        
        // 检查新输入位置前的 markerLen-1 个字符是否与标记的前缀匹配
        let prefixStart = newInputLocation - (markerLen - 1)
        guard nsLine.length >= markerLen - 1,
              nsLine.substring(with: NSRange(location: prefixStart, length: markerLen - 1)) == String(marker.dropLast())
        else {
            print("[Debug] MarkdownInlineLevelFormatRule \(type) not ok: no complete marker")
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
        
        print("[Debug] MarkdownInlineLevelFormatRule \(type) ok: contentLength: \(contentLength)")

        // 确保开始和结束标记之间有内容
        guard contentLength > 0 else {
            return nil
        }
        
        // 提取内容并创建替换字符串
        let content = nsLine.substring(with: NSRange(location: contentStart, length: contentLength))
        
        let contentR = NSRange(location: paragraphRange.location + contentStart, length: contentLength)
        
        let contentAs = hosting.attributedSubstring(from: contentR)
        
        let replacement = transform(content: contentAs)
        
        // 计算完整范围（包括标记）
        let fullRange = NSRange(
            location: paragraphRange.location + start,
            length: (newInputLocation - start) + 1
        )
        
        return RTex.FormatAction(
            type: type,
            range: fullRange,
            replacement: replacement,
            cursor: fullRange.location + contentLength
        )
    }
    
    func apply(_ hosting: RTex.Hosting, with action: RTex.FormatAction) {
        if let replacement = action.replacement {
            print("[FormatRule \(action.type)] replaceCharacters in range: \(action.range), replacement: \(replacement)")
            hosting.replace(characters: replacement, in: action.range)
        }
    }
}
