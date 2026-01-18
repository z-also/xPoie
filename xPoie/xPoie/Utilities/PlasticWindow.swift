import SwiftUI

struct FadedMaterialStyle: ShapeStyle {
    let material: Material
    let opacityGradient: LinearGradient
    
    init(material: Material = .ultraThinMaterial,
         opacityGradient: LinearGradient) {
        self.material = material
        self.opacityGradient = opacityGradient
    }
    
    func resolve(in environment: EnvironmentValues) -> some View {
        Color.clear.background(material).mask(opacityGradient)
    }
}

extension ShapeStyle where Self == FadedMaterialStyle {
    static func fadedMaterial(
        material: Material = .ultraThinMaterial,
        opacityGradient: LinearGradient
    ) -> FadedMaterialStyle {
        FadedMaterialStyle(material: material, opacityGradient: opacityGradient)
    }
}

struct PlasticWindow: ViewModifier {
    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        content
            .background(theme.fill.window)
            .containerBackground(.thickMaterial, for: .window)
//            .toolbarBackground(
//                LinearGradient(
//                    stops: [
//                        .init(color: Color.white.opacity(0.6), location: 0),
//                        .init(color: Color.white.opacity(0), location: 1)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                ),
//                for: .windowToolbar
//            )
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    }
}
