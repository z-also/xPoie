import SwiftUI

struct Modules {}

extension Modules {
    nonisolated(unsafe) static let vars = Vars()
    nonisolated(unsafe) static let main = Main()
    nonisolated(unsafe) static let input = Input()
    nonisolated(unsafe) static let settings = Settings()
    
    nonisolated(unsafe) static let pads = Pads()
    nonisolated(unsafe) static let glim = Glim()
    nonisolated(unsafe) static let tasks = Tasks()
    nonisolated(unsafe) static let notes = Notes()
    nonisolated(unsafe) static let inbox = Inbox()
    nonisolated(unsafe) static let things = Things()
    nonisolated(unsafe) static let events = Events()
    nonisolated(unsafe) static let agenda = Agenda()
    nonisolated(unsafe) static let projects = Projects()
    nonisolated(unsafe) static let calendar = Calendar()
    nonisolated(unsafe) static let spotlight = Spotlight()
}

extension EnvironmentValues {
    @Entry var vars = Modules.vars
    @Entry var main = Modules.main
    @Entry var input = Modules.input
    
    @Entry var glim = Modules.glim
    @Entry var pads = Modules.pads
    @Entry var inbox = Modules.inbox
    @Entry var tasks = Modules.tasks
    @Entry var notes = Modules.notes
    @Entry var things = Modules.things
    @Entry var events = Modules.events
    @Entry var agenda = Modules.agenda
    @Entry var theme = Modules.vars.theme
    @Entry var calendar = Modules.calendar
    @Entry var settings = Modules.settings
    @Entry var projects = Modules.projects
    @Entry var spotlight = Modules.spotlight
}

extension Modules {
    @MainActor
    static func boot() {
        Store.shared = .init()

        pads.load()
        projects.boot()
        
        notes.fetchStickyNotes()
        
        tasks.prepare(inbox: Consts.uuid2)
        
        events.fetchSpaceList()
        calendar.view(date: Date())
        notes.fetchPinneds()
        
        if events.spaces.data.isEmpty {
            prepareEventSpaces()
        }
        
        if projects.projects.isEmpty {
            Samples.createSampleProjects()
        }

        projects.loadAllCatalogsBreadthFirst(rootCatalog: Consts.uuid)
        
//        projects.selectFirstLeaf()

        agenda.view(date: Cal.today, span: 4)
        
        glim.set(sugs: [
            .init(icon: "plus", title: "Research a Topic"),
            .init(icon: "scribble.variable", title: "Write a Task"),
            .init(icon: "magnifyingglass", title: "Search web"),
            .init(icon: "book.pages", title: "Research a Topic"),
        ])
        
        pads.set(nodeGenres: [
            .init(icon: "plus", type: .note, title: "Research a Topic"),
            .init(icon: "scribble.variable", type: .note, title: "Write a Task"),
            .init(icon: "magnifyingglass", type: .note, title: "Search web"),
            .init(icon: "book.pages", type: .note, title: "Research a Topic"),
            .init(icon: "photo.on.rectangle.angled", type: .media, title: "Add Media"),
        ])
    }
    
    static func prepareEventSpaces() {
        events.createSpace(name: "Calendar", role: .calendar, color: "palette/blue")
        events.createSpace(name: "My Tasks", role: .task, color: "palette/green")
    }
}

extension Modules.Projects {
    /// 广度优先加载所有 group 目录，分批异步处理，避免主线程阻塞
    func loadAllCatalogsBreadthFirst(rootCatalog: UUID) {
        var queue: [UUID] = [rootCatalog]
        var visited: Set<UUID> = []
        
        func processNextBatch() {
            let batchSize = 3
            var count = 0
            while !queue.isEmpty && count < batchSize {
                let current = queue.removeFirst()
                if visited.contains(current) { continue }
                visited.insert(current)
                load(catalog: current)
                if let childIds = catalogs[current]?.data {
                    for childId in childIds {
                        if let project = projects[childId], project.type == .group {
                            queue.append(childId)
                        }
                    }
                }
                count += 1
            }
            if !queue.isEmpty {
//                DispatchQueue.main.async {
//                    processNextBatch()
//                }
            }
        }
        processNextBatch()
    }
}
