import Foundation

extension Modules.Tasks {
    func schedule(task: Models.Task, startAt when: Date?) async {
        await schedule(identifier: "task_start_\(task.id.uuidString)",
                       old: task.startAt,
                       new: when,
                       title: "Task Start",
                       body: task.title)
        task.startAt = when
    }
    
    func schedule(task: Models.Task, endAt when: Date?) async {
        await schedule(identifier: "task_end_\(task.id.uuidString)",
                       old: task.endAt,
                       new: when,
                       title: "Task Due",
                       body: task.title)
        task.endAt = when
    }
    
    func cancelSchedule(task: Models.Task) {
        if let when = task.startAt, when > Date.now {
            Notifications.cancel(withIdentifiers: ["task_start_\(task.id.uuidString)"])
        }
        
        if let when = task.endAt, when > Date.now {
            Notifications.cancel(withIdentifiers: ["task_end_\(task.id.uuidString)"])
        }
    }

    private func schedule(identifier: String, old: Date?, new when: Date?, title: String, body: String) async {
        guard old != when else {
            return
        }
        
        if let oldWhen = old, oldWhen > Date.now {
            Notifications.cancel(withIdentifiers: [identifier])
        }

        if let when = when, when > Date.now {
            do {
                try await Notifications.schedule(when: when,
                                                 title: title,
                                                 body: body,
                                                 identifier: identifier)
            } catch {
                
            }
        }
    }
}
