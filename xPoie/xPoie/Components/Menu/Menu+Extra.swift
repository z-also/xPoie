import SwiftUI

struct ExtraMenu<Content: View>: View {
    @ViewBuilder private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        Menu {
            content()
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .frame(width: 15, height: 3)
                .padding(8, 6)
        }
        .menuStyle(.button)
        .buttonStyle(.omni.with(padding: .zero))
    }
}
