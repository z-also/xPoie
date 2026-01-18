import Infy
import SwiftUI

extension Modules {
    @Observable class Pads {
        var pads: [UUID: Models.Pad] = [:]
        // [project id: a collection of note ids]
        var catalogs: [UUID: Collection<UUID>] = [:]
        // inspector
        var inspector: Inspector = .style
        // active note
        var activeNote: Models.Note? = nil
        // show inspector
        var isSidebarHidden = false
        // pinned notes
        var pinnedNotes: [UUID: Collection<UUID>] = [:]
        // generes
        var nodeGenres: [NodeGenre] = []
        
        var intent: Intent = .none
        
        var immersive: Bool = false
        
        var editingNote: Models.Note? = nil
        
        enum Inspector: String {
            case content
            case style
            case action
        }
        
        enum Intent {
            case new
            case none
        }
        
        struct Node: Infy.Node {
            var id: UUID
            var type: Models.Pad.Node.`Type`
            var frame: CGRect
        }
        
        struct NodeGenre {
            var icon: String
            var type: Models.Pad.Node.`Type`
            var title: String
        }
        
        protocol Coordinator {
            @MainActor func present(detail node: Infy.NodeRepresenter<Node>)
        }
    }
}
