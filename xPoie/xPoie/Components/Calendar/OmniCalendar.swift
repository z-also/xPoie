import SwiftUI

struct OmniCalendar: View {
    enum Mode {
        // 区间选择的开始
        case start
        // 区间选择的结束
        case end
        // 单选
        case single
    }
    
    enum Status {
        // 没选中
        case none
        // 区间选择的中间
        case range
        // 单个选中
        case selected
        // 今天
        case today
    }
    
    // 单个日期的数据和状态
    typealias Cel = (date: Date, status: Status, hover: Status)
   
    // 一个星期的日期数据和状态
    typealias Row = (cels: [Cel], selected: (Int?, Int?), hover: (Int?, Int?))

    let mode: Mode
    let selection: [Date?]
    
    var onNav: ((Date) -> Void)?
    var onSelect: (Date) -> Void
    
    @State var grid: [[Cal.D]]
    @State var viewing: Date
    @State var hovering: Date?
    
    @Environment(\.theme) var theme

    init(mode: Mode, selection: [Date?], onSelect: @escaping (Date) -> Void, onNav: ((Date) -> Void)? = nil) {
        self.mode = mode
        self.selection = selection
        self.onSelect = onSelect
        self.onNav = onNav
        
        let v = selection[0] ?? .now
        _viewing = State(initialValue: v)
        self.grid = Cal.view(month: v)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Navbar(
                date: viewing,
                onPrev: onPrev,
                onNext: onNext,
                onToday: onToday,
                onSelectYear: onSelectYear,
                onSelectMonth: onSelectMonth
            )

            WeekdaysBar(symbols: Cal.veryShortWeekdaySymbols)
                .foregroundColor(theme.text.secondary)

            ForEach(0..<grid.count, id: \.self) { row in
                let (cels, selected, hover) = computeRow(ds: grid[row])
                
                HStack(spacing: 0) {
                    ForEach(0..<cels.count, id: \.self) { col in
                        DateCell(date: cels[col].date, status: cels[col].status, onSelect: onSelect)
                            .padding(2)
                            .onHover{ hovering = $0 ? cels[col].date : nil }
                    }
                }
                .background(RangeBackground(from: hover.0, to: hover.1).fill(theme.fill.vivid0))
                .background(RangeBackground(from: selected.0, to: selected.1).fill(theme.fill.vivid0).opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func onPrev() {
        set(viewing: Cal.shift(.month, from: viewing, by: -1))
        onNav?(viewing)  // 触发导航回调
    }
    
    private func onNext() {
        set(viewing: Cal.shift(.month, from: viewing, by: 1))
        onNav?(viewing)  // 触发导航回调
    }
    
    private func onToday() {
        set(viewing: Cal.today)
    }
    
    private func set(viewing: Date) {
        self.viewing = viewing
        grid = Cal.view(month: viewing)
    }
    
    private func cellStatus(_ date: Date) -> Cel {
        if mode == .single {
            let cmp = Cal.compare(a: selection[0], b: date)
            return (date, cmp == .sameDay ? .selected : .none, .none)
        }
        
        var res: Cel = (date, .none, .none)
        
        let start = Cal.compare(a: selection[0], b: date)
        let end = Cal.compare(a: selection[1], b: date)
        
        if start == .sameDay || end == .sameDay {
            res.status = .selected
        } else if start == .dayBefore && end == .dayAfter {
            res.status = .range
        }
        
        if let h = hovering, let hover = Cal.compare(a: h, b: date) {
            if mode == .end {
                if (start == .sameDay || start == .dayBefore) && (hover == .sameDay || hover == .dayAfter) {
                    res.hover = .range
                }
            } else {
                if (hover == .sameDay || hover == .dayBefore) && (end == .sameDay || end == .dayAfter) {
                    res.hover = .range
                }
            }
        }
        
        if res.status == .none && res.hover == .none {
            if Cal.compare(a: res.date, b: Date.now) == .sameDay {
                res.status = .today
            }
        }
        
        return res
    }
    
    private func computeRow(ds: [Cal.D]) -> Row {
        let cels = ds.map { d in cellStatus(d.date) }
        
        let idx0 = cels.firstIndex { $0.status == .selected || $0.status == .range }
        let idx1 = cels.lastIndex { $0.status == .selected || $0.status == .range }
        
        let idx2 = cels.firstIndex { $0.hover == .range }
        let idx3 = cels.lastIndex { $0.hover == .range }

        return (cels: cels, selected: (idx0, idx1), hover: (idx2, idx3))
    }
    
    func onSelectYear(year: Int) {
        if let newDate = Calendar.current.date(from: DateComponents(year: year, month: Calendar.current.component(.month, from: viewing))) {
            set(viewing: newDate)
            onNav?(viewing)
        }
    }
    
    func onSelectMonth(month: Int) {
        if let newDate = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: viewing), month: month)) {
            set(viewing: newDate)
            onNav?(viewing)
        }
    }
}

