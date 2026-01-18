import SwiftUI

struct ResizeToggle: View {
    let handleChange: (_ translation: CGSize, _ isEnded: Bool) -> Void

    var body: some View {
        Spacer()
            .frame(width: 4)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .onHover { inside in
                if !inside {
                    NSCursor.pop()
                } else {
                    NSCursor.resizeLeftRight.push()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.handleChange(value.translation, false)
                    }
                    .onEnded { value in
                        self.handleChange(value.translation, true)
                    }
            )
            .zIndex(100)
    }
}

