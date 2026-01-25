import SwiftUI

@MainActor
struct Visual {
    let name: String
    var shape: () -> any Shape
    var miniature: ((Theme) -> any ShapeStyle)?
    var foreground: ((Theme, Bool, Bool) -> any ShapeStyle)?
    var background: ((Theme, Bool, Bool, any Shape) -> any View)?
    var overlay: ((Theme, Bool, Bool, any Shape) -> any View)?
}

extension Visual {
    var capsule: Self {
        var s = self
        s.shape = { Capsule() }
        return s
    }
    
    var circled: Self {
        var s = self
        s.shape = { Circle() }
        return s
    }
    
    func shape(v: any Shape) -> Self {
        var s = self
        s.shape = { v }
        return s
    }
    
    static let none = Self.init(
        name: "none",
        shape: { RoundedRectangle(cornerRadius: 6) }
    )
    
    static let normal = Self.init(
        name: "normal",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.tertiary : Color.clear) }
    )
    
    static let dumpLink = Self.init(
        name: "dumpLink",
        shape: { Rectangle() },
        foreground: { (theme, h, a) in h || a ? theme.text.primary : theme.text.tertiary }
    )

    static let `static` = Self.init(
        name: "normal",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(theme.fill.tertiary.opacity(a || h ? 1 : 0.8)) }
    )

    static let icon = Self.init(
        name: "icon",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? theme.semantic.brand : theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.quinary : Color.clear) }
    )

    static let nav = Self.init(
        name: "nav",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? theme.semantic.brand : theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.quinary : Color.clear) }
    )
    
    static let tab = Self.init(
        name: "tab",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? theme.text.primary : theme.text.tertiary },
        background: { (theme, h, a, s) in s.fill(h ? theme.fill.tertiary : Color.clear) }
    )
    
    static let pill = Self.init(
        name: "pill",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? theme.text.primary : theme.text.tertiary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.secondary : theme.fill.tertiary) }
    )

    static let active = Self.init(
        name: "active",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, _, __) in theme.semantic.brand },
        background: { (_, __, ___, s) in s.fill(Color.black) }
    )
    
    static let inactive: Self = .init(
        name: "inactive",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, f) in theme.text.tertiary },
        background: { (theme, h, f, s) in h ? theme.fill.selected : Color.clear }
    )
    
    static let link: Self = .init(
        name: "link",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, f) in theme.semantic.brand }
    )

    static let primary: Self = .init(
        name: "primary",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, f) in Color.white },
        background: { (theme, h, f, s) in s.fill(theme.fill.active) }
    )

    static let hovered = Self.init(
        name: "hovered",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, f) in theme.text.primary },
        background: { (theme, h, f, s) in s.fill(theme.fill.tertiary)}
    )
    
    static let field = Self.init(
        name: "field",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
//        overlay: { (theme, h, a, s) in s.stroke(a ? theme.semantic.brand : theme.fill.secondary, lineWidth: 1).shadow(color: theme.semantic.brand, radius: 2) }
        overlay: { (theme, h, a, s) in s.stroke(a ? theme.semantic.brand : theme.fill.secondary, lineWidth: 1) }
    )
    
    static let btn = Self.init(
        name: "btn",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in a ? theme.semantic.brand : theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.tertiary : Color.clear) }
    )
    
    static let normalBtn = Self.init(
        name: "normalBtn",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.secondary : Color.clear) }
    )

    static let primaryBtn = Self.init(
        name: "primaryBtn",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? .white : theme.semantic.brand },
        background: { (theme, h, a, s) in s.fill(theme.semantic.brand.opacity(h || a ? 1 : 0.2)) }
    )
    
    static let brand = Self.init(
        name: "brand",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.semantic.brand },
        background: { (theme, h, a, s) in s.fill(theme.semantic.brand.opacity(h || a ? 0.2 : 0.1)) }
    )

    static let cancelBtn = Self.init(
        name: "cancelBtn",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.tertiary : theme.fill.quaternary) },
        overlay: { (theme, h, a, s) in s.stroke(theme.fill.secondary, lineWidth: 1) }
    )
    
    static let ghost = Self.init(
        name: "ghost",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in h || a ? theme.semantic.brand : theme.text.secondary },
        background: { (theme, h, a, s) in s.fill(theme.semantic.brand.opacity(h || a ? 0.2 : 0)) },
        overlay: { (a, b, c, s) in Color.clear }
    )
    
    static let plain = Self.init(
        name: "plain",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in a ? theme.semantic.brand : theme.text.primary }
    )
    
    static let secondary = Self.init(
        name: "secondary",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(theme.fill.secondary.opacity(h || a ? 1 : 0.6)) }
    )
    
    static let info = Self.init(
        name: "info",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.secondary },
        background: { (theme, h, a, s) in s.fill(theme.fill.tertiary) }
    )
    
    static let tag = Self.init(
        name: "tag",
        shape: { Capsule() },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(theme.fill.secondary.opacity(h || a ? 1 : 0)) },
        overlay: { (theme, h, a, s) in s.stroke(theme.fill.secondary, lineWidth: 1) }
    )
    
    static let tab2 = Self.init(
        name: "tab2",
        shape: { Capsule() },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(theme.fill.secondary.opacity(h || a ? 1 : 0)) }
    )
    
    static let fieldWhenActive = Self.init(
        name: "fieldWhenActive",
        shape: { RoundedRectangle(cornerRadius: 6) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(theme.semantic.brand.opacity(a ? 0.08 : h ? 0.02 : 0)) },
//        overlay: { (theme, h, a, s) in s.stroke(theme.semantic.brand.opacity(a ? 1 : h ? 0.6 : 0), lineWidth: 1) }
        overlay: { (theme, h, a, s) in
            let color: Color = a || h ? theme.semantic.brand : theme.text.secondary
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let embedField = Self.init(
        name: "embedField",
        shape: { RoundedRectangle(cornerRadius: 8) },
        foreground: { (theme, h, a) in theme.text.primary },
        overlay: { (theme, h, a, s) in
            let color: Color = a || h ? theme.semantic.brand : theme.text.quaternary
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let carnote = Self.init(
        name: "carnote",
        shape: { RoundedRectangle(cornerRadius: 16) },
        miniature: { theme in
            Color("palette/red")
        },
        background: { (theme, h, a, s) in
            let c = theme.semantic.brand
//            s.fill(LinearGradient(
//                gradient: Gradient(colors: [theme.semantic.brand.opacity(0.6), theme.semantic.brand.opacity(0.2)]),
//                startPoint: .top,
//                endPoint: .bottom
//            ))
            return s.fill(c.opacity(0.6))
        },
        overlay: { (theme, h, a, s) in
            let color: Color = a || h ? theme.fill.primary : theme.fill.tertiary
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let plain2 = Self.init(
        name: "plain2",
        shape: { RoundedRectangle(cornerRadius: 16) },
        miniature: { theme in theme.semantic.plain },
        background: { (theme, h, a, s) in
//            s.fill(theme.semantic.plain.opacity(0.6))
//            s.fill(.thinMaterial)
            s.fill(.white)
        },
        overlay: { (theme, h, a, s) in
//            let color = a || h ? theme.semantic.brand : theme.fill.tertiary
            let color = Color.white
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let carnote2 = Self.init(
        name: "carnote2",
        shape: { RoundedRectangle(cornerRadius: 16) },
        miniature: { theme in
            let c = Color("palette/yellow")
            return LinearGradient(
                gradient: Gradient(colors: [c.opacity(0.6), c.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        },
        background: { (theme, h, a, s) in
            let c = Color("palette/blue")
//            return s.fill(LinearGradient(
//                gradient: Gradient(colors: [c.opacity(0.6), c.opacity(0.2)]),
//                startPoint: .top,
//                endPoint: .bottom
//            ))
            return s.fill(c.opacity(0.6))
        },
        overlay: { (theme, h, a, s) in
            let color: Color = a || h ? theme.fill.primary : theme.fill.tertiary
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let carnote3 = Self.init(
        name: "carnote3",
        shape: { RoundedRectangle(cornerRadius: 16) },
        miniature: { theme in
            Color("palette/dark_green")
        },
        background: { (theme, h, a, s) in
            let c = Color("palette/dark_green")
            return s.fill(Gradient(colors: [c, c.opacity(0.6)]))
        },
        overlay: { (theme, h, a, s) in
            let color: Color = a || h ? theme.fill.primary : theme.fill.tertiary
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let `void` = Self.init(
        name: "void",
        shape: { RoundedRectangle(cornerRadius: 16) },
        miniature: { theme in
            Color("palette/dark_green")
        },
        background: { (theme, h, a, s) in
            let c = a ? theme.semantic.brand.opacity(0.1) : h ? theme.fill.tertiary : Color.clear
            return s.fill(c)
        },
        overlay: { (theme, h, a, s) in
            let color: Color = a ? theme.semantic.brand : Color.clear
            return s.stroke(color.opacity(a ? 1 : h ? 0.6 : 0.8), lineWidth: 1)
        }
    )
    
    static let menuAction = Self.init(
        name: "menuAction",
        shape: { RoundedRectangle(cornerRadius: 12) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { theme, h, a, s in
            let c = a ? theme.fill.secondary : .clear
            return s.fill(c)
        }
    )
    
    static let destructiveMenuAction = Self.init(
        name: "desctructiveMenuAction",
        shape: { RoundedRectangle(cornerRadius: 12) },
        foreground: { (theme, h, a) in theme.text.destructive },
        background: { theme, h, a, s in
            let c = a ? theme.fill.secondary : .clear
            return s.fill(c)
        }
    )
    
    static let bread = Self.init(
        name: "bread",
        shape: { Capsule() },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in
            let color: Color = theme.text.quaternary.opacity(a || h ? 1 : 0.8)
            return s.fill(color)
        }
    )
    
    static let outline = Self.init(
        name: "outline",
        shape: { Capsule() },
        background: { theme, h, a, s in
            let color: Color = theme.fill.tertiary
            return s.fill(color.opacity(a ? 0.8 : h ? 0.6 : 0.4))
        },
        overlay: { theme, h, a, s in
            let color: Color = .white
            return s.stroke(color.opacity(a ? 0.8 : h ? 0.6 : 0.4), lineWidth: 2)
        }
    )
    
    static let solidGreen = Self.init(
        name: "solidGreen",
        shape: { Capsule() },
        foreground: { theme, h, a in
            return Color.white
        },
        background: { theme, h, a, s in
            let color: Color = .green
//            return s.fill(color.opacity(a ? 0.8 : h ? 0.6 : 0.4))
            return s.fill(color)
        },
        overlay: { theme, h, a, s in
            let color: Color = .white
            return s.stroke(color.opacity(a ? 0.8 : h ? 0.6 : 0.4), lineWidth: 2)
        }
    )
    
    static let route = Self.init(
        name: "route",
        shape: { RoundedRectangle(cornerRadius: 10) },
        foreground: { (theme, h, a) in theme.text.primary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.tertiary : Color.clear) }
    )
    
    static let secondaryRoute = Self.init(
        name: "secondaryRoute",
        shape: { RoundedRectangle(cornerRadius: 10) },
        foreground: { (theme, h, a) in theme.text.secondary },
        background: { (theme, h, a, s) in s.fill(h || a ? theme.fill.tertiary : Color.clear) }
    )
}

extension Visual {
    static let presets: [Visual] = [
        .`void`,
        .plain2,
        .carnote,
        .carnote2,
        .carnote3
    ]
    
    static func named(_ name: String) -> Self? {
        return presets.first { $0.name == name }
    }
}
