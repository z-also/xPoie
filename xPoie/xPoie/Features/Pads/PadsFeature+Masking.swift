import SwiftUI

struct PadEdgeMasking: View {
    var body: some View {
        Color.clear
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(.ultraThickMaterial)
        .mask(
            LinearGradient(
                gradient: Gradient(
                    stops: [
                        .init(color: Color.white.opacity(0.8), location: 0),
                        .init(color: Color.white.opacity(0), location: 1.0)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}
