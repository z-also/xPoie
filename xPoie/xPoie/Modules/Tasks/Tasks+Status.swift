import SwiftUI
import SwiftData

extension Modules.Tasks {
    func stats(task: Models.Task) -> (dones: Int, total: Int, percent: CGFloat) {
        guard let catalog = catalogs[task.id] else {
            return (0, 0, 0)
        }
        
        let subs = catalog.data.compactMap{ tasks[$0] }
        let dones = subs.filter{ $0.status == .done }
        let percent = CGFloat(dones.count / max(subs.count, 1))
        return (dones: dones.count, total: subs.count, percent: percent)
    }
    
    func toggle(task: Models.Task, done: Bool) {
        task.status = done ? .done : .none
        
        guard done else { return }
        
        if let pid = task.parent,
           let parent = tasks[pid] {
            let stats = stats(task: parent)
            if stats.percent >= 1 && parent.status != .done {
                parent.status = .done
            }
        }
        
        if let catalog = catalogs[task.id] {
            let children = catalog.data.compactMap{ tasks[$0] }
            children.forEach{ $0.status = .done }
        }
    }
}
