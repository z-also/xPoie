import SwiftUI
import SwiftData

extension Modules.Projects {
    func toggleNotesPresented(project: Models.Project) {
        withAnimation {
            project.notesPresented.toggle()
        }
    }
}
