import SwiftUI
import SwiftData

extension Modules.Things {
    func upsert(thing: Models.Thing) {
        things[thing.id] = thing
    }
}
