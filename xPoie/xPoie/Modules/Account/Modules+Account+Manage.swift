import SwiftUI
import SwiftData

extension Modules.Account {
    func set(signedIn: Bool) {
        self.signedIn = signedIn
        Preferences[.signedIn] = signedIn
    }
}
