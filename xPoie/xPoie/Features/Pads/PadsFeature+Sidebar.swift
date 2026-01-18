import SwiftUI

struct PadsFeatureSidebar: View {
    let pad: Models.Pad
    let project: Models.Project
    
    @State private var selectedTab = 0
    
    @Environment(\.theme) var theme
    @Environment(\.pads.inspector) var inspector
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ForEach(Consts.padInspectors, id: \.0) { t in
                    Inspector(id: t.0, title: t.1, active: inspector == t.0, action: `switch`)
                }
                
                Spacer()
            }
            .padding(8, 0)
            
            Line()
                .background(theme.fill.secondary)
                .frame(height: 1)
                .padding(6, 4)

            ScrollView {
                Spacer().frame(height: 12).frame(maxWidth: .infinity)
                
                if inspector == .style {
                    PadsFeatureStyling(pad: pad)
                }
                if inspector == .action {
                    PadsFeatureAction(pad: pad, project: project)
                }
            }
            .padding(0, 5)

            Spacer()
        }
    }
    
    private func `switch`(inspector: Modules.Pads.Inspector) {
        Modules.pads.switch(inspector: inspector)
    }
}

fileprivate struct Inspector: View {
    let id: Modules.Pads.Inspector
    
    let title: String
    let active: Bool
    let action: (Modules.Pads.Inspector) -> Void
    
    var body: some View {
        Button(action: { action(id) }) {
            Text(title)
                .fontWeight(.regular)
        }
        .buttonStyle(.omni.with(visual: .tab, active: active))
    }
}

