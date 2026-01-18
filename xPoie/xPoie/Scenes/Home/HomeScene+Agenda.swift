import SwiftUI

struct HomeSceneAgenda: View {
    @Environment(\.input) var input
    @Environment(\.theme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Notes")
                .typography(.h5)
            
            Line()
              .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
              .foregroundStyle(theme.text.secondary.opacity(0.6))
              .frame(height: 1)
            
            let field: Field = .content(id: Consts.uuid)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.text.secondary.opacity(0.2), lineWidth: 0.5)
        )
    }
}


struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
