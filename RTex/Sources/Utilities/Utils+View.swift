import AppKit

public extension Utilities {
    @MainActor static func constraint(_ a: NSView, to b: NSView?) {
        guard let b = b else { return }
        
        a.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutConstraints = [
            a.leadingAnchor.constraint(equalTo: b.leadingAnchor),
            a.trailingAnchor.constraint(equalTo: b.trailingAnchor),
            a.topAnchor.constraint(equalTo: b.topAnchor),
            a.bottomAnchor.constraint(equalTo: b.bottomAnchor)
        ]

        b.addConstraints(layoutConstraints)
    }
    
    static func calcContentRect(layoutManager: NSTextLayoutManager, contentStorage: NSTextContentStorage) -> CGRect {
        var totalRect = CGRect.zero
        var lastLineHeight: CGFloat = 0
        var lastFragmentEndsWithNewline = false
        
        
        layoutManager.ensureLayout(for: layoutManager.documentRange)
        
        // Enumerate all layout fragments
        layoutManager.enumerateTextLayoutFragments(from: nil, options: []) { fragment in
            totalRect = totalRect.union(fragment.layoutFragmentFrame)
            lastLineHeight = fragment.layoutFragmentFrame.height
            
            if let lastLine = fragment.textLineFragments.last {
                let fragmentLocation = layoutManager.offset(from: layoutManager.documentRange.location, to: fragment.rangeInElement.location)
                let absoluteLocation = fragmentLocation + lastLine.characterRange.location
                let lineRange = NSRange(location: absoluteLocation, length: lastLine.characterRange.length)
                let lineString = contentStorage.attributedString!.attributedSubstring(from: lineRange).string
                lastFragmentEndsWithNewline = lineString.hasSuffix("\n")
            }
            
            return true
        }
        
        // Add extra height for trailing newline only if the last fragment doesn't already account for it
        if contentStorage.attributedString!.string.hasSuffix("\n") && lastFragmentEndsWithNewline {
            totalRect.size.height += lastLineHeight
        }
        
        return totalRect
    }
}
