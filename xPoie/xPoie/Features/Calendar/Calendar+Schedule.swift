import SwiftUI

struct CalendarSchedule: View {
    private let frame = Frame()
    
    @State var isEditing = false
    
    let dates: [Date]
    let tasks: [Models.Task]
    let theme: Theme
    
    fileprivate let coord: Coordinator
    
    init(dates: [Date], tasks: [Models.Task], theme: Theme) {
        self.dates = dates
        self.tasks = tasks
        self.theme = theme
        self.coord = .init()
    }
    
    var body: some View {
        GeometryReader { proxy in
            let cell = CGSize(
                width: (proxy.size.width - frame.marks - frame.ph) / Double(dates.count),
                height: max(proxy.size.height / 24, 56)
            )
            let t = tasks.filter { $0.startAt != nil && $0.endAt != nil }
            
            let tiles = coord.layout(spans: t, cell: cell, frame: frame, start: dates[0])

            ZStack(alignment: .topLeading) {
                DatePlates(dates: dates, markWidth: frame.marks, theme: theme)
                    .frame(height: frame.plates)
                    .padding(.trailing, frame.ph)
                    .overlay(alignment: .bottom) {
                        Rectangle().fill(theme.fill.secondary).frame(height: 0.5)
                    }

                ForEach(0..<dates.count, id: \.self) { index in
                    Spacer()
                        .frame(width: 0.5, height: proxy.size.height)
                        .background(theme.fill.secondary)
                        .position(x: frame.marks + cell.width * CGFloat(index), y: proxy.size.height / 2.0)
                }

                ScrollView(.vertical) {
                    ZStack {
                        HourlyLines(x: (proxy.size.width - frame.ph) / 2, step: cell.height, markWidth: frame.marks, theme: theme)
                        
                        ForEach(tiles, id: \.data.id) { tile in
                            TaskTile(task: tile.data, rect: tile.rect)
                                .position(x: tile.rect.minX + tile.rect.width / 2, y: tile.rect.minY + tile.rect.height / 2)
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.trailing, frame.ph)
                    .frame(height: cell.height * 24)
                    .onTapGesture {
                        //
                    }
                }
                .offset(y: frame.plates)
                .frame(height: proxy.size.height - frame.plates)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

fileprivate struct Frame {
    var ph = 16.0
    var pv = 16.0
    var marks = 60.0
    var plates = 68.0
}

fileprivate struct HourlyLines: View {
    var x: CGFloat
    var step: CGFloat
    var markWidth: CGFloat
    var theme: Theme
    
    var body: some View {
        ZStack {
            ForEach(1..<24, id: \.self) { hour in
                HStack(spacing: 0) {
                    Text(hour <= 12 ? "\(hour) AM" : "\(hour - 12) PM")
                        .typography(.caption)
                        .frame(width: markWidth)
                        .multilineTextAlignment(.center)
                    
                    Rectangle()
                        .fill(theme.fill.secondary)
                        .frame(height: 0.5)
                }
                .position(x: x, y: step * CGFloat(hour))
            }
        }
        .frame(maxHeight: .infinity)
    }
}

fileprivate struct DatePlates: View {
    var dates: [Date] = []
    var markWidth: CGFloat
    var theme: Theme

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack {
                Text(Cal.timezone()).typography(.caption)
            }
            .padding(.bottom, 2)
            .frame(width: markWidth)
            
            ForEach(0..<dates.count, id: \.self) { index in
                VStack(alignment: .leading) {
                    let (weekday, day) = format(date: dates[index])
                    
                    Text(weekday).typography(.secondary, size: .h6, weight: .light)

                    Text(day).typography(.h4)
                }
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func format(date: Date) -> (String, String) {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "EEE"
        let weekday = formatter.string(from: date)
        
        formatter.dateFormat = "d"
        let day = formatter.string(from: date)
        
        return (weekday, day)
    }
}

fileprivate struct TaskTile: View {
    let task: Models.Task
    let rect: CGRect
    let color: Color
    
    @State var isEditing = false
    @Environment(\.vars) var vars

    init(task: Models.Task, rect: CGRect, color: Color = .blue) {
        self.task = task
        self.rect = rect
        self.color = Color("theme.system/fill.xx")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(task.title)
                .font(.system(size: 13, weight: .medium))
//                .lineLimit(1)
            
            if let start = task.startAt, let end = task.endAt {
                Text(timeRangeText(start: start, end: end))
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(Color.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(width: rect.width, height: rect.height, alignment: .topLeading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.white, lineWidth: 1)
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue)
                .frame(width: 2)
        }
        .contentShape(Rectangle())
        .onTapGesture { isEditing.toggle() }
        .popover(isPresented: $isEditing) {
            ScrollView {
                TasksOmniTaskEditor(task: task)
            }
            .background(vars.theme.fill.popover.padding(-80))
        }
    }
    
    private func timeRangeText(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct CalendarFrameControl: View {
    @State var frame = Modules.calendar.frame
    @Environment(\.calendar) var calendar

    var body: some View {
        Picker("Frame", selection: $frame) {
            Text("day").tag(Modules.Calendar.Frame.day)
            Text("week").tag(Modules.Calendar.Frame.week)
            Text("month").tag(Modules.Calendar.Frame.month)
        }
        .onChange(of: frame, initial: false) { old, next in
            calendar.view(date: calendar.date, frame: next)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
    }
}

fileprivate struct Coordinator {
    struct Day<T: Span> {
        var day: Date
        var spans: [T]
    }
    
    struct Tile<T: Span> {
        var data: T
        var rect: CGRect
    }
    
    struct Group<T: Span>{
        var spans: [T]
        var start: Date
        var end: Date
    }
    
    func layout<T: Span>(spans: [T], cell: CGSize, frame: Frame, start: Date) -> [Tile<T>] {
        var tiles = [Tile<T>]()
        
        let (_, days) = bydays(spans: spans)
        
        days.forEach { day in
            let sorted = sort(spans: day.spans)
            let groups = isolate(spans: sorted)
            let daydif = Cal.cal.dateComponents([.day], from: start, to: day.day)
            let offset = CGFloat(daydif.day!) * cell.width + frame.marks
            
            groups.forEach { group in
                layoutGroup(group: group, cell: cell, tiles: &tiles, offset: offset)
            }
        }
        
        return tiles
    }

    private func sort<T: Span>(spans: [T]) -> [T] {
        return spans.sorted { a, b in
            if a.startAt! != b.startAt {
                return a.startAt! < b.startAt!
            }
            return a.endAt! > b.endAt!
        }
    }
    
    private func isolate<T: Span>(spans: [T]) -> [Group<T>] {
        var groups = [Group<T>]()
        
        spans.forEach { span in
            if var last = groups.last, last.end > span.startAt! {
                last.spans.append(span)
                last.end = max(last.end, span.endAt!)
                groups[groups.count - 1] = last
                return
            }
            groups.append(.init(spans: [span], start: span.startAt!, end: span.endAt!))
        }
        
        return groups
    }
    
    private func columnize<T: Span>(spans: [T]) -> [[T]]{
        var columns = [[T]]()
        
        spans.forEach { span in
            for col in 0..<columns.count {
                if let last = columns[col].last,
                   !overlaps(a: (last.startAt!, last.endAt!), b: (span.startAt!, span.endAt!)) {
                    columns[col].append(span)
                    return
                }
            }
            columns.append([span])
        }
        
        return columns
    }
    
    private func overlaps(a: (Date, Date), b: (Date, Date)) -> Bool {
        return a.0 < b.1 && a.1 > b.0
    }
    
    private func bydays<T: Span>(spans: [T]) -> (cross: [T], inone: [Day<T>]) {
        var cross = [T]()
        var inone = [Day<T>]()
        
        spans.forEach { span in
            let day = Calendar.current.startOfDay(for: span.startAt!)
            let endDay = Calendar.current.startOfDay(for: span.endAt!)
            
            if day != endDay {
                cross.append(span)
                return
            }
            
            if let index = inone.firstIndex(where: { $0.day == day }) {
                inone[index].spans.append(span)
            } else {
                inone.append(.init(day: day, spans: [span]))
            }
        }
        
        return (cross, inone)
    }
    
    private func layoutGroup<T: Span>(group: Group<T>, cell: CGSize, tiles: inout [Tile<T>], offset: CGFloat) {
        let columns = columnize(spans: group.spans)
        
        // 计算每列的宽度
        let columnWidth = (cell.width - 6) / CGFloat(columns.count)
        
        // 遍历每一列
        for (colIndex, column) in columns.enumerated() {
            // 遍历列中的每个事件
            for span in column {
                // 计算开始时间在一天中的位置
                let startHour = Cal.cal.component(.hour, from: span.startAt!)
                let startMinute = Cal.cal.component(.minute, from: span.startAt!)
                let startY = CGFloat(startHour) * cell.height + (CGFloat(startMinute) / 60.0 * cell.height)
                
                // 计算结束时间在一天中的位置
                let endHour = Cal.cal.component(.hour, from: span.endAt!)
                let endMinute = Cal.cal.component(.minute, from: span.endAt!)
                let endY = CGFloat(endHour) * cell.height + (CGFloat(endMinute) / 60.0 * cell.height)
                
                // 计算高度
                let height = endY - startY
                
                // 创建事件的矩形区域
                let rect = CGRect(
                    x: offset + CGFloat(colIndex) * columnWidth,
                    y: startY,
                    width: columnWidth,
                    height: height
                )
                
                // 添加到 tiles 数组
                tiles.append(Tile(data: span, rect: rect))
            }
        }
    }
}
