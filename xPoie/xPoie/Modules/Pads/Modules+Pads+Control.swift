import AppKit
import SwiftUI
import SwiftData

extension Modules.Pads {
    func `switch`(inspector: Inspector) {
        self.inspector = inspector
    }
    
    func active(note: Models.Note?) {
        self.activeNote = note
    }
    
    func toggleSidebar(hidden: Bool) {
        withAnimation {
            self.isSidebarHidden = hidden
        }
    }
    
    func toggle(immersive: Bool) {
        withAnimation { self.immersive = immersive }
    }
    
    func set(editingNote: Models.Note?) {
        self.editingNote = editingNote
    }
    
    func set(nodeGenres: [NodeGenre]) {
        self.nodeGenres = nodeGenres
    }
    
    func add(note: Models.Note, at frame: CGRect, for pad: Models.Pad) {
        var nodes = pad.nodes
        nodes[note.id] = .init(type: .note, frame: frame)
        pad.nodes = nodes
    }
    
    func set(note: Models.Note, at frame: CGRect, for pad: Models.Pad) {
        var nodes = pad.nodes
        nodes[note.id] = .init(type: .note, frame: frame)
        pad.nodes = nodes
    }
    
    func set(intent: Intent) {
        self.intent = intent
    }
    
    // 添加媒体节点到 pad
    func add(thing: Models.Thing, at frame: CGRect, for pad: Models.Pad) {
        var nodes = pad.nodes
        nodes[thing.id] = .init(type: .media, frame: frame)
        pad.nodes = nodes
    }
}
