import SwiftUI
import Combine

struct FocusTimerView: View {
    let focus: Models.Focus
    @State private var secondsRemaining: Int = 5 * 60 // 默认25分钟
    @State private var timer: AnyCancellable?
    
    let onClose: () -> Void
    
    @State private var hovered = false
    
    @Environment(\.theme) var theme
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.green.opacity(0.2))
                .containerRelativeFrame([.horizontal, .vertical]) { length, axis in
                    axis == .vertical ? length : length * (1 - CGFloat(secondsRemaining) / CGFloat(focus.seconds))
                }

            HStack(spacing: 10) {
                if hovered {
                    ControlButtons(
                        focus: focus,
                        onStart: startTimer,
                        onPause: pauseTimer,
                        onReset: resetTimer,
                    )
                } else {
                    TimerDisplay(seconds: secondsRemaining)
                    
                    Text(focus.title)
                        .font(.system(size: 14))
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(12)
        }
        .frame(width: 260, height: 38)
        .foregroundStyle(theme.text.primary)
        .glassEffect()
        .clipShape(.capsule)
        .onHover{ flag in hovered = flag }
        .task { startTimer() }
    }
    
    private func startTimer() {
        if focus.status == .paused {
            focus.status = .ongoing
            startTimerPublisher()
        } else {
            focus.status = .ongoing
            startTimerPublisher()
        }
        secondsRemaining = focus.seconds
    }
    
    private func pauseTimer() {
        focus.status = .paused
        timer?.cancel()
        timer = nil
    }
    
    private func resetTimer() {
    }
    
    private func startTimerPublisher() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                } else {
                    self.timer?.cancel()
                    self.timer = nil
                    // 这里可以添加完成提示
                }
            }
    }
}

private struct TimerDisplay: View {
    let seconds: Int
    
    @Environment(\.theme) var theme
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: 11, weight: .regular, design: .monospaced))
            .padding(4, 6)
            .background(theme.fill.secondary, in: .capsule)
    }
    
    private var formattedTime: String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

private struct ControlButtons: View {
    let focus: Models.Focus
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onPause) {
                Image(systemName: "pause")
                    .resizable()
                    .frame(width: 12, height: 12)
                Text("Pause")
                    .font(size: .sm)
            }
            .buttonStyle(.omni.with(padding: .md, active: true))
        }
    }
}
