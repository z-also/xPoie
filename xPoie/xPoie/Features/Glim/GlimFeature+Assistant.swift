import Llmx
import SwiftUI

struct GlimFeature_Assistant: View {
    @Environment(\.glim.sugs) private var sugs
    var body: some View {
        VStack {
            Header()
            
            ScrollView {
                VStack {
                    GlimFeature_Sugs(sugs: sugs)
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
                    .frame(width: 12, height: 12)
            }
            .buttonStyle(.omni.with(padding: .md))
        }
    }
    
    private func close() {
        Modules.glim.present(.none)
    }
}
