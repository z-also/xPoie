import SwiftUI

struct AccountFeature_ProfileLink: View {
    var body: some View {
        Button(action: onClick) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 20, height: 20)
                .background(.green)
                .clipShape(.rect(cornerRadius: 6))
            
            Text("Z's Space")
        }
        .buttonStyle(.omni)
    }
    
    private func onClick() {
        Modules.main.switch(scene: .account)
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
