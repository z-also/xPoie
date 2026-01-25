import SwiftUI

extension Modules {
    @Observable class Settings {
        var scene: Scene = .general
        
        var signedIn: Bool = Preferences[.signedIn]
        
        enum Scene {
            case general
            case subscription
            case appearance
            case shortcuts
            case localModels
        }
    }
}
