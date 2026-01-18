import SwiftUI
import SwiftData

extension Modules.Pads {
    func create(id: UUID, layout: Models.Pad.Layout = .list) -> Models.Pad {
        let pad = Models.Pad(id: id, layout: layout)
        upsert(pad: pad)
        Store.shared.context.insert(pad)
        return pad
    }
}
