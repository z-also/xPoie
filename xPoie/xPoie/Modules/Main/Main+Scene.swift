import SwiftUI

extension Modules.Main {
    enum Scene: String {
        case home
        case inbox
        case calendar
        case projects
        case settings
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
