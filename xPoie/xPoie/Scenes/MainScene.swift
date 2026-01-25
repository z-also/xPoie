import AppKit
import SwiftUI

struct MainScene: View {
    @Environment(\.input) var input

    var body: some View {
        Platform()
        .onTapGesture {
            input.focus = .none
        }
        .toolbar(removing: .title)
        .frame(minWidth: 500, idealWidth: 1200, minHeight: 600, idealHeight: 800)
    }
}

fileprivate struct Platform: View {
    @Environment(\.main) var main
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(scene: main.scene)
                .navigationSplitViewColumnWidth(
                    min: Consts.mainSidebarMinWidth,
                    ideal: Consts.mainSidebarIdealWidth,
                    max: Consts.mainSidebarMaxWidth
                )
        } detail: {
            Detail(scene: main.scene)
        }
        .onAppear {
            columnVisibility = main.navigationSplitViewColumnVisibility
        }
        .onChange(of: main.navigationSplitViewColumnVisibility) { old, newValue in
            withAnimation {
                columnVisibility = newValue
            }
        }
        .onChange(of: columnVisibility) { old, newValue in
            if newValue != main.navigationSplitViewColumnVisibility {
                withAnimation {
                    main.navigationSplitViewColumnVisibility = newValue
                }
            }
        }
    }
}

fileprivate struct Custom: View {
    @Environment(\.main) var main
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                Sidebar(scene: main.scene)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .frame(width: max(main.sidebarResizingWidth, Consts.mainSidebarMinWidth))
                    .frame(width: main.sidebarResizingWidth, alignment: .topLeading)
                    .clipped()
                    .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    .padding(12)
                Detail(scene: main.scene)
            }
            .contentShape(Rectangle())

            ResizeToggle { diff, commit in
                main.sidebar(resize: diff, commit: commit)
            }
            .offset(x: max(0, main.sidebarWidth - 10))
        }
        .edgesIgnoringSafeArea(.all)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Label("Toggle", systemImage: "sidebar.left")
                }
            }
        }
    }
    
    func toggleSidebar() {
        main.toggle(sidebar: true)
        main.sidebar(hideWhenInactive: false)
    }
}

fileprivate struct Sidebar: View {
    let scene: Modules.Main.Scene
    
    var body: some View {
        if scene == .projects || scene == .inbox {
            ProjectsSceneSidebar()
        } else if scene == .settings {
            SettingsSceneSidebar()
        } else if scene == .calendar {
            CalendarSceneSidebar()
        }
    }
}

fileprivate struct Detail: View {
    let scene: Modules.Main.Scene
    
    @Environment(\.glim) private var glim
    
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack {
            switch scene {
            case .home:
                HomeSceneMain()
            case .inbox:
                InboxSceneMain()
            case .calendar:
                CalendarSceneMain()
                    .toolbar {
                        ToolbarItemGroup(placement: .principal) {
                            MainNavigator()
                        }
                    }
            case .projects:
                ProjectsSceneMain()
            case .settings:
                SettingsSceneMain()
            }
            
            GlimFeature_Assistant()
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                .matchedGeometryEffect(
                    id: "glimContent",
                    in: animationNamespace,
                    isSource: false
//                    properties: .frame,
//                    anchor: .topLeading
                )
                .transition(.identity)               // important: no extra fade/scale
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .opacity(glim.presentation == .inapp ? 1 : 0)
                .allowsHitTesting(glim.presentation == .inapp)
                .zIndex(glim.presentation == .inapp ? 10 : -10)
            
            if glim.presentation == .none {
                Button(action: {
                    Modules.glim.present(Modules.glim.presentation == .none ? .inapp : .none)
                }) {
                    Image(systemName: "sparkle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(8)
                }
                .buttonStyle(.omni)
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                .matchedGeometryEffect(
                    id: "glimContent",
                    in: animationNamespace,
//                    anchor: .bottomTrailing
                )
                .transition(.identity)               // important: no extra fade/scale
                .padding(32)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }
}


final class AppKitSplitViewController: NSSplitViewController, NSToolbarDelegate {
    init(sidebar: AnyView, detail: AnyView) {
        super.init(nibName: nil, bundle: nil)
        
        // Sidebar
        let sidebarHosting = NSHostingController(rootView: sidebar)
        let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarHosting)
        sidebarItem.canCollapse = true
        sidebarItem.minimumThickness = 200
        addSplitViewItem(sidebarItem)

        // Detail
        let detailHosting = NSHostingController(rootView: detail)
        let detailItem = NSSplitViewItem(viewController: detailHosting)
        detailItem.minimumThickness = 400
        detailItem.automaticallyAdjustsSafeAreaInsets = true
        addSplitViewItem(detailItem)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct AppKitNavigationSplitView<Sidebar: View, Detail: View>: NSViewControllerRepresentable {

    let sidebar: Sidebar
    let detail: Detail

    func makeNSViewController(context: Context) -> AppKitSplitViewController {
        let splitVC = AppKitSplitViewController(
            sidebar: AnyView(sidebar),
            detail: AnyView(detail)
        )

        return splitVC
    }

    func updateNSViewController(_ nsViewController: AppKitSplitViewController, context: Context) {
        // 如果 sidebar 或 detail 是动态的（例如绑定了 @State/@Binding），这里可以更新
        // 但大多数情况下，SwiftUI 视图内部状态会自动更新，无需额外处理
    }
}
