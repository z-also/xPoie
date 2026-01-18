import SwiftUI
import SwiftData

extension Modules {
    @Observable class Glim {
        var sugs: [Sug] = []
        
        var presentation: Presentation = .none
        
        struct Sug {
            var icon: String
            var title: String
        }
        
        enum Presentation {
            case none
            case inapp
            case spotlight
        }
    }
}
