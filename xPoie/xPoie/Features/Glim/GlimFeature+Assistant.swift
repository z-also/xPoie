import SwiftUI

struct GlimFeature_Assistant: View {
    @Environment(\.glim) var glim
    
    var body: some View {
        VStack {
            Header()
            
            ScrollView {
                VStack {
                    GlimFeature_Sugs(sugs: glim.sugs)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GlimFeature_Prompter()
        }
        .padding(4, 2)
        .frame(idealWidth: 320, maxWidth: 360, idealHeight: 240, maxHeight: 520, alignment: .leading)
    }
}

fileprivate struct Header: View {
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: close) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.omni)
        }
    }
    
    private func close() {
        Modules.glim.present(.none)
    }
}
