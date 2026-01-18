import AppKit

extension RTex {
    public enum FormatType: Hashable, Codable, Sendable {
        case bold
        case italic
        case heading(Int)
        case blockquote
        case image
        case body
        case ul
    }
    
    public struct FormatAction {
        let type: FormatType
        let range: NSRange
        var replacement: NSAttributedString? = nil
        var cursor: Int? = nil
    }

    public protocol FormatRule {
        var type: FormatType { get }
//        func match(_ hosting: Hosting, range: NSRange) -> Bool
        func apply(_ hosting: Hosting, with action: FormatAction)
        func remove(from attr: NSMutableAttributedString, range: NSRange, config: Config)
        func `break`(_ hosting: Hosting, at range: NSRange, paragraph: Paragraph) -> Editing?
        func delete(_ hosting: Hosting, at range: NSRange, paragraph: Paragraph) -> Editing?
        func trigger(by input: Character) -> Bool
        func process(_ hosting: Hosting, text: NSString, paragraphRange: NSRange, at newInputRange: NSRange) -> FormatAction?
    }
    
    public struct FormatBreak {
        enum Stragety {
            case split
            case regress
            case `break`
            case `continue`
        }
        
        let empty: Stragety
        let leading: Stragety
        let trailing: Stragety
    }
    
    public protocol LineFormatRule: FormatRule {
        var breakStragety: FormatBreak { get }
    }
    
    public protocol InlineFormatRule: FormatRule {}
}

extension RTex {
    public struct Attributes: AttributeScope {
        public struct Format: CodableAttributedStringKey {
            public typealias Value = FormatType
            public static let name = "rtex.format"
        }

        public let format: Format
        let appKit: AttributeScopes.AppKitAttributes
        let swiftUI: AttributeScopes.SwiftUIAttributes
        
        subscript<T>(dynamicMember keyPath: KeyPath<Attributes, T>) -> T where T : AttributedStringKey {
            return self[keyPath: keyPath]
        }
    }
}

public extension AttributeScopes {
    var rtex: RTex.Attributes.Type { RTex.Attributes.self }
}

public extension NSAttributedString.Key {
    static let rtexFormat = NSAttributedString.Key("rtex.format")
}

public extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<RTex.Attributes, T>) -> T {
        self[T.self]
    }
}

public extension NSAttributedString {
    func toAttributedString() -> AttributedString {
        var result = AttributedString(self)
        
        enumerateAttribute(.rtexFormat, in: NSRange(location: 0, length: length), options: []) { value, range, _ in
            guard let formatType = value as? RTex.FormatType else {
                return
            }
            
            if let stringRange = Range(range, in: result) {
                result[stringRange].rtex.format = formatType
            }
        }
        
        return result
    }
}

public extension AttributedString {
    func toNSAttributedString() -> NSAttributedString {
        let mutableAttrString = NSMutableAttributedString(self)
        
        for run in runs {
            let range = run.range
            let attributes = run.attributes
            
            if let rtexFormatValue = attributes[RTex.Attributes.Format.self] {
                let nsRange = NSRange(range, in: self)
                mutableAttrString.addAttribute(.rtexFormat, value: rtexFormatValue, range: nsRange)
            }
        }
        
        return mutableAttrString
    }
}
