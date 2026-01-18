import SwiftUI

public struct YoRichEditToolbar: View {
    public var onBold: (() -> Void)?
    public var onHeading: (() -> Void)?
    
    public init(onBold: (() -> Void)? = nil, onHeading: (() -> Void)? = nil) {
        self.onBold = onBold
        self.onHeading = onHeading
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            Button(action: { onBold?() }) {
                Image(systemName: "bold")
            }
            .buttonStyle(.borderless)
            
            Button(action: { onHeading?() }) {
                Image(systemName: "textformat.size")
            }
            .buttonStyle(.borderless)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.windowBackgroundColor)))
        .shadow(radius: 4)
    }
}
