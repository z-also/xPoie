import SwiftUI

extension Modules {
    @Observable class Main {
        var scene: Scene = .inbox
        
        // controls the sidebar toggle interaction
        var sidebarWidth = Consts.mainSidebarIdealWidth
        var sidebarResizingWidth = Consts.mainSidebarIdealWidth
        
        var shouldHideSidebarWhenInactive = false
        
        var navigationSplitViewColumnVisibility = NavigationSplitViewVisibility.all
    }
}
