import AppKit
import SwiftUI

class FocusFeatureSession: OmniPanel.Delegate {
    static let shared = FocusFeatureSession()
    
    private var activePanel: OmniPanel?
    
    func start(focus: Models.Focus) {
        present(focus: focus)
    }
    
    func present(focus: Models.Focus) {
        let timerView = FocusTimerView(focus: focus, onClose: dismiss)
        
        // 创建OmniPanel
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1024, height: 768)
        let panelWidth: CGFloat = 260
        let panelHeight: CGFloat = 38
        let panelFrame = CGRect(
            x: (screenSize.width - panelWidth) / 2,
            y: (screenSize.height - panelHeight) / 2,
            width: panelWidth,
            height: panelHeight
        )
        
        let panel = OmniPanel(
            content: timerView,
            frame: panelFrame,
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView]
        )
        
        // 配置面板
        panel.hasShadow = true
        panel.makeKeyAndOrderFront(nil)
        
        // 存储面板引用到全局管理器
        addPanel(panel)
    }
    
    private func dismiss() {
        closeCurrentPanel()
    }
    
    func addPanel(_ panel: OmniPanel) {
        closeCurrentPanel()
        activePanel = panel
        panel.omniDelegate = self
        panel.pin()
    }
    
    func closeCurrentPanel() {
        if let panel = activePanel {
            panel.hide()
            panel.orderOut(nil)
            activePanel = nil
        }
    }
    
    func omniPanelDidHide(_ panel: OmniPanel) {
        if activePanel === panel {
            activePanel = nil
        }
    }
}