private struct DateCell: View {
    let date: Date
    let status: OmniCalendar.Status
    let onSelect: (Date) -> Void
    
    func handleClick() {
        onSelect(date)
    }

    var body: some View {
        Button(action: handleClick) {
            VStack {
                Text("\(date, formatter: Cal.formatter("d"))")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .contentShape(Rectangle())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 26, alignment: .center)
        }
        .buttonStyle(.omni.with(visual: status == .today ? .link : nil, active: status == .selected))
    }
}

fileprivate struct NavSelect: View {
    var value: Option<Int, Int>
    var options: [Option<Int, Int>]
    var onSelect: (Int) -> Void
    
    var body: some View {
        OmniSelect(
            value: [value],
            options: options,
            presenter: {
                OmniSelectPresenter(value: $0, active: $1, toggle: $2) { val, __ in
                    Text(String(val.first!.value))
                        .fixedSize(horizontal: true, vertical: false)
                }
            },
            option: { option, active, toggle in
                OmniSelectOption(
                    value: option,
                    active: active,
                    action: { option in
                        toggle()
                        onSelect(option.value)
                    },
                    render: { option, _ in
                        Text(String(option.value))
                    }
                )
            }
        )
    }
}

fileprivate struct Navbar: View {
    var date: Date
    var onPrev: () -> Void
    var onNext: () -> Void
    var onToday: () -> Void
    var onSelectYear: (Int) -> Void
    var onSelectMonth: (Int) -> Void
    
    private var year: Option<Int, Int> {
        let year = Calendar.current.component(.year, from: date)
        return .init(id: year, value: year)
    }
    
    private var years: [Option<Int, Int>] {
        let currentYear = Calendar.current.component(.year, from: date)
        return Array(currentYear-5...currentYear+6).map { Option(id: $0, value: $0) }
    }
    
    private var month: Option<Int, Int> {
        let month = Calendar.current.component(.month, from: date)
        return .init(id: month, value: month)
    }

    private var months: [Option<Int, Int>] {
        (1...12).map { Option(id: $0, value: $0) }
    }

    var body: some View {
        HStack(spacing: 4) {
            NavSelect(value: year, options: years, onSelect: onSelectYear)
            NavSelect(value: month, options: months, onSelect: onSelectMonth)
            
            Spacer()

            makeBtn(icon: "chevron.left", action: onPrev)
            Text("Today").font(size: .sm, weight: .medium).onTapGesture{ onToday() }
            makeBtn(icon: "chevron.right", action: onNext)
        }
    }
    
    func makeBtn(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 6, height: 10)
                .padding(0, 6)
        }
        .buttonStyle(.omni.with(padding: .icon))
    }
}

fileprivate struct WeekdaysBar: View {
    let symbols: [String]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(symbols, id: \.self) {
                Text($0)
                    .font(.caption2.bold())
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 28)
    }
}

fileprivate struct RangeBackground: Shape {
    let from: Int?
    let to: Int?
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if let start = from, let to = to {
            let gap = 2.0
            let cell = rect.width / 7
            
            let x0 = CGFloat(start) * cell + gap
            let x1 = CGFloat(to + 1) * cell - gap
            
            let r = CGRect(x: x0, y: gap, width: x1 - x0, height: rect.height - gap * 2)
            
            path.addRoundedRect(in: r, cornerSize: CGSize(width: 6, height: 6))
        }
        
        return path
    }
}
