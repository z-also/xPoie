import SwiftUI

extension Modules.Main {
    enum Scene: String {
        case home
        case tasks
        case inbox
        case notes
        case brain
        case calendar
        case analytics
        case projects
        case account
    }
    
    func `switch`(scene: Scene) {
        guard scene != self.scene else {
            return
        }
        if scene == .calendar {
            Modules.calendar.revalidateSchedule()
        }
        withAnimation {
            self.scene = scene
        }
        Preferences[.scene] = scene
    }
}
