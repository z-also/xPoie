import AppKit

class BlockQuoteLayoutFragment: NSTextLayoutFragment {
    override var topMargin: CGFloat { 2 }
    override var bottomMargin: CGFloat { 2 }
    
    override var leadingPadding: CGFloat {
        let spacing: CGFloat = 20
        return borderWidth + spacing
    }
    
    private var borderWidth: CGFloat { return 2 }
    private var borderColor: NSColor {
        if let textElement = textElement as? NSTextParagraph,
           textElement.attributedString.length > 0,
           let color = textElement.attributedString.attribute(
               NSAttributedString.Key("QuoteBorder"), 
               at: 0, 
               effectiveRange: nil
           ) as? NSColor {
            return color
        }
        return .systemBlue  // Default fallback
    }
    
    // Border rectangle in fragment coordinate space
    private var borderRect: CGRect {
        let fragmentBounds = layoutFragmentFrame
        return CGRect(
            x: -leadingPadding + 4,  // Move border to absolute left by offsetting by leadingPadding
            y: 0,  // Top of fragment
            width: borderWidth,
            height: fragmentBounds.height
        )
    }
    
    override var renderingSurfaceBounds: CGRect {
        return borderRect.union(super.renderingSurfaceBounds)
    }
    
    override func draw(at renderingOrigin: CGPoint, in ctx: CGContext) {
        drawBorder(at: renderingOrigin, in: ctx)
        super.draw(at: renderingOrigin, in: ctx)
    }
    
    private func drawBorder(at renderingOrigin: CGPoint, in ctx: CGContext) {
        let cornerRadius: CGFloat = 0.0  // Subtle rounded corners

        let path = CGMutablePath()
        path.addRoundedRect(in: borderRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        
        ctx.saveGState()
        ctx.setFillColor(borderColor.cgColor)
        ctx.addPath(path)
        ctx.fillPath()
        ctx.restoreGState()
    }
}
