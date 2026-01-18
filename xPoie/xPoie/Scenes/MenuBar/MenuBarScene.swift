import SwiftUI

struct MenuBarScene: View {
    @Environment(\.vars) var vars
    @Environment(\.agenda) var agenda
    @Environment(\.colorScheme) var colorSchema

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                AgendaLineup(tasks: agenda.tasks)
            }
            .padding(6)
        }
        .frame(width: 460)
        .background(vars.theme.fill.window)
        .containerBackground(.thinMaterial, for: .window)
    }
}
