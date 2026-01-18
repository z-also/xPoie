import SwiftUI
import SwiftData

extension Modules.Tasks {
    struct Filter {
        var block: (Bool, UUID?) = (false, nil)
        var parent: (Bool, UUID?) = (false, nil)
        var project: (Bool, UUID?) = (false, nil)
        var when: (start: Date, end: Date)? = nil
        var title: (String)? = nil
    }
    
    func fetchTasks(descriptor: FetchDescriptor<Models.Task>) throws -> [Models.Task] {
        let result = try Store.shared.context.fetch(descriptor)
        result.forEach { upsert(task: $0) }
        return result
    }
    
    func fetchTasks(filter: Filter) throws -> [Models.Task] {
        let filterWhen = filter.when != nil
        let filterTitle = filter.title != nil
        
        let (filterBlock, blockId) = filter.block
        let (filterParent, parentId) = filter.parent
        let (filterProject, projectId) = filter.project
        
        let (whenStart, whenEnd) = filter.when ?? (nil, nil)
        let (titleContains) = filter.title ?? (nil)

        let titlePredicate = #Predicate<Models.Task> {
            $0.title.contains(titleContains!)
        }
        
        let idPredicate = #Predicate<Models.Task> {
            (filterBlock ? $0.block == blockId : true)
            && (filterParent ? $0.parent == parentId : true)
            && (filterProject ? $0.project == projectId : true)
        }

        let whenPredicate = #Predicate<Models.Task> {
            ($0.startAt.flatMap { $0 < whenEnd! } ?? false) && ($0.endAt.flatMap{ $0 > whenStart! } ?? false)
        }
        
        let descriptor = FetchDescriptor<Models.Task>(
            predicate: #Predicate{ task in
                idPredicate.evaluate(task)
                && (filterWhen ? whenPredicate.evaluate(task) : true)
                && (filterTitle ? titlePredicate.evaluate(task) : true)
            },
            sortBy: [.init(\.rank, comparator: .lexical, order: .forward)]
        )

        return try fetchTasks(descriptor: descriptor)
    }
}
