import SwiftUI

extension Modules.Spotlight {
    func toggle(pin: Bool) {
        self.pinned = pin
    }
    
    func toggle(collapse: Bool) {
        withAnimation {
            self.collapsed = collapse
        }
        toggle(pin: collapse)
    }

    func set(theme: Theme) {
        self.theme = theme
        Preferences[.spotlightTheme] = theme.name
    }
    
    func set(scene: Scene) {
        withAnimation {
            self.scene = scene
        }
    }
    
    func set(taskScene: TaskScene) {
        withAnimation {
            self.taskScene = taskScene
        }
    }
    
    func set(noteScene: NoteScene) {
        withAnimation {
            self.noteScene = noteScene
        }
    }

    func useCurrentProject() {
        // 如果当前项目是task类型，且taskProject为空，则设置为当前项目
        if let currentProject = Modules.projects.currentProject,
           currentProject.type == .task,
           Modules.projects.scene == .none {
            taskProject = currentProject
        } else {
            taskProject = nil
        }
    }
    
    func submitNewNoteCreate() -> Models.Note? {
        guard !newNote.content.characters.isEmpty else {
            return nil
        }
        
        let pid = newNote.parent ?? Consts.uuid
        
        if let note = Modules.notes.createNote(at: 0, in: pid, frame: .zero) {
            note.title = newNote.title
            note.content = newNote.content
            
            newNote = .init()
            return note
        }
        
        return nil
    }
}
