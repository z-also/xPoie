import SwiftUI

struct StarterGuide: View {
    var icon: String
    var title: String
    var desc: String
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 240, height: 213)

            Text(title).typography(.h4)
            
            Text(desc).typography(.desc, size: .h6)
            
            Button(action: action) {
                Image(systemName: "wand.and.sparkles.inverse")
                    .resizable()
                    .fontWeight(.black)
                    .frame(width: 14, height: 14)

                Text("Create your first tasks block →").typography(.h6)
            }
            .buttonStyle(.omni.with(padding: .md, active: true))
        }
    }
}
