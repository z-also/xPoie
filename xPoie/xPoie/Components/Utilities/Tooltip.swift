import SwiftUI

extension View {
    func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
        self.overlay(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        action(geometry.size)
                    }
                    .onChange(of: geometry.size) { old, newSize in
                        action(newSize)
                    }
            }
        )
    }
    
    func tooltip(_ text: String) -> TooltipContainer<Self> {
        TooltipContainer(content: self, text: text)
    }
}

struct TooltipContainer<Content: View>: View {
    let content: Content
    let text: String
    var options: Options
    @State private var size: CGSize = .zero
    @State var isShowing: Bool = false
    @Environment(\.theme) private var theme
    
    public enum Placement {
        case topLeft
        case topRight
        case topCenter
        case bottomLeft
        case bottomRight
        case bottomCenter
        case leading
    }
    
    public struct Options {
        var position: Placement = .leading
        var zIndex: Double = 1
        var spacing: CGFloat = 6
    }

    public init(content: Content, text: String) {
        self.content = content
        self.text = text
        self.options = Options()
    }
    
    public var body: some View {
        content
            .onHover { isShowing = $0 }
            .overlay(alignment: alignment) {
                Group {
                    if isShowing {
                        GeometryReader { geometry in
                            VStack(alignment: .leading) {
                                Text(text)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(theme.text.secondary)
                                    .font(.system(size: 12, weight: .regular))
                                    .padding(8)
                                    .glassEffect(.regular, in: .rect(cornerRadius: 12))
                                    .frame(maxWidth: 260)
                            }
                            .fixedSize()
                            .measureSize { size = $0 }
                            .position(getToolTipPosition(geometry))
                        }
                    }
                }
            }
            .zIndex(options.zIndex)
    }
    
    private var alignment: Alignment {
        switch options.position {
        case .topLeft:
                .bottom
        case .topRight:
                .bottom
        case .topCenter:
                .bottom
        case .bottomLeft:
                .bottom
        case .bottomRight:
                .bottom
        case .bottomCenter:
                .bottom
        case .leading:
                .leading
        }
    }
    
    private func getToolTipPosition(_ geometry: GeometryProxy) -> CGPoint {
        let viewWidth = geometry.size.width
        let viewHeight = geometry.size.height
        
        let vsize = geometry.size

        switch options.position {
        case .leading:
            return CGPoint(x: -size.width / 2 - options.spacing, y: vsize.height / 2)
            
            
            
        case .bottomLeft:
            return CGPoint(x: size.width / 2, y: -size.height / 2 - 5)
        case .bottomRight:
            return CGPoint(x: viewWidth - size.width / 2, y: -size.height / 2 - 5)
        case .bottomCenter:
            return CGPoint(x: viewWidth / 2, y: -size.height / 2 - 5)
        case .topLeft:
            return CGPoint(x: size.width / 2, y: viewHeight + size.height / 2 + 5)
        case .topRight:
            return CGPoint(x: viewWidth - size.width / 2, y: viewHeight + size.height / 2 + 5)
        case .topCenter:
            return CGPoint(x: viewWidth / 2, y: viewHeight + size.height / 2 + 5)
        }
    }
}
