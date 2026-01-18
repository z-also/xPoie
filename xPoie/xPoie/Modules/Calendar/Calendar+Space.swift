import SwiftUI

extension Modules.Calendar {
    func toggle(space: Modules.Events.Space) {
        if selectedSpaces.contains(space.id) {
            selectedSpaces.remove(space.id)
        } else {
            selectedSpaces.insert(space.id)
            Modules.events.load(by: space)
        }
        Preferences[.selectedCalendarSpace] = selectedSpaces
    }
}
