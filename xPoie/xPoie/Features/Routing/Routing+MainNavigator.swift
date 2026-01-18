import SwiftUI

struct MainNavigator: View {
    @Environment(\.main.scene) private var scene

    var body: some View {
        HStack {
            Button(action: { Modules.main.switch(scene: .projects) }) {
                Image(systemName: "folder")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .font(.headline)
                Text("Projects").lineLimit(1).fixedSize()
            }
            .buttonStyle(.omni.with(padding: .sm, active: scene == .projects))
            .transition(.opacity.combined(with: .move(edge: .leading)))

            Button(action: { Modules.main.switch(scene: .calendar) }) {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .font(.headline)
                Text("Calendar").lineLimit(1).fixedSize()
            }
            .buttonStyle(.omni.with(padding: .sm, active: scene == .calendar))
            .transition(.opacity.combined(with: .move(edge: .leading)))

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .font(.headline)
                Text("⌘+K").typography(.desc)
            }
            .buttonStyle(.omni.with(padding: .sm))
        }
        .padding(.horizontal, 8)
    }
    
    private func onSearch() {
        
    }
}

