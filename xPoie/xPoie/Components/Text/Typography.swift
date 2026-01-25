import AppKit
import SwiftUI

@MainActor
struct Typography {
    var size: Size
    var weight: Font.Weight
    var color: () -> Color
    
    func with(color: Color) -> Typography {
        return with { m in
            m.color = { color }
        }
    }
    
    func with(custom: (inout Typography) -> Void) -> Typography {
        var res = self
        custom(&res)
        return res
    }
    
    var nsFont: NSFont {
        NSFont.systemFont(ofSize: size.rawValue, weight: weight.nsWeight)
    }
}

extension Typography {
    enum Size: CGFloat {
        case huge = 42
        case h1   = 28
        case h2   = 26
        case h3   = 24
        case h4   = 20
        case h5   = 17
        case h6   = 15
        case p    = 13
        case sm   = 12
        case xs   = 11
        case xxs  = 10
    }
}

extension Font.Weight {
    var nsWeight: NSFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}

extension Typography {
    static let h1 = Typography(
        size: .h1,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let h2 = Typography(
        size: .h2,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let h3 = Typography(
        size: .h3,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )

    static let h4 = Typography(
        size: .h4,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let h5 = Typography(
        size: .h5,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let h6 = Typography(
        size: .h6,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )

    static let p = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let primary = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let secondary = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.secondary }
    )
    
    static let accent = Typography(
        size: .p,
        weight: .regular,
        color: { Color.accentColor }
    )
    
    static let quaternary = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.quaternary }
    )

    static let text = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let desc = Typography(
        size: .p,
        weight: .light,
        color: { Modules.vars.theme.text.secondary }
    )

    static let tip = Typography(
        size: .sm,
        weight: .regular,
        color: { Modules.vars.theme.text.secondary }
    )
    
    static let legend = Typography(
        size: .sm,
        weight: .medium,
        color: { Modules.vars.theme.text.secondary }
    )
    
    static let label = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let caption = Typography(
        size: .sm,
        weight: .light,
        color: { Modules.vars.theme.text.secondary }
    )
    
    static let sectionHeader = Typography(
        size: .p,
        weight: .medium,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let body = Typography(
        size: .p,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
    
    static let medium = Typography(
        size: .h4,
        weight: .regular,
        color: { Modules.vars.theme.text.primary }
    )
}


extension Text {
    @MainActor
    func typography(_ config: Typography) -> some View {
        font(.system(size: config.size.rawValue, weight: config.weight))
            .foregroundStyle(config.color())
    }
    
    @MainActor
    func typography(_ config: Typography, size: Typography.Size) -> some View {
        font(.system(size: size.rawValue, weight: config.weight))
            .foregroundStyle(config.color())
    }
    
    @MainActor
    func typography(_ config: Typography, size: Typography.Size? = nil, weight: Font.Weight? = nil) -> some View {
        font(.system(size: (size ?? config.size).rawValue, weight: (weight ?? config.weight)))
            .foregroundStyle(config.color())
    }
    
    func font(size: Typography.Size, weight: Font.Weight? = nil, design: Font.Design? = nil) -> some View {
        font(.system(size: size.rawValue, weight: weight, design: design))
    }
}

extension TextField {
    @MainActor
    func typography(_ config: Typography) -> some View {
        font(.system(size: config.size.rawValue, weight: config.weight))
        .ifLet(config.color) { $0.foregroundStyle($1()) }
    }
}

extension TextEditor {
    @MainActor
    func typography(_ config: Typography) -> some View {
        font(.system(size: config.size.rawValue, weight: config.weight))
        .ifLet(config.color) { $0.foregroundStyle($1()) }
    }
}
