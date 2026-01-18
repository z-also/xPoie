import SwiftUI

struct OmniToggle: View {
    var yes: Bool
    var color: Color
    var size: Size = .small
    var onToggle: (Bool) -> Void
    
    var body: some View {
        let v: CGFloat = size == .large ? 16 : 12
        
        RoundedRectangle(cornerRadius: v / 3)
            .stroke(yes ? Color.clear : color, lineWidth: 1)
            .frame(width: v, height: v)
            .overlay(alignment: .center) {
                if yes {
                    Image(systemName: "checkmark")
                        .resizable()
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(color)
                        .frame(width: v * 0.7, height: v * 0.7)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onToggle(!yes) }
    }
}

