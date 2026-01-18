import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func `ifLet`<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func padding(_ p: [CGFloat]) -> some View {
        let t = p.count > 0 ? p[0] : 0
        let r = p.count > 1 ? p[1] : t
        padding(t, r, p.count > 2 ? p[2] : t, p.count > 3 ? p[3] : r)
    }
    
    @ViewBuilder
    func padding(_ v: CGFloat, _ h: CGFloat) -> some View {
        padding(v, h, v, h)
    }

    @ViewBuilder
    func padding(_ t: CGFloat, _ r: CGFloat?, _ b: CGFloat?, _ l: CGFloat?) -> some View {
        padding(.top, t).padding(.trailing, r ?? t).padding(.bottom, b ?? t).padding(.leading, l ?? r ?? t)
    }
}

struct ExpandTransition: ViewModifier {
    let isExpanded: Bool

    func body(content: Content) -> some View {
        content
            .frame(height: isExpanded ? nil : 0)
            .clipped()
            .opacity(isExpanded ? 1 : 0)
    }
}

extension AnyTransition {
    static var expand: AnyTransition {
        .modifier(
            active: ExpandTransition(isExpanded: false),
            identity: ExpandTransition(isExpanded: true)
        )
    }
}

