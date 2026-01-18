import SwiftUI
import SwiftData

extension Models {
    @Model class Task: Span {
        var id: UUID
        var type: `Type`
        var block: UUID?
        var parent: UUID?
        var project: UUID?
        var title: String
        var rank: String
        var status: Status
        var notes: AttributedString

        // 开始时间
        var startAt: Date?
        // 结束时间
        var endAt: Date?
        // 创建时间
        var createdAt: Date?
        // 修改时间
        var modifiedAt: Date?
        // 完成时间
        var completedAt: Date?
        // 提醒数组
        var reminders: [Reminder]
        
        var count: Int = 0

        init(block: UUID? = nil,
             parent: UUID? = nil,
             project: UUID? = nil,
             title: String = "",
             rank: String = "",
             type: `Type` = .task
        ) {
            self.id = UUID()
            self.block = block
            self.parent = parent
            self.project = project
            self.title = title
            self.type = type
            self.rank = rank
            self.status = .none
            self.startAt = nil
            self.endAt = nil
            self.createdAt = nil
            self.modifiedAt = nil
            self.completedAt = nil
            self.count = 0
            self.reminders = []
            self.notes = AttributedString("")
        }
        
        enum Status: Int, Codable {
            case none
            case done
        }
        
        struct Reminder: Codable {
            var id: UUID
            var time: Date
            var note: String
            var isEnabled: Bool
            
            enum Status: Int, Codable {
                case acked
                case normal
                case missed
                case upcoming
            }

            init(time: Date, note: String = "") {
                self.id = UUID()
                self.time = time
                self.note = note
                self.isEnabled = true
            }
        }
        
        enum `Type`: Int, Codable, CaseIterable {
            case task
            case milestone
        }
        
        @Model class Block {
            var id: UUID
            var rank: String = ""
            var title: String = ""
            var desc: String = ""
            var project: UUID? = nil
            
            init(id: UUID? = nil, title: String = "", project: UUID? = nil, rank: String = "") {
                self.id = id ?? UUID()
                self.rank = rank
                self.title = title
                self.project = project
            }
        }
    }
}
