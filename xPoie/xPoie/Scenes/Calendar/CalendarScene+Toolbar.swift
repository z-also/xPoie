import SwiftUI

struct CalendarSceneToolbar: View {
    @Environment(\.calendar) var calendar
    
    var body: some View {
        HStack {
            Spacer().frame(width: 60)
            
            Text(calendar.date, formatter: Cal.formatter("MMMM"))
                .typography(.p, size: .h3)

            Text(calendar.date, formatter: Cal.formatter("yyyy"))
                .typography(.desc, size: .h3, weight: .light)
            
            Spacer()
        }
    }
}
