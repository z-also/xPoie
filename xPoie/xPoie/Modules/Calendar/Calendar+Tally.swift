import SwiftUI

extension Modules.Calendar {
    enum Frame {
        case day
        case week
        case month
    }
    
    func view(date: Date) {
        view(date: date, frame: self.frame)
    }
    
    func view(date: Date, frame: Frame) {
        self.date = date
        self.frame = frame
        
        let mdates = Cal.view(month: date)
        
        switch frame {
        case .day:
            schedule = .init(dates: [date])
        case .week:
            let dates = mdates.first { dates in
                dates.contains {  Cal.cal.isDate($0.date, equalTo: date, toGranularity: .day) }
            }
            schedule = schedule(dates: dates!.map{ $0.date })
        case .month:
            let dates = mdates.first { dates in
                dates.contains {  Cal.cal.isDate($0.date, equalTo: date, toGranularity: .day) }
            }
            schedule = schedule(dates: dates!.map{ $0.date })
        }
    }
    
    func revalidateSchedule() {
        schedule = schedule(dates: schedule.dates)
    }
}
