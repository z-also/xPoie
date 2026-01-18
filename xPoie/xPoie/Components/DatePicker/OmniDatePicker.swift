import AppKit
import SwiftUI

struct OmniDatePicker: View {
    var value: [Date]
    var onCancel: () -> Void
    var onConfirm: ([Date]) -> Void

    @State private var editing: [Date?]
    @State private var calMode: OmniCalendar.Mode
    @State private var endMode: EndDateTimeControl.Mode = .duration
    @Environment(\.theme) var theme

    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm"
        return formatter
    }
    
    private var canConfirm: Bool {
        if editing.count > 1 {
            guard let start = editing[0], let end = editing[1] else { return false }
            return end >= start
        } else {
            return editing.first ?? nil != nil
        }
    }

    init(value: [Date?] = [], onCancel: @escaping () -> Void, onConfirm: @escaping ([Date]) -> Void) {
        self.value = value.compactMap { $0 }
        self._editing = State(initialValue: value)
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self.calMode = value.count == 1 ? .single : .start
    }

    var body: some View {
        VStack(spacing: 16) {
            OmniCalendar(
                mode: endMode == .end ? calMode : .single,
                selection: endMode == .end ? editing : [editing.first!],
                onSelect: onSelectDate
            )
            
            if editing.count > 1 {
                VStack(spacing: 8) {
                    StartDateTimeControl(
                        value: editing[0],
                        isActive: calMode == .start,
                        onSelect: { onSelectTime(date: $0, mode: .start) },
                        focus: { calMode = .start }
                    )

                    EndDateTimeControl(
                        start: editing[0],
                        value: editing[1],
                        mode: endMode,
                        isActive: calMode == .end,
                        onSelect: { onSelectTime(date: $0, mode: .end) },
                        onFocus: {
                            calMode = .end
                        },
                        onLabelAction: {
                            if calMode != .end {
                                calMode = .end
                            } else {
                                endMode = endMode == .end ? .duration : .end
                            }
                        }
                    )
                }
            } else {
                HStack {
                    Text("Time")
                        .font(.system(size: 14))
                        .foregroundColor(theme.text.secondary)

                    Spacer()

                    TimeSelect(date: editing.first! ?? .now, onChange: { onSelectTime(date: $0, mode: .single) })
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.omni.with(visual: .cancelBtn, padding: .lg))
                
                Button(action: handleConfirm) {
                    Text("Confirm")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.omni.with(visual: .primaryBtn, padding: .lg))
                .disabled(!canConfirm)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 300, alignment: .top)
    }
    
    func onSelectDate(_ date: Date) {
        let now = Date()
        let cal = Calendar.current
        if endMode == .duration && calMode == .end {
            calMode = .start
        }
        
        let cur = editing[calMode == .end ? 1 : 0]
        
        var hour = cal.component(.hour, from: cur ?? now)
        var minute = cal.component(.minute, from: cur ?? now)
        
        if cur == nil {
            if minute < 30 {
                minute = 30
            } else {
                hour = (hour + 1) % 24
                minute = 0
            }
        }
        
        let d = cal.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
        set(date: d, mode: calMode)
    }
    
    func set(date: Date, mode: OmniCalendar.Mode) {
        let cal = Calendar.current
        editing[mode == .end ? 1 : 0] = date

        if mode == .start, editing[1] == nil || editing[1]! <= date {
            editing[1] = cal.date(byAdding: .hour, value: 1, to: date)
        }

        if mode == .end, editing[0] != nil && editing[0]! >= date {
            editing[0] = cal.date(byAdding: .hour, value: -1, to: date)
        }
    }

    func onSelectTime(date: Date, mode: OmniCalendar.Mode) {
        set(date: date, mode: mode)
    }
    
    func handleConfirm() {
        onConfirm(editing.compactMap { $0 })
    }
}

struct OmniDatePickerPresenter: View {
    var dates: [Date]
    var trigger: () -> Void
    var reset: () -> Void
    @Environment(\.theme) var theme

