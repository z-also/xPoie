import SwiftUI

struct CatalogsCtrlbar<T: View>: View {
    var title: String
    @ViewBuilder var menu: () -> T
    
    var body: some View {
        HStack {
//            Image(systemName: "scribble.variable")
//                .resizable()
//                .frame(width: 12, height: 12)
//                .padding(.leading, 2)
//            
            Text(title).typography(.legend, weight: .bold)

            Spacer()
            
            Menu { menu() } label: {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 10, height: 10)
            }
            .menuStyle(.button)
            .menuIndicator(.hidden)
            .buttonStyle(.omni.with(size: .btn))
        }
        .padding(0, 0, 0, 4)
    }
}
