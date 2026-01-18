import AppKit
import SwiftUI

@MainActor class SpotlightScene {
    private var panel: OmniPanel?
    private var observation: Any?
    
    init() {
        let rootView = SpotlightSceneMain()
        let initialSize = CGSize(width: 664, height: 420)
        
        let screenFrame = NSScreen.main?.frame ?? .zero
        let origin = CGPoint(
            x: (screenFrame.width - initialSize.width) / 2,
            y: screenFrame.height - 100 - initialSize.height
        )
        
        let frame = NSRect(origin: origin, size: initialSize)
        
        let panel = OmniPanel(
            content: rootView,
            frame: frame,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView]
        )
        
        panel.hasShadow = false
        
        self.panel = panel
        self.observePinned()
    }
    
    func toggle() {
        panel?.toggle()
    }
    
    func show() {
        panel?.show()
    }
    
    func hide() {
        panel?.hide()
    }
    
    private func observePinned() {
        withObservationTracking {
            _ = Modules.spotlight.pinned
        } onChange: {
            Task { @MainActor in
                self.observePinned()
                if Modules.spotlight.pinned {
                    self.panel?.pin()
                } else {
                    self.panel?.unpin()
                }
            }
        }
    }
    
    deinit {
        panel = nil
    }
}
