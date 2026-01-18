import SwiftUI
import SwiftData

extension Modules {
    @Observable class Notes {
        // task data source
        var notes: [UUID: Models.Note] = [:]
        // [project id: a collection of note ids]
        var catalogs: [UUID: Collection<UUID>] = [:]
        // ids of pinned notes
        var sticky: Collection<UUID> = .init(data: [])
        // [project id: collection of pinned notes]
        var pinneds: Collection<UUID> = .init(data: [])
    }
}
