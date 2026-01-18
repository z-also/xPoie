import AppKit

class UnorderedListLayoutFragment: NSTextLayoutFragment {
    override var topMargin: CGFloat { 4 }
    override var bottomMargin: CGFloat { 4 }
    
    // 根据段落的 textLists 层级动态缩进
    private var baseLeadingPadding: CGFloat { 24 }
    private var indentPerLevel: CGFloat { 16 }
    private var levelFromParagraphStyle: Int {
        guard let paragraph = textElement as? NSTextParagraph,
              paragraph.attributedString.length > 0,
              let style = paragraph.attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        else { return 1 }
        // 顶级列表为 1，嵌套层级递增
        return max(1, style.textLists.count)
    }
    override var leadingPadding: CGFloat { baseLeadingPadding + CGFloat(levelFromParagraphStyle - 1) * indentPerLevel }
    
    private var markerColor: NSColor {
        if let paragraph = textElement as? NSTextParagraph,
           paragraph.attributedString.length > 0 {
            // 优先使用自定义颜色键，其次退回 foregroundColor
            if let color = paragraph.attributedString.attribute(NSAttributedString.Key("ListMarkerColor"), at: 0, effectiveRange: nil) as? NSColor {
                return color
            }
            if let color = paragraph.attributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor {
                return color
            }
        }
        return .labelColor
    }
    
    private var markerSize: CGSize { CGSize(width: 6, height: 6) }
    private var markerOffsetX: CGFloat { 10 } // 圆点距离段落左边缘的偏移
    
    override var textLineFragments: [NSTextLineFragment] {
        super.textLineFragments.filter { $0.characterRange.length > 0 }
    }
    
    private var markerRect: CGRect {
        guard let firstLine = textLineFragments.first else {
            return CGRect(x: -leadingPadding + markerOffsetX, y: 0, width: markerSize.width, height: markerSize.height)
        }
        let midY = firstLine.typographicBounds.midY
        return CGRect(
            x: -leadingPadding + markerOffsetX,
            y: midY - markerSize.height / 2,
            width: markerSize.width,
            height: markerSize.height
        )
    }
    
    override var renderingSurfaceBounds: CGRect {
        markerRect.union(super.renderingSurfaceBounds)
    }
    
    override func draw(at renderingOrigin: CGPoint, in ctx: CGContext) {
        drawMarker(at: renderingOrigin, in: ctx)
        super.draw(at: renderingOrigin, in: ctx)
    }
    
    private func drawMarker(at renderingOrigin: CGPoint, in ctx: CGContext) {
        let rect = markerRect
        let path = CGMutablePath()
        path.addEllipse(in: rect)
        
        ctx.saveGState()
        ctx.setFillColor(markerColor.cgColor)
        ctx.addPath(path)
        ctx.fillPath()
        ctx.restoreGState()
    }
}