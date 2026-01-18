import Foundation

struct Cal {
    struct D {
        var date: Date
    }
    
    static var cal: Calendar {
        return Calendar.current
    }

    static var tz: TimeZone {
        return TimeZone.current
    }
    
    static var today: Date {
        return cal.startOfDay(for: Date.now)
    }
    
    // short hand for calendar.date
    static func date(of cmps: Set<Calendar.Component>, from: Date) -> Date {
        return cal.date(from: cmp(cmps, from: from))!
    }

    static func cmp(_ components: Set<Calendar.Component>, from date: Date) -> DateComponents {
        return cal.dateComponents(components, from: date)
    }
    
    enum Compare {
        case none
        case dayBefore
        case sameDay
        case dayAfter
    }
    
    // for a given date, build a grid of days for the corresponding month.
    // 7 days per grid row, with dates from previous/next month padded if needed.
    static func view(month d0: Date) -> [[D]] {
        let d = cal.startOfDay(for: d0)
        // get the first day of this month
        let mday0 = date(of: [.year, .month], from: d)
        // get the weekday of the first day of this month
        let wday0 = cal.component(.weekday, from: mday0)
        // how many days from last month should be display
        let begin = (7 + wday0 - cal.firstWeekday) % 7
        // get total days count of this month
        let count = cal.range(of: .day, in: .month, for: mday0)!.count
        // how many days from next month should be display
        let end = (7 - (begin + count) % 7) % 7
        // build days row (7 days per row)
        let rows = stride(from: -begin, to: count + end, by: 7)
        
        return rows.map { offset in (0..<7).map { weekday in
            let date = cal.date(byAdding: .day, value: weekday + offset, to: mday0)!
            return .init(date: date)
        }}
    }
    
    static var veryShortWeekdaySymbols: [String] {
        let formatter = DateFormatter()
        let symbols = formatter.veryShortWeekdaySymbols!
        let firstWeekday = cal.firstWeekday
        return Array(symbols[(firstWeekday - 1)..<symbols.count]) + Array(symbols[0..<(firstWeekday - 1)])
    }
    
    static func shift(_ cmp: Calendar.Component, from d: Date, by step: Int) -> Date {
        return cal.date(byAdding: cmp, value: step, to: d)!
    }
    
    static func timezone() -> String {
        return "GMT +\(tz.secondsFromGMT() / 3600)"
    }
    
    static func with(hour: Int, minute: Int, from _date: Date) -> Date? {
        var cmps = cmp([.year, .month, .day], from: _date)
        cmps.hour = hour
        cmps.minute = minute
        return cal.date(from: cmps)
    }
    
    static var fullFormatter: Formatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }
    
    static func formatter(_ dateFormat: String) -> Formatter {
        let f = DateFormatter()
        f.dateFormat = dateFormat
        return f
    }
    
    static func format(date: Date) -> String {
        var res = ""
        let now = Date()

        let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: date)).day ?? 0
        
        if days == 0 || days == 1 || days == -1 {
            let rel: [Int: String] = [0: "Today", 1: "Tomorrow", -1: "Yesterday"]
            res = rel[days]!
        } else {
            let fmt = DateFormatter()
            let years = cal.component(.year, from: date) != cal.component(.year, from: now)
            fmt.dateFormat = years ? "MMMM d, yyyy" : "MMMM d"
            res = fmt.string(from: date)
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        return "\(res) \(timeFormatter.string(from: date))"
    }
    
    static func compare(a: Date?, b: Date?) -> Compare? {
        guard let a = a, let b = b else {
            return nil
        }
        
        let cmp = cal.compare(a, to: b, toGranularity: .day)
        return cmp == .orderedSame ? .sameDay : cmp == .orderedAscending ? .dayBefore : .dayAfter
    }
    
    static func duration(from: Date, to: Date) -> String {
        var comps = [String]()
        
        let duration = Cal.cal.dateComponents([.day, .hour, .minute], from: from, to: to)
        
        if let days = duration.day, days > 0 {
            comps.append("\(days)day")
        }
        
        if let hours = duration.hour, hours > 0 {
            comps.append("\(hours)hr")
        }
        if let minutes = duration.minute, minutes > 0 {
            comps.append("\(minutes)min")
        }
        
        return comps.joined(separator: " ")
    }
}
