import SwiftUI

struct TypewriterCarousel: View {
    let texts: [String]
    var dwellInterval: TimeInterval = 4.0                // 每段文字完整显示后的停留时间（秒）
    var typingInterval: TimeInterval = 0.06              // 每字符间隔（秒），例如 0.06
    var deleteBeforeNext: Bool = true                    // 是否在切换前“删除”旧文字
    var showBlinkingCursor: Bool = true                  // 是否展示光标
    var pauseIntervalAfterDelete: TimeInterval = 1.0     // 删除完成后等待时间（秒）
    
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var isCursorVisible = true
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(displayedText)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.blue.gradient)
            
            + Text(showBlinkingCursor ? "|" : "")
                .font(.system(size: 42, weight: .thin))
                .foregroundStyle(.blue.gradient.opacity(isCursorVisible ? 1 : 0))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            if showBlinkingCursor {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(600))
                    isCursorVisible.toggle()
                }
            }
        }
        .task { await runTypewriterLoop() }
    }
    
    private func runTypewriterLoop() async {
        while !Task.isCancelled {
            let currentText = texts[currentIndex]
            
            displayedText = ""
            
            for char in currentText {
                if Task.isCancelled { return }
                displayedText += String(char)
                try? await Task.sleep(for: .seconds(typingInterval))
            }
            
            try? await Task.sleep(for: .seconds(dwellInterval))
            
            if deleteBeforeNext {
                for _ in currentText {
                    if Task.isCancelled { return }
                    if !displayedText.isEmpty {
                        displayedText.removeLast()
                    }
                    try? await Task.sleep(for: .seconds(typingInterval * 0.4))
                }
                
                try? await Task.sleep(for: .seconds(pauseIntervalAfterDelete))
            } else {
                displayedText = ""
                try? await Task.sleep(for: .milliseconds(300))
            }
            
            currentIndex = (currentIndex + 1) % texts.count
        }
    }
}
