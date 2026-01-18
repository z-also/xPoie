import SwiftUI
import SwiftData

extension Modules.Projects {
    static func filter(
        projs: [UUID: Models.Project],
        of types: [Models.Project.`Type`],
        using search: String,
        catalogs: [UUID: Collection<UUID>]
    ) -> [UUID: Collection<UUID>] {
        let rootId = Consts.uuid
        var result: [UUID: [UUID]] = [:]
        guard let rootChildren = catalogs[rootId]?.data else { return [:] }
        
        var stack: [(UUID, [UUID])] = rootChildren.reversed().map { ($0, [rootId, $0]) }
        
        while let (currId, path) = stack.popLast() {
            guard let curr = projs[currId] else { continue }
            
            if curr.type == .group, let children = catalogs[currId]?.data {
                for child in children.reversed() {
                    stack.append((child, path + [child]))
                }
            } else {
                let typeOk = types.contains(curr.type)
                let titleOk = search.isEmpty || curr.title.lowercased().contains(search)
                
                if typeOk && titleOk {
                    for i in 1..<path.count {
                        let parent = path[i-1]
                        let child = path[i]
                        if !(result[parent]?.contains(child) ?? false) {
                            result[parent, default: []].append(child)
                        }
                    }
                }
            }
        }
        
        return result.mapValues { Collection(data: $0) }
    }
}
