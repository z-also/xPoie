import SwiftUI

extension Modules.Glim {
    func present(_ at: Presentation) {
        withAnimation(.interpolatingSpring(stiffness: 250, damping: 25)) {
            presentation = at
        }
    }
    
    func set(sugs: [Sug]) {
        withAnimation { self.sugs = sugs }
    }
}
