import SwiftUI

struct SettingsInterfaceThemeCard: View {
    var image: String
    
    var title: String
    
    var selected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Image(image)
                    .resizable()
                    .frame(width: 80, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .circular)
                            .strokeBorder(selected ? Color.green : Color.clear, lineWidth: 1)
                    )
                
                if (selected) {
                    Image(systemName: "checkmark")
                        .frame(width: 12, height: 12)
                        .foregroundColor(selected ? Color.green : Color.black)
                }
            }

            HStack {
                Text(title)
                    .typography(.h4.with(color: selected ? Color.green : Color.black))
            }
        }
    }
}
