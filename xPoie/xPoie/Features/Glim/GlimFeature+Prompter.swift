import SwiftUI

struct GlimFeature_Prompter: View {
    @State private var prompt = ""
    
    @Environment(\.input) private var input
    
    var body: some View {
        VStack {
            OmniField(prompt, placeholder: "Search ...")
                .behavior(.alwaysEditable)
                .field(.prompt, focus: input.focus == .prompt)
                .on(focus: onFocus, blur: onBlur, edit: onEdit, submit: onSubmit)
        }
        .padding(12)
    }
    
    private func onFocus() {
        input.focus = .prompt
    }
    
    private func onBlur() {
        if input.focus == .prompt {
            input.focus = .none
        }
    }
    
    private func onEdit(value: String) {
        prompt = value
    }
    
    private func onSubmit() -> Bool {
        onBlur()
        return true
    }
}
