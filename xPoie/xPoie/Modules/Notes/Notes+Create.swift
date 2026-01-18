import SwiftUI
import SwiftData

extension Modules.Notes {
    func createNote(at: Int, in pid: UUID, frame: CGRect? = nil) -> Models.Note? {
        guard var catalog = catalogs[pid] else {
            return nil
        }
        
        let prev: Models.Note? = at > 0 ? notes[catalog.data[at - 1]] : nil
        let next: Models.Note? = at < catalog.data.count ? notes[catalog.data[at]] : nil
        
        let note = Models.Note(
            parent: pid,
            title: "",
            rank: prev == nil || next == nil
                ? LexoRank.next(curr: prev?.rank ?? "")
                : LexoRank.between(prev: prev!.rank, next: next!.rank),
            content: AttributedString("")
        )
        
        if (prev == nil && next !== nil) {
            next!.rank = at >= catalog.data.count - 1
                ? LexoRank.next(curr: note.rank)
                : LexoRank.between(prev: note.rank, next: notes[catalog.data[at + 1]]!.rank)
        }
        
        upsert(note: note)
        Store.shared.context.insert(note)
        catalog.data.insert(note.id, at: at)
        catalogs[pid] = catalog
        
        return note
    }
}
