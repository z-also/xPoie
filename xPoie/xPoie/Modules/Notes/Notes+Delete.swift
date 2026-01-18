import SwiftUI
import SwiftData

extension Modules.Notes {
    func delete(note: Models.Note) {
        guard let pid = note.parent else {
            return
        }
        
        // Remove from regular catalog
        if var catalog = catalogs[pid] {
            catalog.data = catalog.data.filter { $0 != note.id }
            catalogs[pid] = catalog
        }
        
        // Remove from sticky notes if it exists
        sticky = .init(data: sticky.data.filter{ $0 != note.id })
        
        // Remove from pinned notes catalog if it exists
        pinneds = .init(data: pinneds.data.filter{ $0 != note.id })
        
        // TODO: remove from projects.pinnedNotes

        // Remove from local cache
        notes.removeValue(forKey: note.id)

        // Delete from SwiftData context
        Store.shared.context.delete(note)
    }
}