    var body: some View {
        Button(action: trigger) {
            HStack {
                Spacer()
                
                Button(action: reset) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(theme.text.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Start selector with built-in label
fileprivate struct StartDateTimeControl: View {
    let value: Date?
    let isActive: Bool
    let onSelect: (Date) -> Void
    let focus: () -> Void
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Start:")
                .font(.system(size: 12))
            
            Spacer()
            
            if let value = value {
                Text(value.formatted(.dateTime.day().month().year()))
                    .font(.system(size: 12))
                TimeSelect(date: value, onChange: onSelect)
            } else {
                Text(isActive ? "Pick a date above" : "No date selected")
                    .foregroundStyle(theme.text.secondary)
                    .padding(4, 0)
            }
        }
        .contentShape(Rectangle())
        .modifier(OmniStyle.omni.with(visual: .field, padding: .md, active: isActive))
        .onTapGesture { focus() }
    }
}

fileprivate struct EndDateTimeControl: View {
    enum Mode { case duration, end }

    let start: Date?
    let value: Date?
    let mode: Mode
    let isActive: Bool
    let onSelect: (Date) -> Void
    let onFocus: () -> Void
    let onLabelAction: () -> Void

    @Environment(\.theme) var theme

    // Precomputed 30m steps up to 6h
    private static let durationOptions: [Option<String, Int>] = {
        (1...12).map { i in
            let mins = i * 30
            return Option(id: Self.formatDuration(mins), value: mins)
        }
    }()

    private static func formatDuration(_ minutes: Int) -> String {
        guard minutes > 0 else { return "0m" }
        let d = minutes / 1440
        let remAfterDays = minutes % 1440
        let h = remAfterDays / 60
        let m = remAfterDays % 60

        var parts: [String] = []
        if d > 0 { parts.append("\(d)d") }
        if h > 0 { parts.append("\(h)h") }
        if m > 0 { parts.append("\(m)m") }
        return parts.joined(separator: " ")
    }
    
    private var computedDuration: Int {
        guard let s = start, let e = value else { return 60 }
        let mins = max(0, Int(e.timeIntervalSince(s) / 60))
        let snapped = max(30, min(360, (mins / 30) * 30))
        return snapped
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onLabelAction) {
                HStack(spacing: 4) {
                    Text(mode == .end ? "End:" : "Duration:")
                        .font(.system(size: 12))
                    Image(systemName: "arrow.left.arrow.right")
                        .resizable()
                        .frame(width: 8, height: 8)
                        .foregroundStyle(theme.text.secondary)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            if mode == .duration {
                OmniSelect(
                    value: [Option(id: EndDateTimeControl.formatDuration(computedDuration), value: computedDuration)],
                    options: EndDateTimeControl.durationOptions,
                    presenter: {
                        OmniSelectPresenter(value: $0, active: $1, toggle: $2, style: .omni.with(visual: .plain)) { val, __ in
                            Text(val.first?.id ?? EndDateTimeControl.formatDuration(computedDuration))
                                .font(.system(size: 12))
                                .fixedSize()
                        }
                    },
                    option: { option, active, toggle in
                        OmniSelectOption(
                            value: option,
                            active: active,
                            action: { opt in
                                toggle()
                                if let start = start {
                                    if let newEnd = Calendar.current.date(byAdding: .minute, value: opt.value, to: start) {
                                        onSelect(newEnd)
                                    }
                                }
                            },
                            render: { opt, _ in
                                Text(opt.id)
                            }
                        )
                    }
                )
            } else {
                if let value = value {
                    Text(value.formatted(.dateTime.day().month().year()))
                        .font(.system(size: 12))
                    TimeSelect(date: value, onChange: onSelect)
                } else {
                    Text(isActive ? "Pick a date above" : "No date selected")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.text.secondary)
                        .padding(4, 0)
                }
            }
        }
        .contentShape(Rectangle())
        .modifier(OmniStyle.omni.with(visual: .field, padding: .md, active: isActive))
        .onTapGesture { onFocus() }
    }
}

fileprivate struct TimeSelect: View {
    let date: Date
    let onChange: (Date) -> Void

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    private var timeSlots: [Option<String, Int>] {
        var slots: [Option<String, Int>] = []
        
        for minutes in stride(from: 0, to: 1440, by: 30) {
            let hour = minutes / 60
            let minute = minutes % 60
            let timeString = String(format: "%02d:%02d", hour, minute)
            slots.append(Option(id: timeString, value: minutes))
        }
        
        return slots
    }

    private var selectedTimeSlot: Option<String, Int> {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        // 找到最接近的30分钟间隔
        let roundedMinute = (minute / 30) * 30
        // 计算总分钟数
        let totalMinutes = hour * 60 + roundedMinute
        
        // 从timeSlots中找到匹配的选项
        if let slot = timeSlots.first(where: { $0.value == totalMinutes }) {
            return slot
        }
        
        // 如果没找到匹配项（理论上不会发生），创建一个新的
        let timeString = String(format: "%02d:%02d", hour, roundedMinute)
        return Option(id: timeString, value: totalMinutes)
    }

    var body: some View {
        OmniSelect(
            value: [selectedTimeSlot],
            options: timeSlots,
            presenter: {
                TimeInlinePresenter(date: date, toggle: $2) { h24, m in
                    let calendar = Calendar.current
                    let baseDate = calendar.startOfDay(for: date)
                    if let newDate = calendar.date(bySettingHour: h24, minute: m, second: 0, of: baseDate) {
                        onChange(newDate)
                    }
                }
            },
            option: { option, active, toggle in
                OmniSelectOption(
                    value: option,
                    active: active,
                    action: { option in
                        toggle()
                        // 根据选中的分钟偏移量设置日期
                        let calendar = Calendar.current
                        let baseDate = calendar.startOfDay(for: date)
                        let hour = option.value / 60
                        let minute = option.value % 60
                        if let newDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate) {
                            onChange(newDate)
                        }
                    },
                    render: { option, _ in
                        Text(option.id)
                    }
                )
            }
        )
    }
}

// MARK: Inline, segmented time presenter (Hour • Minute • AM/PM)
fileprivate struct TimeInlinePresenter: View {
    enum Segment { case hour, minute, ampm }
    
    var date: Date // initial value source
    var toggle: () -> Void // open dropdown
    var onChange: (Int, Int) -> Void // 24h hour, minute
    
    @State private var hour: Int = 9 // 1-12 display
    @State private var minute: Int = 0 // 0-59
    @State private var isPM: Bool = false
    @State private var focus: Segment = .hour
    @Environment(\.theme) var theme

    // typing buffers to support two-digit entry
    @State private var hourBuf: String = ""
    @State private var minuteBuf: String = ""

    init(date: Date, toggle: @escaping () -> Void, onChange: @escaping (Int, Int) -> Void) {
        self.date = date
        self.toggle = toggle
        self.onChange = onChange
        // Seed hour/minute/AMPM directly from date
        let cal = Calendar.current
        let h = cal.component(.hour, from: date)
        let m = cal.component(.minute, from: date)
        let isPMSeed = h >= 12
        let h12 = ((h + 11) % 12) + 1
        self._hour = State(initialValue: h12)
        self._minute = State(initialValue: min(max(m, 0), 59))
        self._isPM = State(initialValue: isPMSeed)
    }

    var body: some View {
        HStack(spacing: 1) {
            TimeSegment(
                text: String(format: "%02d", hour),
                focused: focus == .hour,
                onTap: { focus = .hour },
                onKey: handleHourKey
            )

            Text(":").font(.system(.body, design: .monospaced)).fixedSize()

            TimeSegment(
                text: String(format: "%02d", minute),
                focused: focus == .minute,
                onTap: { focus = .minute },
                onKey: handleMinuteKey
            )

            TimeSegment(
                text: isPM ? "PM" : "AM",
                focused: focus == .ampm,
                onTap: { focus = .ampm },
                onKey: handleAmPmKey
            )

            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundStyle(theme.text.secondary)
                .padding(2)
                .contentShape(Rectangle())
        }
        .font(.system(.body, design: .monospaced))
    }

    private func commit() {
        var h24 = hour % 12
        if isPM { h24 += 12 }
        onChange(h24, minute)
    }

    private func handleHourKey(_ k: KeyEvent) {
        switch k.kind {
        case .digit(let d):
            hourBuf.append(d)
            hourBuf = String(hourBuf.suffix(2))
            var v = Int(hourBuf) ?? hour
            v = min(max(v, 1), 12)
            hour = v
            if hourBuf.count >= 2 { hourBuf.removeAll(); focus = .minute }
            commit()
        case .up: hour = hour == 12 ? 1 : hour + 1; commit()
        case .down: hour = hour == 1 ? 12 : hour - 1; commit()
        case .left: focus = .ampm
        case .right: focus = .minute
        case .enter: commit()
        default: break
        }
    }

    private func handleMinuteKey(_ k: KeyEvent) {
        switch k.kind {
        case .digit(let d):
            minuteBuf.append(d)
            minuteBuf = String(minuteBuf.suffix(2))
            var v = Int(minuteBuf) ?? minute
            v = min(max(v, 0), 59)
            minute = v
            if minuteBuf.count >= 2 { minuteBuf.removeAll(); focus = .ampm }
            commit()
        case .up: minute = (minute + 1) % 60; commit()
        case .down: minute = (minute + 59) % 60; commit()
        case .left: focus = .hour
        case .right: focus = .ampm
        case .enter: commit()
        default: break
        }
    }

    private func handleAmPmKey(_ k: KeyEvent) {
        switch k.kind {
        case .digit(_): break
        case .char(let c):
            let lower = Character(c.lowercased())
            if lower == "a" { isPM = false }
            if lower == "p" { isPM = true }
            commit()
        case .up, .down: isPM.toggle(); commit()
        case .left: focus = .minute
        case .right: focus = .hour
        case .enter: commit()
        }
    }
}

fileprivate struct TimeSegment: View {
    var text: String
    var focused: Bool
    var onTap: () -> Void
    var onKey: (KeyEvent) -> Void
    @Environment(\.theme) var theme

    var body: some View {
        Text(text)
            .font(size: .sm)
            .padding(1)
            .frame(width: 22)
            .background(focused ? theme.semantic.brand.opacity(0.15) : .clear)
            .cornerRadius(4)
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
            .background(KeyCaptureView(isActive: focused, onKey: onKey))
    }
}

fileprivate struct KeyEvent {
    enum Kind {
        case digit(Character),
             char(String),
             up,
             down,
             left,
             right,
             enter
    }
    let kind: Kind
}

fileprivate struct KeyCaptureView: NSViewRepresentable {
    var isActive: Bool
    var onKey: (KeyEvent) -> Void

    func makeNSView(context: Context) -> NSView {
        let v = KeyView()
        v.onKey = onKey
        return v
    }
    func updateNSView(_ nsView: NSView, context: Context) {
        if isActive, nsView.window != nil { nsView.window?.makeFirstResponder(nsView) }
    }

    final class KeyView: NSView {
        var onKey: ((KeyEvent) -> Void)?
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            if let chars = event.charactersIgnoringModifiers, let first = chars.first {
                if first.isNumber {
                    onKey?(.init(kind: .digit(first)))
                    return
                }
                switch first {
                case Character(UnicodeScalar(NSUpArrowFunctionKey)!): onKey?(.init(kind: .up))
                case Character(UnicodeScalar(NSDownArrowFunctionKey)!): onKey?(.init(kind: .down))
                case Character(UnicodeScalar(NSLeftArrowFunctionKey)!): onKey?(.init(kind: .left))
                case Character(UnicodeScalar(NSRightArrowFunctionKey)!): onKey?(.init(kind: .right))
                case "\r", "\n": onKey?(.init(kind: .enter))
                default: onKey?(.init(kind: .char(String(first))))
                }
            }
        }
    }
}
