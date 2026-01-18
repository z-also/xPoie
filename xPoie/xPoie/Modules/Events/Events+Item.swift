import SwiftUI
import SwiftData

extension Modules.Events {
    enum Status: Int, Codable {
        case none
        case done
    }
    
    struct Record: Codable {
        var id: UUID = UUID()
        var title: String = ""
        var desc: String = ""
        var color: String = ""
        var notes: String = ""
        var space: UUID = UUID()
        var startTime: Date = .now
        var endTime: Date = .now
        var status: Status = .none
    }
    
    @Model class Item {
        var id: UUID
        var title: String
        var desc: String
        var startTime: Date
        var endTime: Date
        var color: String?
        var notes: String?
        var space: Modules.Events.Space
        var nesteds: [Record] = []
        
        init(title: String, desc: String, startTime: Date, endTime: Date, space: Modules.Events.Space, color: String? = nil) {
            self.id = UUID()
            self.title = title
            self.desc = desc
            self.startTime = startTime
            self.endTime = endTime
            self.color = color
            self.space = space
        }
    }
}

extension Modules.Events {
    func createDraftItem(start: Date, space: Modules.Events.Space) -> Item {
        let event: Modules.Events.Item = .init(
            title: "haha",
            desc: "vv",
            startTime: start,
            endTime: start,
            space: space
        )
        return event
    }
    
    func save(item: Item) {
        Store.shared.context.insert(item)
    }
    
    func load(ids: [UUID]) {
        let fetchDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                ids.contains(item.id)
            }
        )
        
        do {
            let result = try Store.shared.context.fetch(fetchDescriptor)
            result.forEach { item in
                items[item.id] = item
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
