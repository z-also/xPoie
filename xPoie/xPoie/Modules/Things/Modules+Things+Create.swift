import SwiftUI
import SwiftData

extension Modules.Things {
    func createThing(in pid: UUID, frame: CGRect? = nil) -> Models.Thing? {
        guard var catalog = catalogs[pid] else {
            return nil
        }
        
        let thing = Models.Thing(
            type: .media,
            parent: pid,
        )
        
        upsert(thing: thing)
        Store.shared.context.insert(thing)
        catalog.data.append(thing.id)
        catalogs[pid] = catalog
        
        return thing
    }
}


