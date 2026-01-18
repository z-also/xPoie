import SwiftUI

extension Modules.Calendar {
    struct Schedule {
        var dates: [Date] = []
        var tasks: [Models.Task] = []
    }
    
    func set(draft: Modules.Events.Item?) {
//        eventDraft = draft
    }
    
    func schedule(dates: [Date]) -> Schedule {
        var tasks = [Models.Task]()
        do {
            if let start = dates.first, let end = dates.last {
                let end0 = Cal.cal.date(byAdding: .day, value: 1, to: end)
                let result = try Modules.tasks.fetchTasks(
                    filter: .init(when: (start, end0!))
                )
                tasks = result
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return .init(dates: dates, tasks: tasks)
    }
}
