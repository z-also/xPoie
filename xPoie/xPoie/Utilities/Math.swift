import Foundation

func clamp(_ value: CGFloat, min intMin: CGFloat, max intMax: CGFloat) -> CGFloat {
    return min(intMax, max(intMin, value))
}
