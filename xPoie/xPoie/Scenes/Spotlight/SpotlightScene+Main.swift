import AppKit
import SwiftUI

struct SpotlightSceneMain: View {
    @State var width: CGFloat = 600
    
    @Namespace private var namespace
    @Environment(\.theme) private var theme
    @Environment(\.spotlight) private var spotlight

    var body: some View {
        VStack(spacing: 16) {
            SpotlightDock()
                .frame(width: width)
            
            if !spotlight.collapsed {
                VStack {
                    if spotlight.scene == .ai {
                        SpotlightAi()
                    }
                    if spotlight.scene == .tasks {
                        SpotlightTasks()
                    }
                    if spotlight.scene == .notes {
                        SpotlightNotes()
                    }
                    if spotlight.scene == .search {
                        SpotlightSearch()
                    }
                }
                .glassEffect(.regular, in: .rect(cornerRadius: 16.0))
                
                //                    .contentShape(Rectangle())
                //                    .background(.thinMaterial, in: .rect(cornerRadius: 16.0))
                //                    .transition(.scale.combined(with: .opacity))
                //                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 0)
                //                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            Spacer()
        }
        .frame(alignment: .top)
        .environment(\.theme, theme)
        .padding(32)
        .edgesIgnoringSafeArea(.all)
    }
}

// 透明的背景视图，用于支持窗口拖动
struct DraggableBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> DraggableNSView {
        return DraggableNSView()
    }
    
    func updateNSView(_ nsView: DraggableNSView, context: Context) {
        // 不需要更新
    }
}

// 自定义 NSView，支持窗口拖动
class DraggableNSView: NSView {
    override var mouseDownCanMoveWindow: Bool {
        return false
    }
}

