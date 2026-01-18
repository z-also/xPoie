import SwiftUI

struct InboxMain: View {
    @Environment(\.theme) var theme
    @Environment(\.agenda) var agenda
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 0) {
                VStack {
                    InboxToday()
                    
                    Spacer().frame(height: 32)
                    
                    InboxTasks()
                }
                
                VStack {
                    InboxFocus()
                }
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
