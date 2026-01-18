import AppKit
import SwiftUI

@MainActor class OmniPanel: NSPanel {
    weak var omniDelegate: Delegate?
    private var originalFrame: NSRect?
    private var _isPinned: Bool = false
    private let animationDuration: TimeInterval = 0.2
    private let pinnedWindowLevel: NSWindow.Level = NSWindow.Level(112)

    private let shouldCloseOnResignKey: Bool = true
    private let shouldCloseOnOutsideClick: Bool = true
    private let shouldCloseOnEscape: Bool = true
    
    func isPinned() -> Bool {
        return _isPinned
    }

    @MainActor protocol Delegate: AnyObject {
        func omniPanelDidShow(_ panel: OmniPanel)
        func omniPanelDidHide(_ panel: OmniPanel)
        func omniPanel(_ panel: OmniPanel, didMove frame: CGRect)
    }
    
    init<Content: View>(content: Content, frame: CGRect, styleMask: NSWindow.StyleMask?) {
        super.init(
            contentRect: frame,
            styleMask: styleMask ?? [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        setupWindow()
        updateCloseBehaviors()
        
        let hostingView = NSHostingView(rootView: content)
        self.contentView = hostingView
    }
    
    private func setupWindow() {
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = .clear

        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        self.isFloatingPanel = true
        self.isReleasedWhenClosed = false

        self.isMovable = true
        self.isMovableByWindowBackground = true
        
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
        self.animationBehavior = .default
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        
        self.delegate = self
    }
    
    public func windowWillMove(_ notification: Notification) {
        //
    }
    
    public func windowDidMove(_ notification: Notification) {
        self.omniDelegate?.omniPanel(self, didMove: self.frame)
    }
        
    public func toggle(animated: Bool = true) {
        if self.isVisible {
            hide(animated: animated)
        } else {
            show(animated: animated)
        }
    }
    
    public func show(animated: Bool = true) {
        if animated {
            self.alphaValue = 0
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = animationDuration
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                self.animator().alphaValue = 1
            }) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.omniDelegate?.omniPanelDidShow(self)
                }
            }
        } else {
            self.alphaValue = 1
            self.omniDelegate?.omniPanelDidShow(self)
        }
        
        self.makeKeyAndOrderFront(nil)
    }
    
    public func hide(animated: Bool = true) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().alphaValue = 0
        }) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.parent?.removeChildWindow(self)
                Modules.spotlight.toggle(pin: false)
                Modules.spotlight.toggle(collapse: false)
                self.orderOut(nil)
                self.windowController = nil
                self.omniDelegate?.omniPanelDidHide(self)
            }
        }
    }
    
    public func pin() {
        _isPinned = true
        updateCloseBehaviors()
        self.level = pinnedWindowLevel
    }
    
    public func unpin() {
        _isPinned = false
        updateCloseBehaviors()
        self.level = .normal
    }
    
    private func updateCloseBehaviors() {
        self.level = _isPinned ? pinnedWindowLevel : .floating
    }
    
    public override var canBecomeKey: Bool {
        return true
    }
    
    public override var canBecomeMain: Bool {
        return false
    }
    
    public override func orderOut(_ sender: Any?) {
        if !isPinned() {
            super.orderOut(sender)
        } else {
            self.makeKeyAndOrderFront(nil)
        }
    }
    
    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown && !isKeyWindow && isPinned() {
            self.makeKeyAndOrderFront(nil)
        }
        super.sendEvent(event)
    }
}

extension OmniPanel: NSWindowDelegate {
    public func windowDidResignKey(_ notification: Notification) {
        if !isPinned() && shouldCloseOnResignKey {
            self.hide()
        }
    }
}

extension OmniPanel.Delegate {
    func omniPanelDidShow(_ panel: OmniPanel) {}
    func omniPanelDidHide(_ panel: OmniPanel) {}
    func omniPanel(_ panel: OmniPanel, didMove frame: CGRect) {}
}
