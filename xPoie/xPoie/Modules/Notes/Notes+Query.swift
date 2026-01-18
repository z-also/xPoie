import SwiftUI
import SwiftData

extension Modules.Notes {
    struct Filter {
        var parent: (Bool, UUID?) = (false, nil)
        var sticky: (Bool, Bool) = (false, false)
        var pinned: (Bool, Bool) = (false, false)
    }

    func fetchNotes(descriptor: FetchDescriptor<Models.Note>) throws -> [Models.Note] {
        let result = try Store.shared.context.fetch(descriptor)
        result.forEach { upsert(note: $0) }
        return result
    }
    
    func fetchNotes(filter: Filter) throws -> [Models.Note] {
        let (filterParent, parent) = filter.parent
        let (filterSticky, sticky) = filter.sticky
        let (filterPinned, pinned) = filter.pinned

        let relationPredicate = #Predicate<Models.Note> {
            (filterParent ? $0.parent == parent : true)
        }
        
        let statusPredicate = #Predicate<Models.Note> {
            (filterSticky ? sticky ? $0._sticky != "" : $0._sticky == "" : true)
            && (filterPinned ? pinned ? $0.pinned != "" : $0.pinned == "" : true)
        }

        let descriptor = FetchDescriptor<Models.Note>(
            predicate: #Predicate { note in
                relationPredicate.evaluate(note)
                && statusPredicate.evaluate(note)
            },
            sortBy: [.init(\.rank, comparator: .lexical, order: .forward)]
        )

        return try fetchNotes(descriptor: descriptor)
    }
}
