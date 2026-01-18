import SwiftUI
import SwiftData

extension Modules.Projects {
    func select(id: UUID) {
        guard let project = projects[id] else {
            return
        }
        
        if id == currentProject?.id {
            if project.type == .group {
                toggle(id: id, expand: !(expandeds[id] ?? false))
            }
            return
        }
        
        scene = .none
        currentProject = project
        
        if project.type == .group {
            toggle(id: id, expand: true)
            load(catalog: project.id)
        }
        
        if project.type == .task {
            Modules.tasks.loadBlocks(projectId: project.id)
            Modules.tasks.loadProjectTasks(projectId: project.id)
            //            result.forEach { loadTasks(parent: nil, block: $0.id, project: $0.project) }
        }
        
        if project.type == .pad {
            Modules.notes.fetchNotes(of: project.id)
            Modules.things.fetchThings(of: project.id)
        }
    }
    
    func upsert(project: Models.Project) {
        projects[project.id] = project

        if project.type == .group {
            if catalogs[project.id] == nil {
                catalogs[project.id] = .init(data: [])
            }
            if expandeds[project.id] == nil {
                expandeds[project.id] = true
            }
        }
        
        // 确保在 Tasks 模块中创建相关的 catalog 和 projects 条目
        if project.type == .task {
            if Modules.tasks.projects[project.id] == nil {
                Modules.tasks.projects[project.id] = .init(data: [])
            }
            if Modules.tasks.catalogs[project.id] == nil {
                Modules.tasks.catalogs[project.id] = .init(data: [])
            }
        }
    }
    
    func load(catalog id: UUID) {
        guard let catalog = catalogs[id] else {
            return
        }
        
        guard catalog.status != .nomore else {
            return
        }
        
        let pid = id == Consts.uuid ? nil : id
        
        let descriptor = FetchDescriptor<Models.Project>(
            predicate: #Predicate<Models.Project> { item in
                item.parentId == pid
            },
            sortBy: [.init(\.rank, comparator: .lexical, order: .forward)]
        )
        
        do {
            let result = try Store.shared.context.fetch(descriptor)
            result.forEach { upsert(project: $0) }
            catalogs[id] = .init(data: result.map { $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func move(by id: UUID, to _id: UUID, edge: Edge) {
        guard id != _id, let proj = projects[id], let to = projects[_id] else {
            return
        }
        
        let cid = to.parentId ?? Consts.uuid
        catalogs[proj.parentId ?? Consts.uuid]?.data.removeAll{ $0 == id }
        
        if edge == .trailing {
            proj.parentId = _id
            proj.rank = LexoRank.next(curr: "")
            catalogs[_id]?.data.append(id)
            return
        }
        
        guard let catalog = catalogs[cid], let index = catalog.data.firstIndex(of: _id) else {
            return
        }
        
        proj.parentId = to.parentId
        
        let prev: Models.Project? = index > 0 ? projects[catalog.data[index - 1]] : nil
        let next: Models.Project? = index < catalog.data.count - 1 ? projects[catalog.data[index + 1]] : nil
        
        if edge == .top {
            if let prev = prev {
                proj.rank = LexoRank.between(prev: prev.rank, next: to.rank)
            } else {
                proj.rank = to.rank
                to.rank = LexoRank.between(prev: to.rank, next: next?.rank ?? "")
            }
            catalogs[cid]?.data.insert(id, at: index)
        } else if edge == .bottom {
            proj.rank = LexoRank.between(prev: to.rank, next: next?.rank ?? "")
            catalogs[cid]?.data.insert(id, at: index + 1)
        }
    }
    
    func delete(project: Models.Project) {
        var projs: [Models.Project] = [project]
        
        let pid = project.parentId ?? Consts.uuid
        
        if currentProject?.id == project.id {
            currentProject = nil
        }

        if var catalog = catalogs[pid] {
            catalog.data = catalog.data.filter { $0 != project.id }
            catalogs[pid] = catalog
        }
        
        var todeletes: [Models.Project] = []

        while !projs.isEmpty {
            let proj = projs.removeFirst()
            todeletes.append(proj)

            guard let catalog = catalogs[proj.id] else {
                continue
            }
            
            catalogs.removeValue(forKey: proj.id)
            projs += catalog.data.map { projects[$0]! }
        }
        
        todeletes.forEach { proj in
            Store.shared.context.delete(proj)
            projects.removeValue(forKey: proj.id)
        }
    }
    
    func toggle(id: UUID, expand: Bool) {
        guard let project = projects[id] else {
            return
        }
        
        if expand != expandeds[id] && project.type == .group {
            withAnimation { expandeds[id] = expand }
        }
    }
}
