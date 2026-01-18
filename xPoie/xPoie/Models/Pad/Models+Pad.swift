import SwiftUI
import SwiftData

extension Models {
    @Model class Pad {
        var id: UUID
        var layout = Layout.list
        var createdAt: Date
        var width: CGFloat = 1000
        var height: CGFloat = 1000
        var _nodes: [UUID: _Node] = [:]
        
        enum Layout: Codable {
            case grid
            case list
        }
        
        struct Node: Codable {
            var type: `Type`
            var frame: CGRect
            enum `Type`: Codable {
                case note
                case media
            }
        }
        
        struct _Node: Codable {
            var type: Node.`Type`
            var frame: String
        }
        
        init(id: UUID, layout: Layout) {
            self.id = id
            self.layout = layout
            self.createdAt = .now
        }
        
        @Transient
        lazy var nodes: [UUID: Node] = initializeNodes() {
            didSet {
                _nodes = nodes.mapValues{ .init(type: $0.type, frame: Utilities.string(from: $0.frame)) }
            }
        }
        
        private func initializeNodes() -> [UUID: Node] {
            _nodes.mapValues{ .init(type: $0.type, frame: Utilities.rect(from: $0.frame)) }
        }
    }
}
