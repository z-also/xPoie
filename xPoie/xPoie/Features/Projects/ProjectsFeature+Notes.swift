import SwiftUI

struct ProjectsFeatureNotes: View {
    let notes: AttributedString
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Text(notes)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            
            Spacer()
            
//            Line()
//              .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 6]))
//              .foregroundStyle(theme.text.quaternary.opacity(0.6))
//              .frame(height: 1)
//              .padding(0, 12, 0, 28)
        }
    }
}
