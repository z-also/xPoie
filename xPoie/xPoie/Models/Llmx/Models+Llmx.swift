import SwiftUI
import SwiftData

extension Models {
    class Llmx {
        @Model class Message {
            var id: UUID
            var content: AttributedString
            
            init(id: UUID, content: AttributedString? = nil) {
                self.id = id
                self.content = content ?? .init()
            }
        }
    }
}
