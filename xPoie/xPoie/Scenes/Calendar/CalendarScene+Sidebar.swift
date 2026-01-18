import SwiftUI

struct CalendarSceneSidebar: View {
    @State var isExpanded = true
    
    @Environment(\.vars) var vars
    @Environment(\.events) var events
    @Environment(\.calendar) var calendar

    var body: some View {
        VStack(alignment: .leading) {
//            Spacer().frame(height: 44)
            
            OmniCalendar(
                mode: .single,
                selection: [calendar.date],
                onSelect: onSelect,
                onNav: onNav 
            )
            
            Spacer().frame(height: 20)
            
            CalendarSpaceWidget(
                spaces: events.spaces.data,
                selecteds: calendar.selectedSpaces
            )
            
            Spacer()
        }
        .padding(12)
    }

    func onNav(date: Date) {
        calendar.view(date: date, frame:.month)
    }
    
    func onSelect(date: Date) {
        calendar.view(date: date)
    }
    
    func onYearChange() {
        
    }
    
    func onDayChange() {
        
    }
}

