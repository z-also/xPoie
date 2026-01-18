import SwiftUI

struct ProjectsSceneTrash: View {
    var body: some View {
        VStack {
            Ctrlbar()
            
        }
    }
}


fileprivate struct Ctrlbar: View {
    var body: some View {
        HStack {
            Text("Recently Deleted").typography(.h3)
            
            Spacer()
        }
        .padding(.trailing)
        .padding(.top, 13)
        .padding(.leading, 52)
    }
}
