import SwiftUI

struct FlatSlider: View {
    var percent: CGFloat
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .glassEffect()
            Capsule().fill(.blue)
                .containerRelativeFrame(.horizontal, alignment: .leading) { length, axis in
                    axis == .horizontal ? length * percent : length
                }
        }
    }
}
