import SwiftUI

struct SpotlightTasks: View {
    @Environment(\.agenda) var agenda
    @Environment(\.spotlight) var spotlight
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            ActionBar()
            if spotlight.taskScene == .browse {
                AgendaLineup(tasks: agenda.tasks)
            }
            if spotlight.taskScene == .create {
                TasksFeatureQuickCreator(
                    task: spotlight.newTask,
                    project: spotlight.taskProject,
                    onCreate: onCreate,
                    onSelectProject: onSelectProjectForCreate
                )
            }
        }
    }
    
    private func onCreate() {
        if NSApplication.shared.mainWindow == nil {
            openWindow(id: "main")
            Modules.main.switch(scene: .projects)
        }
        NSApp.activate(ignoringOtherApps: true)
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func onSelectProjectForCreate(id: UUID) {
        Modules.spotlight.taskProject = Modules.projects.projects[id]
    }
}

fileprivate struct ActionBar: View {
    @Environment(\.theme) var theme
    @Environment(\.spotlight) var spotlight

    var body: some View {
        HStack {
            if spotlight.taskScene == .create {
                Button(action: { `switch`(scene: .browse) }) {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: 16, height: 12)
                }
                    .buttonStyle(.omni)
            }
            
            Button(action: { `switch`(scene: .create) }) {
                Label("Task", systemImage: "plus")
                    .padding(.vertical, 2)
            }
            .buttonStyle(.omni.with(active: spotlight.taskScene == .create))
            
            Spacer()
        }
        .padding(6, 12)
        .font(.system(size: 12))
    }
    
    private func `switch`(scene: Modules.Spotlight.TaskScene) {
        Modules.spotlight.set(taskScene: scene)
    }
}
