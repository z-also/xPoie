import SwiftUI

struct Callout: View {
    var icon: String
    var title: String
    var message: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 12, height: 12)
                .padding(1, 4, 1, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(size: .sm, weight: .medium)
                Text(message).font(size: .sm)
            }
            
            Spacer()
        }
        .padding(8, 6)
        .modifier(OmniStyle.info.static)
    }
}
