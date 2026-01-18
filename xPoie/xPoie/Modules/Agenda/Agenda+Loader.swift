import SwiftUI

extension Modules.Agenda {
    func view(date: Date, span: Int = 1) {
        do {
            let start = Cal.cal.startOfDay(for: date)
            let end = Cal.cal.date(byAdding: .day, value: span, to: start)!
            let result = try Modules.tasks.fetchTasks(
                filter: .init(when: (start, end))
            )
            self.date = date
            self.tasks = result.sorted { (a, b) in
                (a.startAt ?? .distantFuture) < (b.startAt ?? .distantFuture)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func `is`(task: Models.Task, within date: Date) -> Bool {
        guard let startAt = task.startAt,
              let endAt = task.endAt else { return false }

        let calendar = Cal.cal
        let startDate = calendar.startOfDay(for: startAt)
        let endDate = calendar.startOfDay(for: endAt)
        let targetDate = calendar.startOfDay(for: date)
        return startDate <= targetDate && endDate >= targetDate
    }
}
