import SwiftUI

extension Modules {
    @Observable class Calendar {
        var date = Date()
        
        var frame: Frame = .week

        var schedule: Schedule = .init()
        
        var selectedSpaces = Preferences[.selectedCalendarSpace]
    }
}
