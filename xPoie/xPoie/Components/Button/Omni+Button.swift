import SwiftUI

struct OmniButtonStyle: ButtonStyle {
    var style: OmniStyle
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label.lineLimit(1)
        }
            .modifier(style)
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
    
    func with(size: OmniStyle.Size? = nil, visual: Visual? = nil, padding: OmniStyle.Padding? = nil, active: Bool? = nil) -> Self {
        var res = self
        res.style = res.style.with(size: size, visual: visual, padding: padding, active: active)
        return res
    }
}

extension ButtonStyle where Self == OmniButtonStyle {
    static var omni: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
    
    static var icon: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
    
    static var ghost: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
    
    static var brand: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
    
    static var primary: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
    
    static var primarySm: OmniButtonStyle {
        return OmniButtonStyle(style: .omni)
    }
}
