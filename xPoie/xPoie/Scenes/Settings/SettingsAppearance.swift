import SwiftUI

struct SettingsAppearance: View {
    @Environment(\.vars) var vars
    
    @State var isOn = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Section {
                Text("Interface theme")
                    .typography(.h4)
                
                Text("Personalize the appearance of your app. Select a theme, and sync with your system's light/dark mode")
                    .typography(.tip)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Consts.themes) { item in
                            SettingsInterfaceThemeCard(
                                image: item.icon,
                                title: item.title,
                                selected: vars.theme.name == item.value.name
                            )
                            .onTapGesture {
                                withAnimation {
                                    vars.set(theme: item.value)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            Section {
                Text("Accent color")
                    .typography(.h4)
            }
        }
    }
}


// Recent Activities
