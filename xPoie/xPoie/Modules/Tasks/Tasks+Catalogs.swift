import SwiftUI
import SwiftData

extension Modules.Tasks {
    func upsert(block: Models.Task.Block) {
        blocks[block.id] = block
        if catalogs[block.id] == nil {
            catalogs[block.id] = .init(data: [])
            expandeds[block.id] = true
        }
    }
    
    func upsert(task: Models.Task) {
        tasks[task.id] = task
        if task.count > 0 && catalogs[task.id] == nil {
            catalogs[task.id] = .init(data: [])
        }
    }
    
    func toggle(block: Models.Task.Block) {
        let curr = expandeds[block.id] ?? false
        withAnimation { expandeds[block.id] = !curr }
        expandeds[block.id] = !curr
        if !curr {
            loadTasks(parent: nil, block: block.id, project: block.project)
        }
    }
    
    func toggle(task: Models.Task, expand: Bool) {
        if task.count > 0 && expand != expandeds[task.id] {
            withAnimation { expandeds[task.id] = expand }
        }
    }

    func loadBlocks(projectId id: UUID) {
        if projects[id] == nil {
            projects[id] = .init(data: [])
        }
        
        let catalog = projects[id]!
        
        guard catalog.status != .nomore else {
            return
        }
        
        let descriptor = FetchDescriptor<Models.Task.Block>(
            predicate: #Predicate {
                $0.project == id
            },
            sortBy: [.init(\.rank, comparator: .lexical, order: .forward)]
        )
        
        do {
            let result = try Store.shared.context.fetch(descriptor)
            result.forEach { upsert(block: $0) }
            projects[id] = .init(data: result.map { $0.id })
            result.forEach { loadTasks(parent: nil, block: $0.id, project: $0.project) }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func loadTasks(parent: UUID?, block: UUID?, project: UUID?, depth: Int = 2) {
        let pid = (parent ?? block ?? project)!
        guard let catalog = catalogs[pid] else {
            return
        }
        guard catalog.status != .nomore else {
            return
        }
        do {
            let result = try fetchTasks(
                filter: .init(
                    block: (true, block),
                    parent: (true, parent),
                    project: (true, project)
                )
            )
            catalogs[pid] = .init(data: result.map { $0.id })
            
            if depth > 1 {
                let parents = result.filter{ $0.count > 0 }
                parents.forEach{ loadTasks(parent: $0.id, block: $0.block, project: $0.project, depth: depth - 1)}
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func prepare(inbox: UUID) {
        let block: Models.Task.Block = .init(id: Consts.uuid2)
        upsert(block: block)
        
        loadTasks(parent: nil, block: block.id, project: nil)
    }
    
    func loadProjectTasks(projectId id: UUID) {
        if catalogs[id] == nil {
            catalogs[id] = .init(data: [])
        }
        
        let catalog = catalogs[id]!
        
        guard catalog.status != .nomore else {
            return
        }
        
        do {
            let result = try fetchTasks(
                filter: .init(
                    block: (true, nil), // block is null
                    parent: (true, nil),
                    project: (true, id)
                )
            )
            catalogs[id] = .init(data: result.map { $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
