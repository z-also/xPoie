import SwiftUI
import SwiftData

extension Modules.Projects {
    func create(metas: Models.Project.Metas, at: Int, in parent: Models.Project?) -> Models.Project? {
        var pid = Consts.uuid
        
        if let parent = parent {
            pid = parent.id
            toggle(id: parent.id, expand: true)
        }
        
        guard var catalog = catalogs[pid] else {
            return nil
        }

        let prev: Models.Project? = at > 0 ? projects[catalog.data[at - 1]] : nil
        let next: Models.Project? = at < catalog.data.count ? projects[catalog.data[at]] : nil
        
        let project: Models.Project = .init(
            id: UUID(),
            metas: metas,
            rank: prev == nil || next == nil
                ? LexoRank.next(curr: prev?.rank ?? "")
                : LexoRank.between(prev: prev!.rank, next: next!.rank),
            parentId: parent?.id
        )

        if (prev == nil && next !== nil) {
            next!.rank = at >= catalog.data.count - 1
                ? LexoRank.next(curr: project.rank)
                : LexoRank.between(prev: project.rank, next: projects[catalog.data[at + 1]]!.rank)
        }
        
        upsert(project: project)
        Store.shared.context.insert(project)
        catalog.data.insert(project.id, at: at)
        catalogs[pid] = catalog
        
        select(id: project.id)

        if metas.type == .pad {
            _ = Modules.pads.create(id: project.id)
        }

        return project
    }
    
    static func initialMetas(for type: Models.Project.`Type`) -> Models.Project.Metas {
        var metas = Models.Project.Metas(type: type)
        metas.icon = "note.text"
        metas.color = "palette/blue"
        return metas
    }
}
