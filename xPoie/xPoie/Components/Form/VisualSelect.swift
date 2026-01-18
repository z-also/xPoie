import SwiftUI

struct VisualSelect: View {
    var size = 22.0
    var columns: Int = 6
    var value: String
    var options: [Option<String, Visual>]
    var onSelect: (Option<String, Visual>) -> Void
    
    @Environment(\.theme) var theme
    
    private var rows: [[Option<String, Visual>]] {
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
                        let color = AnyShapeStyle(option.value.miniature!(theme))
                        let selected = option.id == value
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
