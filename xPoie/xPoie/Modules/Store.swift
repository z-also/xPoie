import SwiftData

class Store {
    let context: ModelContext
    let container: ModelContainer
    
    nonisolated(unsafe) static var shared: Store! = nil

    init() {
        let localModels: [any PersistentModel.Type] = [
            Models.Llmx.Message.self
        ]
        let cloudModels: [any PersistentModel.Type] = [
            Modules.Events.Space.self,
            Modules.Events.Item.self,
            Models.Project.self,
            Models.Task.Block.self,
            Models.Task.self,
            Models.Pad.self,
            Models.Note.self,
            Models.Thing.self
        ]
        
        let localConfig = ModelConfiguration(
            "xPoie_local",
            schema: Schema(localModels),
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        let cloudConfig = ModelConfiguration(
            "xPoie_iCloud",
            schema: Schema(cloudModels),
            isStoredInMemoryOnly: false,
            allowsSave: true,
//            cloudKitDatabase: .private("iCloud.com.xPoie")
            cloudKitDatabase: .automatic
        )
        
//        container = try! ModelContainer(
//            for: Schema([
//                Modules.Events.Space.self,
//                Modules.Events.Item.self,
//                Models.Project.self,
//                Models.Task.Block.self,
//                Models.Task.self,
//                Models.Pad.self,
//                Models.Note.self
//            ]),
//            configurations: .init(isStoredInMemoryOnly: false, allowsSave: true)
//        )
        
        container = try! ModelContainer(
            for: Schema(cloudModels + localModels),
            configurations: [cloudConfig, localConfig]
        )
        
        context = ModelContext(container)
//        context = container.mainContext
        context.autosaveEnabled = true
    }
}
