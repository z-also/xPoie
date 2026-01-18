import SwiftUI
import SwiftData

extension Models {
    @Model class Thing {
        var id: UUID
        var type: `Type`
        var parent: UUID?
        var title: String
        var createdAt: Date
        
        init(type: `Type`, parent: UUID? = nil) {
            self.id = UUID()
            self.type = type
            self.parent = parent
            self.title = ""
            self.createdAt = .now
        }
        
        enum `Type`: Codable {
            case media
        }
    }
}
