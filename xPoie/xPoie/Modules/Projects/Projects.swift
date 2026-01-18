import SwiftUI

extension Modules {
    @Observable class Projects {
        // view
        var view: View = .list
        // scene
        var scene: Scene = .none
        // project data source
        var projects: [UUID: Models.Project] = [:]
        // [catalog id: a collection of project ids]
        var catalogs: [UUID: Collection<UUID>] = [:]
        // [catalog id: Bool]
        var expandeds: [UUID: Bool] = [:]
        // current project
        var currentProject: Models.Project?
        
        enum View: String {
            case list
            case kanban
        }
        
        enum Scene: String {
            case none
            case brain
            case calendar
        }
        
        struct Specs {
            var what: String
            var intro: String
            var title: String
            var desc: String
        }

        typealias Sug = Option<String, String>
    }
}

extension Modules.Projects {
    func set(scene: Scene) {
        self.scene = scene
    }
    
    func set(view: View) {
        self.view = view
    }
    
    func boot() {
        catalogs[Consts.uuid] = .init(data: [])
        load(catalog: Consts.uuid)
    }
    
    func selectFirstLeaf() {
        guard let rootCatalog = catalogs[Consts.uuid] else { return }
        
        var pathIds: [UUID] = []
        
        // 深度优先搜索辅助函数
        func dfs(_ projectId: UUID) -> Bool {
            guard let project = projects[projectId] else { return false }
            
            // 记录路径ID
            pathIds.append(projectId)
            
            // 如果是task类型，返回true终止搜索
            if project.type == .task {
                return true
            }
            
            // 如果是group类型，加载其子目录
            if project.type == .group {
                load(catalog: projectId)
                // 从catalogs获取子项目
                if let childIds = catalogs[projectId]?.data {
                    for childId in childIds {
                        if dfs(childId) {
                            return true
                        }
                    }
                }
            }
            
            // 如果当前路径没有找到task，移除当前ID
            pathIds.removeLast()
            return false
        }
        
        // 从根目录开始搜索
        for projectId in rootCatalog.data {
            if dfs(projectId) {
                // 按路径顺序select
                for id in pathIds {
                    select(id: id)
                }
                return
            }
        }
    }
}
