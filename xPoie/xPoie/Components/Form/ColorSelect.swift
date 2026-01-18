import SwiftUI

struct ColorSelect: View {
    var size = 22.0
    var columns: Int = 6
    var value: String
    var options: [Option<String, String>]
    var onSelect: (Option<String, String>) -> Void
    
    private var rows: [[Option<String, String>]] {
        stride(from: 0, to: options.count, by: columns).map { offset in
            let end = min(offset + columns, options.count)
            return Array(options[offset..<end])
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(0..<rows.count, id: \.self) { index in
                let row = rows[index]
                HStack(spacing: 12) {
                    ForEach(row) { option in
                        let color = Color(option.value)
                        let selected = option.value == value
                        let outerSize = selected ? size + 4 : size
                        
                        RoundedRectangle(cornerRadius: size / 2)
                            .fill(color)
                            .frame(width: size, height: size)
                            .scaleEffect(selected ? 0.86 : 1)
                            .if(selected) {
                                $0.overlay(
                                    RoundedRectangle(cornerRadius: outerSize / 2)
                                        .stroke(color.opacity(0.6), lineWidth: 3)
                                        .frame(width: outerSize, height: outerSize)
                                )
                            }
                            .onTapGesture {
                                onSelect(option)
                            }
                    }
                    Spacer()
                }
            }
        }
        .animation(.linear, value: value)
    }
}
