import SwiftUI
import SwiftData

extension Modules.Pads {
    func upsert(pad: Models.Pad) {
        pads[pad.id] = pad
    }
    
    func load() {
        let descriptor = FetchDescriptor<Models.Pad>(
            predicate: #Predicate<Models.Pad> { item in
                true
            },
            sortBy: []
        )
        
        do {
            let result = try Store.shared.context.fetch(descriptor)
            result.forEach { upsert(pad: $0) }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
