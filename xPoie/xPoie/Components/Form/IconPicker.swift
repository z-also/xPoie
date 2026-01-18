import SwiftUI

struct IconPicker: View {
    var icon: String
    var color: String
    var size: CGFloat = 12
    var action: (String, String) -> Void

    @State private var active = false
    
    var body: some View {
        Button(action: toggle) {
            Image(systemName: icon)
                .resizable()
                .foregroundStyle(Color(color))
                .frame(width: size, height: size)
        }
        .buttonStyle(.icon)
        .popover(isPresented: $active) {
            PickerContent(icon: icon, color: color, action: action)
        }
    }
    
    private func toggle() {
        active.toggle()
    }
}

fileprivate struct PickerContent: View {
    var icon: String
    var color: String
    var action: (String, String) -> Void
    
    var icons = Consts.icons.chunked(into: 8)
    
    @Environment(\.vars) var vars

    var body: some View {
        VStack(alignment: .leading) {
            ColorSelect(value: color, options: Consts.colors) { action(icon, $0.value) }
            
            Divider().frame(height: 0.5)
            
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                ForEach(0..<icons.count) { index in
                    GridRow {
                        ForEach(icons[index]) { i in
                            Image(systemName: i.value)
                                .resizable()
                                .frame(width: 14, height: 14)
                                .padding(8)
                                .fontWeight(.bold)
                                .foregroundColor(i.value == icon ? Color.white : vars.theme.text.primary)
                                .background(RoundedRectangle(cornerRadius: 6).fill(i.value == icon ? Color(color) : Color.clear))
                                .contentShape(Rectangle())
                                .onTapGesture { action(i.value, color) }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(vars.theme.fill.popover.padding(-80))
    }
}
