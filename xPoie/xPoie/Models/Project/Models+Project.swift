import SwiftUI
import SwiftData

extension Models {
    @Model class Project {
        var id: UUID
        var type: Type
        var rank: String
        var icon: String
        var title: String
        var color: String
        var status: String
        var parentId: UUID?
        var notes: AttributedString
        var createdAt: Date
        var notesPresented: Bool = true
        
        enum `Type`: Codable {
            case pad
            case task
//            case note
//            case board
            case group
            case chat
        }
        
        struct Metas {
            var id: UUID?
            var type: Type
            var title = ""
            var icon = ""
            var color = ""
            var parentId: UUID?
            var notes = AttributedString("")
        }

        init(id: UUID, metas: Metas, rank: String, parentId: UUID?) {
            self.id = id
            self.type = metas.type
            self.rank = rank
            self.icon = metas.icon
            self.title = metas.title
            self.color = metas.color
            self.status = "normal"
            self.parentId = parentId
            self.notes = metas.notes
            self.createdAt = .now
            self.notesPresented = !metas.notes.characters.isEmpty
        }
        
        static func metas(for project: Project) -> Metas {
            return .init(
                id: project.id,
                type: project.type,
                title: project.title,
                icon: project.icon,
                color: project.color,
                parentId: project.parentId,
                notes: project.notes
            )
        }
    }
}
