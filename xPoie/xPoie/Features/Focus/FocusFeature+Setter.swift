import SwiftUI
import AppKit

struct FocusFeatureSetter: View {
    @State var progress: CGFloat = 0.5
    
    @State var content: String = ""
    
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "60.arrow.trianglehead.counterclockwise")
                .resizable()
                .frame(width: 18, height: 20)
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's your main focus at this moment?")
                        .font(size: .h4)
                    
                    Spacer()
                    
                    TextField("do a research for agent...", text: $content)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16))
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(theme.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
                    
                    FooterControl(onStart: createFocusTimerPanel)
                }
                .foregroundStyle(
                    LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

                Spacer()
                
                ClockRing(progress: progress, trackColor: theme.fill.track, tick: onProgress)
            }
        }
        .padding(16)
        .background(theme.fill.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func onProgress(value: CGFloat) {
        progress = value
    }
    
    private func createFocusTimerPanel() {
        let focus: Models.Focus = .init(
            title: content, seconds: Int(progress * 60 * 60)
        )
        
        FocusFeatureSession.shared.start(focus: focus)
    }
}

fileprivate struct FooterControl: View {
    let onStart: () -> Void
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .frame(width: 10, height: 12)
            }
            .buttonStyle(.omni)
            
            Button(action: onStart) {
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 10, height: 12)
                
                Text("Start now")
            }
            .buttonStyle(.omni.with(visual: .solidGreen, padding: .lg))
            
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 10, height: 12)
            }
            .buttonStyle(.omni)
            Spacer()
        }
    }
}
