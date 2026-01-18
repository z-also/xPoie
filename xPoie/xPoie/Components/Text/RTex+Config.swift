import AppKit
import RTex
import SwiftUI

class RTexc: RTex.Config {
    var attributes: [RTex.FormatType: [NSAttributedString.Key: Any]] = [:]
    var typingAttributes: [NSAttributedString.Key: Any] = [:]
    
    var typography: Typography
    var paragraphStyle: NSMutableParagraphStyle
    
    @MainActor init(typography: Typography) {
        self.typography = typography
        
        self.paragraphStyle = {
            let font = typography.nsFont
            let style = NSMutableParagraphStyle()

            style.lineSpacing = 0
            style.alignment = .justified
//            style.lineHeightMultiple = lineHeightMultiple
            
//            let desiredLineHeight = font.defaultLineHeight * lineHeightMultiple
//            style.minimumLineHeight = desiredLineHeight
//            style.maximumLineHeight = desiredLineHeight
            
            return style
        }()
        
        self.revalidate(theme: Modules.vars.theme)
    }
    
    @MainActor func revalidate(theme: Theme) {
        let foregroundColor = NSColor(typography.color())

        self.typingAttributes = [
            .font: typography.nsFont,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle,
        ]
        
        self.attributes = [
            .body: [
                .font: typography.nsFont,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: foregroundColor,
            ]
        ]
    }
    
    func calcBaselineOffset(font: NSFont, lineHeightMultiple: CGFloat) -> CGFloat {
        return font.defaultLineHeight * (lineHeightMultiple - 1) / 2
    }
}

class RTexcOmni: RTexc {
    override func revalidate(theme: Theme) {
        let foregroundColor = NSColor(typography.color())
        super.revalidate(theme: theme)
        
        self.attributes = [
            .bold: [
                .font: NSFont.boldSystemFont(ofSize: 16),
                .foregroundColor: NSColor(theme.text.primary)
            ],
            .italic: [
                .font: NSFontManager.shared.convert(NSFont.systemFont(ofSize: 16), toHaveTrait: .italicFontMask),
                .foregroundColor: NSColor(theme.text.primary)
            ],
            .heading(1): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 23, weight: .medium)
            ],
            .heading(2): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 20, weight: .medium)
            ],
            .heading(3): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 18, weight: .medium)
            ],
            .heading(4): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 16, weight: .medium)
            ],
            .heading(5): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 15, weight: .medium)
            ],
            .heading(6): [
                .foregroundColor: NSColor(theme.text.primary),
                .paragraphStyle: paragraphStyle,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ],
            .blockquote: [
                .foregroundColor: NSColor(theme.text.secondary),
                .font: NSFont.systemFont(ofSize: 13, weight: .light),
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineHeightMultiple = 1.3
                    style.lineSpacing = 0
                    style.alignment = .justified
                    style.paragraphSpacing = 8
                    style.paragraphSpacingBefore = 8
                    return style
                }(),
                NSAttributedString.Key("QuoteBorder"): NSColor.red
            ],
            .ul: [
                .foregroundColor: NSColor(theme.text.primary),
                .font: typography.nsFont,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    // 使用自定义布局片段提供的 leadingPadding 控制左侧圆点空间，不再使用段落缩进
                    style.paragraphSpacing = 4
                    return style
                }(),
                // 提供圆点颜色（若未设置则回退到 foregroundColor）
                NSAttributedString.Key("ListMarkerColor"): NSColor(theme.text.primary)
            ],
            .body: [
                .font: typography.nsFont,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: foregroundColor,
            ]
        ]
    }
}

struct RTex_Placeholder: View {
    let string: String
    let typography: Typography
    
    var body: some View {
        HStack {
            Text(string)
                .typography(typography)
                .opacity(0.6)
            Spacer()
        }
//        .background(.red)
    }
}
