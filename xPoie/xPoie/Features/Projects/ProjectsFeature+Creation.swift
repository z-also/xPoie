import SwiftUI

struct ProjectMetasEditor: View {
    private let mode: Mode
    
    @State var sugs: [Modules.Projects.Sug]
    @Binding var metas: Models.Project.Metas
    
    let onCancel: () -> Void
    let onSubmit: (Models.Project.Metas) -> Void
    
    enum Mode: String {
        case new
        case edit
    }
    
    init(
        mode: Mode,
        metas: Binding<Models.Project.Metas>,
        onCancel: @escaping () -> Void,
        onSubmit: @escaping (Models.Project.Metas) -> Void
    ) {
        self.mode = mode
        self._metas = metas
        self.onCancel = onCancel
        self.onSubmit = onSubmit
        let sugs = Consts.projectCreationSugs[.pad]!
        self.sugs = sugs
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Create Notes pad").typography(.h5)
            
            ProjectMetasEdit(
                metas: $metas,
                specs: Consts.projectSpecs[metas.type]!,
                sugs: $sugs
            )
            
            Spacer().frame(height: 16)
            
            HStack {
                Spacer()
                
                Button(action: onCancel) {
                    Text("Cancel")
                }
                .buttonStyle(.omni.with(visual: .cancelBtn, padding: .lg))

                Button(action: { onSubmit(metas) }) {
                    Text("Create")
                }
                .disabled(metas.title.isEmpty)
                .buttonStyle(.omni.with(visual: .brand, padding: .lg))
            }
        }
        .padding(22)
        .frame(width: 560, alignment: .leading)
    }
}
