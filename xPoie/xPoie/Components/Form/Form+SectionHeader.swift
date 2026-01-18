import SwiftUI

struct FormSectionHeader: View {
    let title: String
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(title)
            .font(size: .xs, weight: .medium)
            .textCase(.uppercase)
            .foregroundStyle(theme.text.tertiary)
    }
}
