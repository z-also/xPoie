import SwiftUI
import SwiftData

extension Modules.Events {
    @Model class Space {
        var id: UUID
        var name: String
        var role: String
        var color: String

        init(name: String, role: String, color: String) {
            self.id = UUID()
            self.name = name
            self.role = role
            self.color = color
        }
    }
    
    func fetchSpaceList() {
        do {
            let res = try Store.shared.context.fetch(FetchDescriptor<Space>())
            spaces = .init(data: res)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func createSpace(name: String, role: Role, color: String) {
        let space = Space(name: name, role: role.rawValue, color: color)
        Store.shared.context.insert(space)
        fetchSpaceList()
    }
    
    func space(for role: Role) -> Space {
        return spaces.data.first { $0.role == role.rawValue }!
    }
    
    func load(by space: Space) {
        let id = space.id
        
        let fetchDescriptor = FetchDescriptor<Item>(
            predicate: #Predicate { item in
                item.space.id == id
            }
        )

        do {
            let result = try Store.shared.context.fetch(fetchDescriptor)
            
            result.forEach { item in
                items[item.id] = item
            }
            
            byspace[space.id] = .init(data: result.map { $0.id }, status: .success, cursor: 0)

        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
