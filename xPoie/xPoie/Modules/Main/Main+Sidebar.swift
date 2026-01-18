import SwiftUI

extension Modules.Main {
    func toggle(sidebar: Bool) {
        let to = self.sidebarWidth > 0 ? 0 : Consts.mainSidebarIdealWidth
        
        withAnimation {
            self.sidebarResizingWidth = to
        } completion: {
            self.sidebarWidth = to
        }
        withAnimation {
            navigationSplitViewColumnVisibility = sidebar ? .automatic : .detailOnly
        }
    }
    
    func sidebar(resize size: CGSize, commit: Bool) {
        var width = sidebarWidth + size.width
        
        if width < Consts.mainSidebarMinWidth * 0.75 {
            width = 0
        } else if width < Consts.mainSidebarMinWidth {
            width = Consts.mainSidebarMinWidth
        } else if width > Consts.mainSidebarMaxWidth {
            width = Consts.mainSidebarMaxWidth
        }

        sidebarResizingWidth = width
        
        if commit {
            sidebarWidth = width
        }
    }
    
    func sidebar(hideWhenInactive: Bool) {
        shouldHideSidebarWhenInactive = hideWhenInactive
    }
}
