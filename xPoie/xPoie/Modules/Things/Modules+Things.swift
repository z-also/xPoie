import SwiftUI
import SwiftData

extension Modules {
    @Observable class Things {
        var things: [UUID: Models.Thing] = [:]
        var catalogs: [UUID: Collection<UUID>] = [:]
    }
}
