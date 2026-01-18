import SwiftUI

struct PickerButtons<T: Hashable & Sendable, V: Sendable>: View {
    let options: [Option<T, V>]
    var selection: T
    let onSelect: ((Option<T, V>) -> Void)?
    
    var body: some View {
        HStack {
            ForEach(options) { option in
                let selected = selection == option.id
                Button(action: { onSelect?(option) }) {
                    HStack {
                        if !option.icon.isEmpty {
                            Image(systemName: option.icon)
                                .resizable()
                                .frame(width: 14, height: 14)
                                .padding(1)
                        }
                        
                        if selected && !option.title.isEmpty {
                            Text(option.title)
                        }
                    }
                    .padding(4, 2)
                    .frame(maxWidth: selected ? .infinity : nil)
                }
                .buttonStyle(.omni.with(visual: .pill, active: selected))
            }
        }
    }
}
