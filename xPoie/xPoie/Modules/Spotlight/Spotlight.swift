import SwiftUI

extension Modules {
    @Observable class Spotlight {
        var scene: Scene = .ai
        var pinned = false
        var collapsed = false
        var theme = Theme.named(Preferences[.spotlightTheme]) ?? Theme.plastic
        var taskProject: Models.Project? = nil
        var newNote: Models.Note = .init()
        var newTask: Models.Task = .init()
        var noteScene: NoteScene = .browse
        var taskScene: TaskScene = .browse
        
        var isAiExpanded = false

        enum Scene: String {
            case ai
            case tasks
            case notes
            case search
        }
        
        enum TaskScene: String {
            case create
            case browse
        }
        
        enum NoteScene: String {
            case create
            case browse
            case research
        }
    }
} 
