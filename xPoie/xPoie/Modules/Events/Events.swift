import SwiftUI

extension Modules {
    @Observable class Events {
        var items: [UUID: Item] = [:]
        
        var spaces = Collection<Space>(data: [])
        
        var byspace: [UUID: Collection<UUID>] = [:]
    }
}
