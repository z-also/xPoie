import SwiftUI
import SwiftData

extension Modules.Tasks {
    func createBlock(at: Int, in pid: UUID) -> Models.Task.Block? {
        guard var catalog = projects[pid] else {
            return nil
        }
        
        let prev: Models.Task.Block? = at > 0 ? blocks[catalog.data[at - 1]] : nil
        let next: Models.Task.Block? = at < catalog.data.count ? blocks[catalog.data[at]] : nil
        
        let block = Models.Task.Block(
            title: "haha",
            project: pid,
            rank: prev == nil || next == nil
                ? LexoRank.next(curr: prev?.rank ?? "")
                : LexoRank.between(prev: prev!.rank, next: next!.rank)
        )
        
        if (prev == nil && next !== nil) {
            next!.rank = at >= catalog.data.count - 1
                ? LexoRank.next(curr: block.rank)
                : LexoRank.between(prev: block.rank, next: blocks[catalog.data[at + 1]]!.rank)
        }
        
        upsert(block: block)
        Store.shared.context.insert(block)
        catalog.data.insert(block.id, at: at)
        projects[pid] = catalog
        
        return block
    }
    
    func createTask(at: Int, parent: Models.Task?, block: Models.Task.Block?, project: Models.Project?) -> Models.Task {
        let pid = (parent?.id ?? block?.id ?? project?.id)!
        var catalog = catalogs[pid] ?? .init(data: [])

        let prev: Models.Task? = at > 0 ? tasks[catalog.data[at - 1]] : nil
        let next: Models.Task? = at < catalog.data.count ? tasks[catalog.data[at]] : nil

        let task: Models.Task = .init(
            block: block?.id,
            parent: parent?.id,
            project: block?.project ?? project?.id,
            title: "untitled task",
            rank: prev == nil || next == nil
                ? LexoRank.next(curr: prev?.rank ?? "")
                : LexoRank.between(prev: prev!.rank, next: next!.rank),
            type: .task
        )
        
        if (prev == nil && next !== nil) {
            next!.rank = at >= catalog.data.count - 1
                ? LexoRank.next(curr: task.rank)
                : LexoRank.between(prev: task.rank, next: tasks[catalog.data[at + 1]]!.rank)
        }
        
        upsert(task: task)
        parent?.count += 1
        Store.shared.context.insert(task)
        catalog.data.insert(task.id, at: at)

        withAnimation {
            catalogs[pid] = catalog
            self.lastInsertedTaskId = task.id
        }
        
        return task
    }
    
    func createTask(near: Models.Task, offset: Int) -> Models.Task? {
        guard let pid = near.parent ?? near.block ?? near.project,
              let catalog = catalogs[pid] else {
           return nil
        }
        let index = catalog.data.firstIndex(of: near.id)
        let block = near.block == nil ? nil : blocks[near.block!]
        let parent = near.parent == nil ? nil : tasks[near.parent!]
        let project = near.project == nil ? nil : Modules.projects.projects[near.project!]
        return createTask(at: index! + offset, parent: parent, block: block, project: project)
    }

    func createTask(for block: Models.Task.Block, prev: Models.Task) -> Models.Task? {
        guard let catalog = catalogs[prev.parent ?? block.id] else {
            return nil
        }
        
        guard let index = catalog.data.firstIndex(of: prev.id) else {
            return nil
        }
        
        let pid = prev.parent
        
        return createTask(at: index + 1, parent: pid == nil ? nil : tasks[pid!], block: block, project: nil)
    }
    
    func createTaskAtEnd(catalogId: UUID) -> Models.Task? {
        let block = blocks[catalogId]
        let projid = block == nil ? catalogId : block?.project
        let project = projid == nil ? nil : Modules.projects.projects[projid!]

        guard let catalog = catalogs[catalogId] else {
            return nil
        }
        
        return createTask(at: catalog.data.count, parent: nil, block: block, project: project)
    }

    func createSubTask(in parent: Models.Task) -> Models.Task? {
        let block = parent.block.flatMap { blocks[$0] }
        expandeds[parent.id] = true
        let project = parent.project.flatMap { Modules.projects.projects[$0] }
        return createTask(at: 0, parent: parent, block: block, project: project)
    }
    
    func sub(task: Models.Task) {
        guard let cid = task.parent ?? task.block ?? task.project,
              var catalog = catalogs[cid] else {
            return
        }
        
        guard let index = catalog.data.firstIndex(of: task.id) else {
            return
        }
        
        guard index > 0, let prev = tasks[catalog.data[index - 1]] else {
            return
        }
        
        if let parent = task.parent, let t = tasks[parent] {
            t.count -= 1
        }
        // TODO: -=1
        catalog.data.remove(at: index)
        catalogs[cid] = catalog

        task.parent = prev.id
        if catalogs[prev.id] == nil {
            catalogs[prev.id] = .init(data: [])
        }
        prev.count += 1
        
        var c = catalogs[prev.id]!
        c.data.append(task.id)
        catalogs[prev.id] = c
        expandeds[prev.id] = true
    }
}
