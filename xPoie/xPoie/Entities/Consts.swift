import SwiftUI

struct Consts {
    // min width of main sidebar
    static let mainSidebarMinWidth: CGFloat = 240
    // max width of main sidebar
    static let mainSidebarMaxWidth: CGFloat = 360
    // ideal width of main sidebar
    static let mainSidebarIdealWidth: CGFloat = 280
    // themes
    static let themes: [Option<String, Theme>] = [
        .init(
            id: "liquid",
            icon: "theme.liquid",
            title: "Liquid Glass",
            value: Theme.liquid
        ),
        .init(
            id: "flat",
            icon: "theme.system",
            title: "Flat",
            value: Theme.flat
        )
    ]
    // colors
    static let colors: [Option<String, String>] = [
        .init(
            id: "red",
            title: "Red",
            value: "palette/red"
        ),
        .init(
            id: "blue",
            title: "Red",
            value: "palette/blue"
        ),
        .init(
            id: "green",
            title: "Red",
            value: "palette/green"
        ),
        .init(
            id: "yellow",
            title: "Red",
            value: "palette/yellow"
        ),
        .init(
            id: "pink",
            title: "Red",
            value: "palette/pink"
        ),
        .init(
            id: "purple",
            title: "Red",
            value: "palette/purple"
        )
    ]
    
    static let icons: [Option<String, String>] = [
        "gamecontroller",
        "lightbulb.min",
        "scribble",
        "book",
        "airplane.departure",
        "chart.xyaxis.line",
        "number",
        "heart.square",
        "externaldrive.connected.to.line.below",
        "externaldrive.connected.to.line.below.fill",
        "personalhotspot",
        "personalhotspot.circle",
        "bolt.horizontal.circle.fill",
        "seal.fill",
        "key.icloud",
        "globe.central.south.asia.fill",
        "play.rectangle.fill",
        "light.min",
        "clock.badge",
        "m.circle",
        "sum",
        "at",
        "cloud.heavyrain",
        "cloud.snow.circle.fill",
        "cloud.sun.rain.circle.fill",
        "pencil.tip",
        "folder.badge.person.crop",
        "externaldrive.connected.to.line.below",
        "ipod.shuffle.gen4"
    ].map{ .init(id: $0, value: $0) }
    
    static let illustrationForCreation: [String] = [
        ""
    ]
    
    // predefined const id
    static let uuid = UUID()
    
    // static uuid for inbox. never change!!!
    static let uuid2 = UUID(uuidString: "0D819F35-84AD-4454-82D2-D40E928C4255")!
    
    static let projectSpecs: [Models.Project.`Type`: Modules.Projects.Specs] = [
        .group: .init(
            what: "What are Folders in xPoie",
            intro: "Organize your projects, tasks, and notes with folders. Create a hierarchical structure to keep everything neatly organized and easy to find.",
            title: "Project title.",
            desc: "details"
        ),
        .pad: .init(
            what: "What are Pads in xPoie",
            intro: "Capture your thoughts, ideas, and information in rich text format. Perfect for knowledge recording, meeting notes, research, documentation, and creative writing.",
            title: "vv",
            desc: ""
        ),
        .task: .init(
            what: "What are Task Books in xPoie",
            intro: "Manage your tasks and projects with structured workflows. Use todo lists, kanban boards, agenda views, and progress tracking to stay organized and productive.",
            title: "ee",
            desc: ""
        )
    ]
    
    // project creation configuration
    static let projectCreationConfig: [Models.Project.`Type`: (title: String, hint: String, explain: String)] = [
        .group: (
            "Create folder",
            "What are Folders in xPoie",
            "Organize your projects, tasks, and notes with folders. Create a hierarchical structure to keep everything neatly organized and easy to find."
        ),
        .pad: (
            "Create Notes pad",
            "What are Notes in xPoie",
            "Capture your thoughts, ideas, and information in rich text format. Perfect for knowledge recording, meeting notes, research, documentation, and creative writing."
        ),
        .task: (
            "Create Task Book",
            "What are Task Books in xPoie",
            "Manage your tasks and projects with structured workflows. Use todo lists, kanban boards, agenda views, and progress tracking to stay organized and productive."
        )
    ]
    
    static let projectCreationSugs: [Models.Project.`Type`: [Modules.Projects.Sug]] = [
        .group: [
            .init(
                id: "",
                icon: "note.text",
                color: "palette/blue",
                title: "Work",
                value: ""
            ),
            .init(
                id: "",
                icon: "note.text",
                color: "palette/purple",
                title: "Personal",
                value: ""
            ),
            .init(
                id: "",
                icon: "note.text",
                color: "palette/green",
                title: "Projects",
                value: ""
            ),
            .init(
                id: "",
                icon: "note.text",
                color: "palette/orange",
                title: "Archive",
                value: ""
            )
        ],
        .pad: [
            .init(
                id: "",
                icon: "note.text",
                color: "palette/blue",
                title: "Meeting notes",
                value: ""
            ),
            .init(
                id: "",
                icon: "book",
                color: "palette/green",
                title: "Research",
                value: ""
            ),
            .init(
                id: "",
                icon: "lightbulb",
                color: "palette/yellow",
                title: "Ideas",
                value: ""
            ),
            .init(
                id: "",
                icon: "doc.text",
                color: "palette/purple",
                title: "Documentation",
                value: ""
            )
        ],
        .task: [
            .init(
                id: "",
                icon: "lightbulb",
                color: "palette/yellow",
                title: "User reviews",
                value: ""
            ),
            .init(
                id: "",
                icon: "lightbulb",
                color: "palette/yellow",
                title: "Standups",
                value: ""
            ),
            .init(
                id: "",
                icon: "lightbulb",
                color: "palette/blue",
                title: "Projects",
                value: ""
            ),
            .init(
                id: "",
                icon: "figure.dance",
                color: "palette/purple",
                title: "Product demos",
                value: ""
            )
        ]
    ]
    
    static let padInspectors: [(Modules.Pads.Inspector, String)] = [
        (.content, "Content"),
        (.style, "Style"),
        (.action, "Action")
    ]
    
    static let padLayoutOptions: [PadLayoutOption] = [
        .init(id: .grid, icon: "rectangle.3.group.fill", title: "Grid", value: .grid),
        .init(id: .list, icon: "rectangle.grid.1x2.fill", title: "List", value: .list)
    ]
    
    @MainActor static let visuals: [Option<String, Visual>] = Visual.presets.map {
        .init(id: $0.name, value: $0)
    }
    
    @MainActor static let presenters: [Option<String, Presenter>] = Presenter.presets.map {
        .init(id: $0.name, value: $0)
    }
    
    nonisolated(unsafe) static var floatingPanelLevel: Int = 102
    
    static let padNodeSnapshotsCacheDirectory: URL = .cachesDirectory
        .appendingPathComponent(Bundle.main.bundleIdentifier!)
        .appendingPathComponent("infy-snapshots")
}
