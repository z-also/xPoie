import SwiftUI

struct OmniStyle: ViewModifier {
    var size: Size?
    var visual: Visual
    var padding: Padding = .sm
    var active: Bool = false
    var hoverable: Bool = true
    
    @State var hovered = false
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        let shape = visual.shape()
        content
            .padding(padding.value)
            .ifLet(size?.min) { $0.frame(minWidth: $1.width, minHeight: $1.height) }
            .ifLet(visual.foreground) { $0.foregroundStyle(AnyShapeStyle($1(theme, hovered, active))) }
            .ifLet(visual.background) { $0.background(AnyView($1(theme, hovered, active, shape))) }
            .ifLet(visual.overlay) { $0.overlay(AnyView($1(theme, hovered, active, shape))) }
            .if(hoverable) {
                $0.onHover { active in
                    withAnimation { hovered = active }
                }
            }
    }
}

extension OmniStyle {
    struct Padding {
        var value: [CGFloat]
    }
    
    struct Size {
        var min: (width: CGFloat, height: CGFloat)?
    }
}

extension OmniStyle {
    var `static`: Self {
        with { $0.hoverable = false }
    }

    func with(custom: (inout Self) -> Void) -> Self {
        var res = self
        custom(&res)
        return res
    }
    func with(size: Size? = nil, visual: Visual? = nil, padding: Padding? = nil, active: Bool? = nil) -> Self {
        var res = self
        res.size = size ?? res.size
        res.visual = visual ?? res.visual
        res.active = active ?? res.active
        res.padding = padding ?? res.padding
        return res
    }
}

extension OmniStyle.Padding {
    static let slim: Self = .init(value: [6, 12])
    
    static let zero: Self = .init(value: [0])
    static let xxs: Self = .init(value: [2])
    static let xs: Self = .init(value: [3])
    static let sm: Self = .init(value: [4, 6])
    static let md: Self = .init(value: [6, 8])
    static let lg: Self = .init(value: [8, 12])
    static let xl: Self = .init(value: [12, 16])
    
    static let icon: Self = .init(value: [6])
    static let nav: Self = .init(value: [7, 10])
    static let btn: Self = .init(value: [4])
    static let button: Self = .init(value: [4, 8])
    static let input: Self = .init(value: [6, 12])
}

extension OmniStyle.Size {
    // 标准尺寸
    static let xs: Self = .init(min: (22, 22))
    static let btn: Self = .init(min: (22, 22))
}

extension OmniStyle {
    static let btn: Self = .init(visual: .btn, padding: .sm)
    static let omni: Self = .init(visual: .normal, padding: .sm)
    static let normal: Self = .init(size: .xs, visual: .normal, padding: .sm)
    static let hovered: Self = .init(size: .xs, visual: .hovered, padding: .sm)
    static let secondary: Self = .init(visual: .secondary, padding: .sm)
    static let info: Self = .init(visual: .info, padding: .sm)
    static let tag: Self = .init(visual: .info, padding: .sm)
}
