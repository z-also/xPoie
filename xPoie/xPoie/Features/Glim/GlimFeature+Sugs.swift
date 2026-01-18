import SwiftUI

struct GlimFeature_Sugs: View {
    let sugs: [Modules.Glim.Sug]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(sugs, id: \.title) { sug in
                Button(action: {}) {
                    Image(systemName: sug.icon)
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Text(sug.title)
                }
                .buttonStyle(.omni.with(visual: .dumpLink))
            }
        }
    }
}
