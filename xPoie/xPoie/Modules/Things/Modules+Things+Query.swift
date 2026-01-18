import SwiftUI
import SwiftData

extension Modules.Things {
    struct Filter {
        var parent: (Bool, UUID?) = (false, nil)
    }

    func fetchThings(descriptor: FetchDescriptor<Models.Thing>) throws -> [Models.Thing] {
        let result = try Store.shared.context.fetch(descriptor)
        result.forEach { upsert(thing: $0) }
        return result
    }
    
    func fetchThings(filter: Filter) throws -> [Models.Thing] {
        let (filterParent, parent) = filter.parent

        let relationPredicate = #Predicate<Models.Thing> {
            (filterParent ? $0.parent == parent : true)
        }
        
        let descriptor = FetchDescriptor<Models.Thing>(
            predicate: #Predicate { note in
                relationPredicate.evaluate(note)
            },
            sortBy: []
        )

        return try fetchThings(descriptor: descriptor)
    }
    
    func fetchThings(of pid: UUID) {
        if catalogs[pid] == nil {
            catalogs[pid] = .init(data: [])
        }
        
        guard let catalog = catalogs[pid] else {
            return
        }
        
        guard catalog.status != .nomore else {
            return
        }
        
        do {
            let result = try fetchThings(
                filter: .init(
                    parent: (true, pid),
                )
            )
            catalogs[pid] = .init(data: result.map { $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
