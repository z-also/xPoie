import AppKit
import Markdown

extension Llmx {
    struct MarkupX: MarkupVisitor {
        let baseFontSize: CGFloat = 15.0

        private let style: Style
                
        init(style: Style = .default) {
            self.style = style
        }
        
        public mutating func attributedString(from document: Document) -> AttributedString {
            return visit(document)
        }
        
        mutating public func defaultVisit(_ markup: Markup) -> AttributedString {
            var result = AttributedString()
            
            for child in markup.children {
                result.append(visit(child))
            }
            
            return result
        }
        
        mutating public func visitText(_ text: Text) -> AttributedString {
            var attr = AttributedString(text.plainText)
            let font = style.baseFont ?? .system(size: style.baseFontSize)
            attr.font = font
            if let color = style.textColor {
                attr.foregroundColor = color
            }
            return attr
        }
        
        mutating public func visitEmphasis(_ emphasis: Emphasis) -> AttributedString {
            var result = defaultVisit(emphasis)
            
            let baseFont = style.baseFont ?? .system(size: style.baseFontSize)
            result.font = baseFont.weight(.bold)
            
            return result
        }
        
        mutating public func visitStrong(_ strong: Strong) -> AttributedString {
            var result = defaultVisit(strong)
            let baseFont = style.baseFont ?? .system(size: style.baseFontSize)
            result.font = baseFont.weight(.bold)
            return result
        }
        
        mutating public func visitParagraph(_ paragraph: Paragraph) -> AttributedString {
            var result = defaultVisit(paragraph)
//            let newline = paragraph.isContainedInList ? "\n" : "\n\n"  // 忽略 hasSuccessor，列表内始终 "\n"
//            let newline = "\n"  // 忽略 hasSuccessor，列表内始终 "\n"
//            result.append(AttributedString(newline))  // 始终 append，但列表内只单 \n
            result.lineHeight = .multiple(factor: style.lineHeightMultiple)
            return result
        }
        
        mutating public func visitHeading(_ heading: Heading) -> AttributedString {
            var result = defaultVisit(heading)
            let size = style.headingSizes[heading.level] ?? style.baseFontSize
            let baseFont = style.baseFont ?? .system(size: size)
            result.font = baseFont.bold()
            
            if heading.hasSuccessor {
                result += AttributedString("\n\n")
            }
            result.lineHeight = .multiple(factor: style.lineHeightMultiple)
            return result
        }
        
        mutating public func visitLink(_ link: Link) -> AttributedString {
            var result = defaultVisit(link)
            result.foregroundColor = style.linkColor
            if let destination = link.destination, let url = URL(string: destination) {
                result.link = url
            }
            return result
        }
        
        mutating public func visitInlineCode(_ inlineCode: InlineCode) -> AttributedString {
            var attr = AttributedString(inlineCode.code)
            let font = style.codeFont ?? .system(size: style.baseFontSize, design: .monospaced)
            attr.font = font
            attr.foregroundColor = style.codeColor
            return attr
        }
        
        public func visitCodeBlock(_ codeBlock: CodeBlock) -> AttributedString {
            var result = AttributedString(codeBlock.code)
            let font = style.codeFont ?? .system(size: style.baseFontSize, design: .monospaced)
            result.font = font
            result.foregroundColor = style.codeColor
            
            if codeBlock.hasSuccessor {
                result += AttributedString("\n")
            }
            return result
        }
        
        mutating public func visitStrikethrough(_ strikethrough: Strikethrough) -> AttributedString {
            var result = defaultVisit(strikethrough)
            
            result.strikethroughStyle = .single
            
            return result
        }
        
        mutating public func visitUnorderedList(_ unorderedList: UnorderedList) -> AttributedString {
            var result = AttributedString()
            let indentOffset = style.listBaseIndent + (style.listIndentPerLevel * CGFloat(unorderedList.listDepth))
            let spacesBeforeBullet = String(repeating: " ", count: Int(indentOffset / 8))
            
            let listItems = Array(unorderedList.listItems)
            for (index, listItem) in listItems.enumerated() {
                var item = visit(listItem)
                
                var bulletPrefix = AttributedString(spacesBeforeBullet + "• ")
                bulletPrefix.font = style.baseFont ?? .system(size: style.baseFontSize)
                
                result += bulletPrefix
                result += item
                
                if index < listItems.count - 1 {
                    result += AttributedString("\n")
                }
            }
            
            result.lineHeight = .multiple(factor: style.lineHeightMultiple)

            return result
        }
        
        mutating public func visitListItem(_ listItem: ListItem) -> AttributedString {
            var result = AttributedString()
            
            for child in listItem.children {
                result.append(visit(child))
            }
            
//            if listItem.hasSuccessor {
//                result.append(AttributedString("\n"))
//            }
            
            return result
        }
        
        mutating public func visitOrderedList(_ orderedList: OrderedList) -> AttributedString {
            var result = AttributedString()
            let indentOffset = style.listBaseIndent + (style.listIndentPerLevel * CGFloat(orderedList.listDepth))
            let spacesBeforeNumber = String(repeating: " ", count: Int(indentOffset / 8))
            
            let maxNumber = orderedList.childCount
            let numberWidth = "\(maxNumber).".count
            
            let listItems = Array(orderedList.listItems)
            for (index, listItem) in listItems.enumerated() {
                let paddedNumber = String(format: "%\(numberWidth)d.", index + 1)
                var numberPrefix = AttributedString(spacesBeforeNumber + paddedNumber + " ")
                numberPrefix.font = style.baseFont ?? .system(size: style.baseFontSize)
                
                var item = visit(listItem)
                result += numberPrefix
                result += item
                
                
                if index < listItems.count - 1 {
                    result += AttributedString("\n")
                }
            }
            result.lineHeight = .multiple(factor: style.lineHeightMultiple)
            return result
        }
        
        mutating public func visitBlockQuote(_ blockQuote: BlockQuote) -> AttributedString {
            var result = AttributedString()
            let indentOffset = style.listBaseIndent + (style.listIndentPerLevel * CGFloat(blockQuote.quoteDepth))
            let spacesBeforeBar = String(repeating: " ", count: Int(indentOffset / 8))
            
            for child in blockQuote.children {
                var childAttr = visit(child)
                if let color = style.secondaryColor {
                    childAttr.foregroundColor = color
                }
                
                var barPrefix = AttributedString(spacesBeforeBar + "│ ")
                barPrefix.foregroundColor = style.quoteBarColor
                barPrefix.font = style.baseFont ?? .system(size: style.baseFontSize)
                
                result += barPrefix
                result += childAttr
            }
            
            if blockQuote.hasSuccessor {
                result += AttributedString("\n\n")
            }
            result.lineHeight = .multiple(factor: style.lineHeightMultiple)
            return result
        }
    }
}

extension Markup {
    var hasSuccessor: Bool {
        guard let childCount = parent?.childCount else { return false }
        return indexInParent < childCount - 1
    }
    
    var isContainedInList: Bool {
        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                return true
            }

            currentElement = currentElement?.parent
        }
        
        return false
    }
}

extension BlockQuote {
    var quoteDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is BlockQuote {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

extension ListItemContainer {
    var listDepth: Int {
        var index = 0

        var currentElement = parent

        while currentElement != nil {
            if currentElement is ListItemContainer {
                index += 1
            }

            currentElement = currentElement?.parent
        }
        
        return index
    }
}

