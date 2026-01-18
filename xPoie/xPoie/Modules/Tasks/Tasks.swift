import SwiftUI
import SwiftData

extension Modules {
    @Observable class Tasks {
        // task data source
        var tasks: [UUID: Models.Task] = [:]
        
        // block data source
        var blocks: [UUID: Models.Task.Block] = [:]
        
        // [block id: a collection of task ids]
        // [task id: a collection of subtask ids]
        // [project id: a collection of task ids, whose block is null]
        var catalogs: [UUID: Collection<UUID>] = [:]
        
        // [project id: a collection of block ids]
        var projects: [UUID: Collection<UUID>] = [:]
        
        // block expandeds [project id: [block id: Bool]]
        var expandeds: [UUID: Bool] = [:]
        
        // 新增：追踪新插入的 task id
        var lastInsertedTaskId: UUID? = nil
    }
}
