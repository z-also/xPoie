import SwiftUI

struct InboxNotes: View {
    @Environment(\.vars) var vars
    @Environment(\.tasks) var tasks
    @Environment(\.theme) var theme
    @Environment(\.agenda) var agenda
    
    @State private var expanded = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Editor()
                .padding(10, 6, 0, 6)
            
//            Spacer().frame(height: 24)
            
            Header(expanded: expanded, toggle: toggle)
        }
    }
    
    private func toggle() {
        withAnimation {
            expanded.toggle()
        }
    }
}

fileprivate struct Editor: View {
    @Environment(\.input) var input
    
    let field: Field = .desc(id: Consts.uuid)
    
    @State private var attributedString: AttributedString = AttributedString("Hatters gonna hate.\nThe quick brown fox jumps over the lazy dog.\nLorem ipsum dolor sit amet, consectetur adipiscing elit.\nSed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notepad")
                    .typography(.h5)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Save to")
                }
                .buttonStyle(.omni.with(visual: .brand.capsule, padding: .lg))
            }
            
            OmniRTex(attributedString, placeholder: "")
                .field(field, focus: input.focus == field)
                .behavior(.omni)
                .on(focus: onFocus)
                .style(typography: .body)
                .padding(8)
                .modifier(OmniStyle.omni.with(visual: .field, active: input.focus == field))
                .onTapGesture {
                    input.focus = field
                }
            
            Spacer().frame(height: 24)
        }
    }
    
    private func onFocus() {
        input.focus = field
    }
    
    private func onBlur() {
        
    }
}

fileprivate struct Header: View {
    var expanded: Bool
    var toggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: toggle) {
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 5, height: 9)
                    .rotationEffect(.degrees(expanded ? 90 : 0))
                
                Text("Notepads")
                    .typography(.h5)
            }
            .buttonStyle(.omni.with(padding: .md))
            
            Button(action: {  }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .buttonStyle(.omni.with(size: .btn))

            Spacer()
        }
    }
}
