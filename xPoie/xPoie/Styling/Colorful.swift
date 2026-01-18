import SwiftUI

@MainActor
struct Colorful {
    let name: String
    var shape: () -> any Shape
    var foreground: ((Theme) -> any ShapeStyle)?
    var background: ((Theme) -> any View)?
    var overlay: ((Theme) -> any View)?
}
