//import SwiftUI
//import AppKit
//
//enum OmniPopoverPlacement {
//    case bottom
//    case right
//    case top
//}
//
//struct OmniPopover<Content: View>: View {
//    @Binding var isPresented: Bool
//    let placement: OmniPopoverPlacement
//    let content: () -> Content
//
//    @State private var anchorFrame: CGRect = .zero
//    @State private var popoverController: OmniPopoverController?
//    @State private var anchorView: NSView? // 添加一个状态变量来保存视图引用
//
//    var body: some View {
//        GeometryReader { geometry in
//            EmptyView()
//                .onChange(of: isPresented) { oldValue, newValue in
//                    anchorFrame = geometry.frame(in: .global)
//                    if newValue {
//                        showPopover()
//                    } else {
//                        hidePopover()
//                    }
//                }
//        }
//    }
//    
//    private func showPopover() {
//        let controller = OmniPopoverController(isPresented: $isPresented)
//        self.popoverController = controller
//        
//        let view = anchorFrame.toNSView(existingView: anchorView)
//        self.anchorView = view
//        
//        guard let view = view else { return }
//        
//        controller.show(
//            content: AnyView(content()),
//            relativeTo: view.bounds,
//            of: view,
//            preferredEdge: getPreferredEdge()
//        )
//    }
//    
//    private func hidePopover() {
//        popoverController?.popover.close()
//        popoverController = nil
//        
//        // 移除临时视图
//        anchorView?.removeFromSuperview()
//        anchorView = nil
//    }
//    
//    private func getPreferredEdge() -> NSRectEdge {
//        switch placement {
//        case .bottom:
//            return .minY
//        case .right:
//            return .maxX
//        case .top:
//            return .maxY
//        }
//    }
//}
//
//// NSPopover 包装器
//class OmniPopoverController: NSObject, NSPopoverDelegate {
//    var popover: NSPopover
//    var isPresented: Binding<Bool>
//    
//    init(isPresented: Binding<Bool>) {
//        self.popover = NSPopover()
//        self.isPresented = isPresented
//        super.init()
//        
//        self.popover.behavior = .transient
//        self.popover.animates = true // 启用动画
//        self.popover.delegate = self
//        
//        self.popover.appearance = NSAppearance(named: .aqua)
//        self.popover.setValue(false, forKeyPath: "shouldHideAnchor")
//        
//        if let effectView = self.popover.contentViewController?.view.superview?.subviews.first(where: { $0 is NSVisualEffectView }) {
//            effectView.wantsLayer = true
//            effectView.layer?.cornerRadius = 12
//            effectView.layer?.masksToBounds = true
//        }
//    }
//    
//    func show<Content: View>(content: Content, relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
//        let positioningView0 = NSView()
//        positioningView0.frame = positioningView.frame
//        positioningView.superview?.addSubview(positioningView0, positioned: .below, relativeTo: positioningView)
//        
//        let controller = NSHostingController(rootView: content)
//        self.popover.contentViewController = controller
//        
//        // 设置初始透明度
//        self.popover.contentViewController?.view.alphaValue = 0
//        
//        // 显示 popover
//        self.popover.show(relativeTo: .zero, of: positioningView0, preferredEdge: preferredEdge)
//        
//        // 获取 popover 视图
//        if let popoverView = self.popover.contentViewController?.view {
//            // 设置初始位置（向上偏移20像素）
//            let originalFrame = popoverView.frame
//            popoverView.frame = NSRect(
//                x: originalFrame.origin.x,
//                y: originalFrame.origin.y - 20,
//                width: originalFrame.width,
//                height: originalFrame.height
//            )
//            
//            // 添加动画
//            NSAnimationContext.runAnimationGroup({ context in
//                context.duration = 0.25
//                context.allowsImplicitAnimation = true
//                
//                // 透明度动画
//                popoverView.animator().alphaValue = 1
//                
//                // 位置动画
//                popoverView.animator().frame = originalFrame
//            })
//        }
//        
//        // 计算屏幕边界外的位置
//        guard let screen = positioningView.window?.screen ?? NSScreen.main else { return }
//        let screenFrame = screen.frame
//        
//        // 将定位视图移动到屏幕可见区域之外
//        let offset = -max(screenFrame.height, screenFrame.width)
//        positioningView0.frame = NSMakeRect(offset, offset, 1, 1)
//    }
//    
//    func popoverDidClose(_ notification: Notification) {
//        isPresented.wrappedValue = false
//    }
//}
//
//extension View {
//    func omniPopover<Content: View>(
//        isPresented: Binding<Bool>,
//        placement: OmniPopoverPlacement = .bottom,
//        @ViewBuilder content: @escaping () -> Content
//    ) -> some View {
//        background(
//            OmniPopover(isPresented: isPresented, placement: placement, content: content)
//        )
//    }
//}
//
//// Helper extension
//private extension CGRect {
//    func toNSView(existingView: NSView? = nil) -> NSView? {
//        let window = NSApplication.shared.windows.first { $0.isKeyWindow }
//        guard let contentView = window?.contentView else { return nil }
//        
//        let rect = NSRect(x: self.minX, y: self.minY,
//                         width: self.width, height: self.height)
//        
//        if let existingView = existingView {
//            existingView.frame = rect
//            return existingView
//        }
//        
//        let view = NSView(frame: rect)
//        view.wantsLayer = true
////        view.layer?.backgroundColor = NSColor.red.cgColor
//        contentView.addSubview(view)
//        return view
//    }
//}
//
