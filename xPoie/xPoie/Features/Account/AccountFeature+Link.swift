import SwiftUI

struct AccountFeature_ProfileLink: View {
    @State private var hovered = false
    var body: some View {
        Button(action: onClick) {
            Image(systemName: hovered ? "gear" : "plus")
                .resizable()
                .frame(width: 16, height: 16)
                .padding(2)
                .background(hovered ? .clear : .green)
                .clipShape(.rect(cornerRadius: 6))
            
            Text("Z's Space")
        }
        .buttonStyle(.omni)
        .onHover { h in withAnimation { hovered = h } }
    }
    
    private func onClick() {
        Modules.main.switch(scene: .settings)
    }
}

struct AccountFeature_SignOutBtn: View {
    @Environment(\.account) var account
    
    var body: some View {
        Button(action: signOut) {
            Text("Sign out")
        }
        .buttonStyle(.omni)
    }
    
    private func signOut() {
        try? accountService.signOut()
        account.set(signedIn: false)
    }
}
