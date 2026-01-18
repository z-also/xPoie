import SwiftUI

struct ProjectMetasEdit: View {
    let specs: Modules.Projects.Specs
    @Binding var metas: Models.Project.Metas
    @Binding private var titleSugs: [Modules.Projects.Sug]
    
    @Environment(\.input) var input
    @State private var hoveredTitleSug: Modules.Projects.Sug?
    @State private var selectedTitleSug: Modules.Projects.Sug?
    
    init(metas: Binding<Models.Project.Metas>,
         specs: Modules.Projects.Specs,
         sugs: Binding<[Modules.Projects.Sug]>) {
        self.specs = specs
        self._metas = metas
        self._titleSugs = sugs
    }

    var body: some View {
        VStack(alignment: .leading) {
            Callout(icon: "info.circle.fill", title: specs.what, message: specs.intro)
            
            Spacer().frame(height: 16)
            
            Text("Title").font(size: .p, weight: .medium)

            HStack(spacing: 4) {
                IconPicker(
                    icon: hoveredTitleSug?.icon ?? metas.icon,
                    color: hoveredTitleSug?.color ?? metas.color,
                    action: setIcon
                )
                OmniField(
                    metas.title,
                    placeholder: hoveredTitleSug?.title ?? "your title"
                )
                    .field(.title0, focus: input.focus == .title0)
                    .behavior(.autofocusAlwaysEditable)
                    .style(typography: .label)
                    .on(focus: onTitleFocus, edit: onTitleEdit)

                Spacer()
            }
            .padding(2, 0)
            .modifier(OmniStyle.omni.with(visual: .field, active: input.focus == .title0))

            Text("or use suggestions below to get started quickly")
                .typography(.desc)
                .padding(.top, 4)
            
            Tags(
                sugs: titleSugs,
                selected: selectedTitleSug,
                onHover: { hoveredTitleSug = $0 },
                onSelect: { select(titleSug: $0) }
            )
            
            Spacer().frame(height: 22)

            Text("Description").font(size: .p, weight: .medium)

            OmniRTex(metas.notes, placeholder: "like instrucments for prompts", height: 100)
                .field(.notes0, focus: input.focus == .notes0)
                .on(focus: onNotesFocus, edit: onNotesEdit)
                .behavior(.minimal)
                .style(typography: .body)
                .padding(6, 6)
                .frame(maxWidth: .infinity)
                .modifier(OmniStyle(visual: .field, padding: .sm, active: input.focus == .notes0))
        }
    }
    
    private func setIcon(icon: String, color: String) {
        metas.icon = icon
        metas.color = color
    }
    
    private func onTitleFocus() {
        input.focus = .title0
    }
    
    private func onTitleEdit(value: String) {
        metas.title = value
    }
    
    private func onNotesFocus() {
        input.focus = .notes0
    }
    
    private func onNotesEdit(value: AttributedString) {
        metas.notes = value
    }
    
    private func select(titleSug sug: Modules.Projects.Sug) {
        selectedTitleSug = sug
        metas.icon = sug.icon
        metas.color = sug.color
        metas.title = sug.title
    }
}

fileprivate struct Tags: View {
    let sugs: [Modules.Projects.Sug]
    let selected: Modules.Projects.Sug?
    let onHover: (Modules.Projects.Sug?) -> Void
    let onSelect: (Modules.Projects.Sug) -> Void
    
    var body: some View {
        HStack {
            ForEach(sugs, id: \.title) { sug in
                Button(action: { onSelect(sug) }) {
                    Image(systemName: sug.icon)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color(sug.color))
                    Text(sug.title)
                }
                .buttonStyle(.omni.with(visual: .tag, padding: .lg, active: isSelected(sug: sug)))
                .onHover{ onHover($0 ? sug : nil) }
            }
        }
    }
    
    private func isSelected(sug: Modules.Projects.Sug) -> Bool {
        selected?.title == sug.title
    }
}
