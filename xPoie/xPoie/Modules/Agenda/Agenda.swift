import SwiftUI

extension Modules {
    @Observable class Agenda {
        var date = Date()
        
        var today: Collection<UUID> = .init(data: [])
        
        // startAt 或者 endAt 跟当前 date 有重合的
        // 其实也就是今日待办事项
        var tasks: [Models.Task] = []

        init() {
        }

        // task 更新开始时间后者结束时间后，需要判断这个task
        // 更新 tasks
        func onScheduleChanged(task: Models.Task) {
            // 判断任务是否在当前日期内
            let isInDate = self.is(task: task, within: self.date)
            if isInDate {
                // 如果任务在当前日期，更新或添加任务
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    tasks[index] = task
                } else {
                    tasks.append(task)
                }
            } else {
                // 如果任务不在当前日期，移除任务
                tasks.removeAll(where: { $0.id == task.id })
            }
            // 任务列表按开始时间排序
            tasks.sort { ($0.startAt ?? .distantFuture) < ($1.startAt ?? .distantFuture) }
        }
    }
}
