import SwiftUI

extension Modules.Settings {
    func `switch`(scene: Scene) {
        withAnimation { self.scene = scene }
    }
}
