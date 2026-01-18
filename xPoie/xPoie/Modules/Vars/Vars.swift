import SwiftUI

extension Modules {
    @Observable class Vars {
        // theme synced in Preferences
        var theme = Theme.named(Preferences[.theme]) ?? Theme.plastic
    }
}
