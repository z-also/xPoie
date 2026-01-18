import SwiftUI

struct ProjectsFeatureNavbar<Extra: View>: View {
    let project: Models.Project
    @ViewBuilder let extra: () -> Extra

    init(project: Models.Project,
         @ViewBuilder extra: @escaping () -> Extra = { EmptyView() }) {
        self.project = project
        self.extra = extra
    }

    var body: some View {
        HStack(spacing: 6) {
            ProjectsFeatureTitleSetter(project: project)

            Spacer()

            HStack(spacing: 16) {
                extra()
                
                ExtraMenu {
                    Button(action: toggleNotesPresented ) {
                        Label(project.notesPresented ? "Hide notes" : "Show notes", systemImage: "chevron.up.chevron.down")
                    }
                    Button(action: {}) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .padding(0, 4)
        }
        .padding(5, 12, 4, 16)
    }
    
    private func toggleNotesPresented() {
        Modules.projects.toggleNotesPresented(project: project)
    }
}

struct ProjectsFeatureTitleSetter: View {
    let project: Models.Project
    @FocusState var focus: Bool
    @Environment(\.input) var input

    var body: some View {
        HStack(spacing: 6) {
            IconPicker(icon: project.icon, color: project.color, size: 14) { i, c in
                project.icon = i
                project.color = c
            }
            
            let field: Field = .title(id: project.id)
            
//            OmniField(project.title, placeholder: "Project title...")
//                .behavior(.auto)
//                .field(field, focus: input.focus == field)
//                .style(typography: .h4)
//                .on(focus: onFocus, edit: onEdit, submit: onSubmit, tab: onSubmit)
//                .onTapGesture { input.focus = field }

            TextField(
                "Title",
                text: Binding(
                    get: { project.title },
                    set: { project.title = $0 }
                )
            )
            .typography(.h4)
            .focused($focus)
            .textFieldStyle(.plain)
            .onSubmit {
                focus = false
            }
        }
        .padding(0, 12)
    }
    
    private func onFocus() {
        input.focus = .title(id: project.id)
    }
    
    private func onEdit(value: String) {
        project.title = value
    }
    
    private func onSubmit() -> Bool {
        return true
    }
}
