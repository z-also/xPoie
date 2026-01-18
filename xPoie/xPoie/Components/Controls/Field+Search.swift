import SwiftUI

struct SearchBox: View {
    @State var search = ""
    @Environment(\.input) var input
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .frame(width: 12, height: 12)
                .padding(6)
            
            OmniField(search, placeholder: "Search ...")
                .behavior(.alwaysEditable)
                .field(.search, focus: input.focus == .search)
                .on(focus: onFocus, blur: onBlur, edit: onEdit, submit: onSubmit)
                .frame(width: 160)
        }
        .padding(0, 6, 0, 12)
    }
    
    private func onFocus() {
        withAnimation { input.focus = .search }
    }
    
    private func onBlur() {
        if input.focus == .search {
            withAnimation { input.focus = .none }
        }
    }
    
    private func onEdit(value: String) {
        search = value
    }
    
    private func onSubmit() -> Bool {
        return true
    }
}
