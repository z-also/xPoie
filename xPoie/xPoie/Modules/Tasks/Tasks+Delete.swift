import SwiftUI
import SwiftData

extension Modules.Tasks {
    func delete(task: Models.Task) {
        cancelSchedule(task: task)
        
        if let cid = task.parent ?? task.block ?? task.project,
           var catalog = catalogs[cid] {
            catalog.data = catalog.data.filter { $0 != task.id }
            catalogs[cid] = catalog
        }
        Store.shared.context.delete(task)
        tasks.removeValue(forKey: task.id)
        
        if let pid = task.parent,
           let parent = tasks[pid] {
            parent.count -= 1
            
            if parent.count == 0 {
                catalogs.removeValue(forKey: pid)
            }
        }
    }
}
