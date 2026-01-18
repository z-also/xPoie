import SwiftUI

struct ProjectsSceneGroup: View {
    var project: Models.Project
    
    var body: some View {
        VStack {
            Header(project: project, createProject: createProject)
        }
    }
    
    func createProject() {
        
    }
}

fileprivate struct Header: View {
    var project: Models.Project
    var createProject: () -> Void

    @Environment(\.vars) var vars
    @Environment(\.input) var input

    var body: some View {
        HStack {
            TextField(
                "",
                text: Binding(
                    get: { project.title },
                    set: { project.title = $0 }
                )
            )
            .typography(.h3)
            .textFieldStyle(.plain)
//            .focused(focus!, equals: .row(id: project.id.uuidString))
            .onSubmit {
                input.focus = .none
            }

            Spacer()
            
            Button(action: createProject) {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .help("hahah")
            }
            
            Button(action: createProject) {
                Image(systemName: "text.alignright")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .help("outline")
            }
        }
        .padding(.trailing)
        .padding(.vertical, 0)
        .padding(.leading, 62)
    }
}
