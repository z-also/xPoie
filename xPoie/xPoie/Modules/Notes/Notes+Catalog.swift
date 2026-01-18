import SwiftUI
import SwiftData

extension Modules.Notes {
    func upsert(note: Models.Note) {
        notes[note.id] = note
    }
    
    func fetchNotes(of pid: UUID) {
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
            let result = try fetchNotes(
                filter: .init(
                    parent: (true, pid),
                    pinned: (true, false)
                )
            )
            catalogs[pid] = .init(data: result.map { $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchPinneds(filter: Filter = .init(pinned: (true, true))) {
        guard pinneds.status != .nomore else {
            return
        }
        
        do {
            let result = try fetchNotes(filter: filter)
            result.forEach{ upsert(note: $0) }
            pinneds = .init(data: result.map{ $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchStickyNotes() {
        do {
            let result = try fetchNotes(
                filter: .init(
                    sticky: (true, true)
                )
            )
            result.forEach{ upsert(note: $0) }
            sticky = .init(data: result.map{ $0.id })
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
