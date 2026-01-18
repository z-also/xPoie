import SwiftUI
import Markdown
import Foundation

extension String.Index {
    init(_ location: SourceLocation, in string: String) {
        let lines = string.components(separatedBy: .newlines)
        var currentOffset = 0
        var targetLineIndex = location.line - 1  // 1-indexed to 0-indexed
        
        if targetLineIndex >= lines.count {
            self = string.endIndex
            return
        }
        
        // 计算前 targetLine-1 行的总长度 + 换行
        for i in 0..<targetLineIndex {
            currentOffset += lines[i].utf8.count + 1  // +1 for \n
        }
        
        let lineString = lines[targetLineIndex]
        let columnOffset = location.column - 1  // 1-indexed to 0-indexed
        
        let utf8View = lineString.utf8
        let clampedColumn = min(columnOffset, utf8View.count)
        let lineIndex = utf8View.index(utf8View.startIndex, offsetBy: clampedColumn)
        
        // 总 index = 前行 offset + lineIndex
        let absoluteOffset = currentOffset + lineString.distance(from: lineString.startIndex, to: lineIndex)
        
        self = string.index(string.startIndex, offsetBy: absoluteOffset, limitedBy: string.endIndex) ?? string.endIndex
    }
}

extension Llmx {
    public class Streaming {
        private var style: Style
        private var bufferingString = ""
        private var bufferingDocument: Document? = nil
        
        @Binding private var bufferingSegment: AttributedString
        @Binding private var committedSegments: [AttributedString]

        public init(style: Style,
                    committed: Binding<[AttributedString]>,
                    buffering: Binding<AttributedString>) {
            self.style = style
            _bufferingSegment = buffering
            _committedSegments = committed
        }
        
        public func receive(string content: String) {
            bufferingString += content
            commitBlocksIfPossible()
        }
        
        private func commitBlocksIfPossible() {
            let document = Document(parsing: bufferingString)
            bufferingDocument = document
            
            var blockList: [BlockMarkup] = []
            for block in document.blockChildren {
                blockList.append(block)
            }
            
//            var blockList2 = document.blockChildren.map{ $0 }
            
            if blockList.isEmpty {
                return
            }
            
            var commitCount = 0
            
            // TODO debug. under order list
            blockList = blockList.filter{ !($0 is ThematicBreak) }
            
            if blockList.count > 1 {
                commitCount = blockList.count - 1
            } else if let singleBlock = blockList.first, isBlockComplete(singleBlock) {
                commitCount = 1
            }
                        
            
            // commit 前面的完整块
            for i in 0..<commitCount {
                let block = blockList[i]
                let attr = parseBlock(block)
                committedSegments.append(attr)
            }
            
            var remaining = bufferingString
            
            if commitCount > 0,
               let lastBlock = blockList[commitCount - 1] as? any Markup,
               let sourceRange = lastBlock.range {
                
                let upperBoundIndex = String.Index(sourceRange.upperBound, in: bufferingString)
                remaining = String(bufferingString[upperBoundIndex...])
            }
            
            // Step 2: 计算这些块的总字符长度（使用 format() 作为近似源长度）
//            var totalCommittedLength = 0
//            for i in 0..<commitCount {
//                let blockSource = blockList[i].format()
//                totalCommittedLength += blockSource.count
//            }
            
            // Step 3: 直接从 streamingBuffer 开头截取掉这个长度
            // 注意：这里用 dropFirst 是安全的近似
//            let remainingBuffer = String(bufferingString.dropFirst(totalCommittedLength))
            
            // 可选：清理前导空白（常见于段落间 \n\n 被压缩的情况）
//            bufferingString = remainingBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
//            bufferingString = remaining
            var cleaned = remaining

            // 删除开头的空行（\n\n 或多个 \n），但保留内容
//            while cleaned.hasPrefix("\n") {
//                cleaned.removeFirst()
//                // 可选：最多删除 2 个，防止过度
//                // if cleaned.hasPrefix("\n") { cleaned.removeFirst() } else { break }
//            }
//
//            bufferingString = cleaned
            
            // 清理前导空行
            if cleaned.hasPrefix("\n\n") {
                cleaned.removeFirst(2)
            } else if cleaned.hasPrefix("\n") {
                cleaned.removeFirst(1)
            }
            
            bufferingString = cleaned

            if bufferingString.isEmpty {
                bufferingSegment = AttributedString()
                bufferingDocument = nil
            } else {
                let doc = Document(parsing: bufferingString)
                bufferingSegment = parseBlock(doc)
                bufferingDocument = doc
            }
        }
        
        private func isBlockComplete(_ block: BlockMarkup) -> Bool {
            switch block {
            case is Paragraph:
                // 段落完整性的唯一可靠标志：缓冲区以空行结尾
                let trimmed = bufferingString.trimmingCharacters(in: .whitespaces)
                return trimmed.hasSuffix("\n\n") || trimmed.hasSuffix("\n\n\n")
                
            case is Heading:
                // 标题通常以单换行结束，且后面跟新内容，算完整
                return true
                
            case is CodeBlock:
                // 代码块必须以 ``` 闭合
                if let codeBlock = block as? CodeBlock {
                    return codeBlock.language == nil || codeBlock.code.contains("```")
                }
                return false
                
            case is BlockQuote:
                // 引用块相对复杂，保守起见只有缓冲以空行结尾才 commit
                return bufferingString.trimmingCharacters(in: .whitespaces).hasSuffix("\n\n")
                
            case is UnorderedList, is OrderedList:
                // 列表：如果缓冲以空行结尾，或列表项明显中断
                let trimmed = bufferingString.trimmingCharacters(in: .whitespaces)
                return trimmed.hasSuffix("\n\n") || trimmed.hasSuffix("\n\n\n")
                
            default:
                return false
            }
        }
        
        private func hasUnclosedInline(in block: BlockMarkup) -> Bool {
            // 检查是否有未闭合的 inline 如 *bold* 或 [link]
            // 简单实现：遍历 inline 孩子，检查未匹配的 delimiters
            // 为简化，可用正则检查缓冲中 *、` 等奇数出现
            let delimiters = ["*", "_", "[", "]", "`"]
            return delimiters.contains { char in
                bufferingString.filter { $0 == Character(char) }.count % 2 != 0
            }
        }
        
        private func commitBlock(_ block: BlockMarkup) {
            var visitor = MarkupX()
            let attr = visitor.visit(block)
            committedSegments.append(attr)
        }
        
        private func parseBlock(_ block: BlockMarkup) -> AttributedString {
            var visitor = MarkupX(style: style)
            let attr = visitor.visit(block)
            return attr
        }
    }
}
