import SwiftUI
import SwiftData

extension Modules {
    @Observable class Account {
        var signedIn: Bool = Preferences[.signedIn]
    }
}
