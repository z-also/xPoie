import RTex
import SwiftUI
import SwiftData

/// Sample projects system for app initialization
struct Samples {
    // Sample data structure
    struct SampleData {
        let metas: Models.Project.Metas
        let children: [SampleData]?
        let initialContent: InitialContent?
        
        init(type: Models.Project.`Type`, title: String, icon: String, color: String, children: [SampleData]? = nil, initialContent: InitialContent? = nil) {
            self.metas = Models.Project.Metas(type: type, title: title, icon: icon, color: color)
            self.children = children
            self.initialContent = initialContent
        }
    }
    
    /// Initial content for sample projects
    struct InitialContent {
        let notes: [AttributedString]?
        let tasks: [String]?
        
        init(notes: [AttributedString]? = nil, tasks: [String]? = nil) {
            self.notes = notes
            self.tasks = tasks
        }
    }
    
    /// Sample projects structure for new users
    static let sampleProjects: [SampleData] = [
        // Welcome Project (task type, with blocks)
        SampleData(
            type: .task,
            title: "Welcome",
            icon: "star.fill",
            color: "palette/yellow",
            initialContent: InitialContent(
                notes: [
//                    Utilities.attributedString(
//                        from: """
//Welcome to xPoie!
//
//A Project in xPoie is a flexible container for organizing your work, life, and ideas. You can use projects to manage tasks, group related notes, plan agendas, and more.
//
//- Use projects for work (e.g. 'Work Projects'), personal goals (e.g. 'Health & Fitness'), or any topic you want to organize.
//- Projects can contain tasks, notes, and even other projects (folders).
//- You can break down big goals into smaller tasks, group them with blocks, and track your progress.
//
//Explore the sample projects and try creating your own!
//""",
//                        config: TikitRTexConfig(theme: Modules.vars.theme)
//                    )
                ]
            )
        ),
        // Personal Journal
        SampleData(
            type: .group,
            title: "Personal Journal",
            icon: "book",
            color: "palette/blue",
            children: [
                SampleData(
                    type: .pad,
                    title: "Today's Reflection",
                    icon: "heart.square",
                    color: "palette/pink",
                    initialContent: InitialContent(
                        notes: [
                            "Today I feel grateful for...",
                            "What went well today?",
                            "What could I improve tomorrow?"
                        ]
                    )
                ),
                SampleData(
                    type: .pad,
                    title: "Ideas & Inspiration",
                    icon: "lightbulb.min",
                    color: "palette/yellow",
                    initialContent: InitialContent(
                        notes: [
                            "💡 New project idea: Create a habit tracker app\n",
                            "📚 Book recommendation: Atomic Habits by James Clear\n",
                            "🎯 Goal: Learn a new programming language this year"
                        ]
                    )
                ),
                SampleData(
                    type: .task,
                    title: "Daily Habits",
                    icon: "clock.badge",
                    color: "palette/green",
                    initialContent: InitialContent(
                        tasks: [
                            "Morning meditation (10 minutes)",
                            "Read 30 pages",
                            "Exercise for 30 minutes",
                            "Write in journal",
                            "Review tomorrow's schedule"
                        ]
                    )
                )
            ]
        ),
        // Work Projects
        SampleData(
            type: .group,
            title: "Work Projects",
            icon: "chart.xyaxis.line",
            color: "palette/purple",
            children: [
                SampleData(
                    type: .task,
                    title: "Q1 Goals",
                    icon: "externaldrive.connected.to.line.below",
                    color: "palette/blue",
                    initialContent: InitialContent(
                        tasks: [
                            "Complete project proposal",
                            "Set up team meetings",
                            "Review budget allocation",
                            "Create timeline for deliverables"
                        ]
                    )
                ),
                SampleData(
                    type: .pad,
                    title: "Meeting Notes",
                    icon: "pencil.tip",
                    color: "palette/green",
                    initialContent: InitialContent(
                        notes: [
                            "📅 Weekly Team Meeting - Jan 15, 2024",
                            "• Discussed Q1 objectives",
                            "• Assigned new project roles",
                            "• Next meeting: Jan 22, 2024",
                            "",
                            "📝 Action Items:",
                            "- Follow up with design team",
                            "- Schedule client presentation"
                        ]
                    )
                ),
                SampleData(
                    type: .task,
                    title: "Urgent Tasks",
                    icon: "bolt.horizontal.circle.fill",
                    color: "palette/red",
                    initialContent: InitialContent(
                        tasks: [
                            "Respond to client email",
                            "Fix critical bug in production",
                            "Prepare presentation for tomorrow"
                        ]
                    )
                )
            ]
        ),
        // Daily Life
        SampleData(
            type: .group,
            title: "Daily Life",
            icon: "gamecontroller",
            color: "palette/green",
            children: [
                SampleData(
                    type: .task,
                    title: "Shopping List",
                    icon: "airplane.departure",
                    color: "palette/blue",
                    initialContent: InitialContent(
                        tasks: [
                            "Groceries: milk, bread, eggs",
                            "Home supplies: laundry detergent",
                            "Personal care: shampoo, toothpaste"
                        ]
                    )
                ),
                SampleData(
                    type: .pad,
                    title: "Quick Notes",
                    icon: "scribble",
                    color: "palette/yellow",
                    initialContent: InitialContent(
                        notes: [
                            "📞 Call mom this weekend",
                            "🎬 Movie to watch: Inception",
                            "🍕 Restaurant recommendation: Luigi's Pizza",
                            "📱 App idea: Smart grocery list"
                        ]
                    )
                ),
                SampleData(
                    type: .task,
                    title: "Health & Fitness",
                    icon: "number",
                    color: "palette/purple",
                    initialContent: InitialContent(
                        tasks: [
                            "Go for a 30-minute walk",
                            "Drink 8 glasses of water",
                            "Take vitamins",
                            "Stretch exercises"
                        ]
                    )
                )
            ]
        )
    ]
    
    /// Create sample projects from the predefined structure
    static func createSampleProjects() {
        // 1. 创建主项目结构
        var welcomeProject: Models.Project? = nil
        for sampleData in sampleProjects.reversed() {
            let project = createSampleProject(sampleData, parent: nil)
            // 记录 Welcome 项目
            if sampleData.metas.title == "Welcome" {
                welcomeProject = project
            }
        }
        // 2. 在 Welcome 里创建任务块和任务
        if let welcome = welcomeProject {
            createWelcomeBlocks(for: welcome)
        }
        // 3. 在 inbox 里创建样例任务
        createInboxSamples()
    }
    
    /// 在 Welcome 项目下创建任务块和任务
    private static func createWelcomeBlocks(for project: Models.Project) {
        let blocks: [(String, [String])] = [
            ("Get Started", [
                "Create your first task",
                "Mark a task as done",
                "Edit or delete a task"
            ]),
            ("Organize", [
                "Create a new project or folder",
                "Move tasks between projects",
                "Try grouping tasks with blocks"
            ]),
            ("Notes & Agenda", [
                "Create a note for meeting minutes",
                "Add a daily agenda entry",
                "Link notes to tasks"
            ]),
            ("Productivity Tips", [
                "Use Inbox for quick capture",
                "Set reminders for important tasks",
                "Explore keyboard shortcuts"
            ])
        ]
        for (blockTitle, taskTitles) in blocks {
            let block = Models.Task.Block(
                title: blockTitle,
                project: project.id,
                rank: LexoRank.next(curr: "")
            )
            Modules.tasks.blocks[block.id] = block
            Store.shared.context.insert(block)
            // Add block to project
            if Modules.tasks.projects[project.id] == nil {
                Modules.tasks.projects[project.id] = Collection(data: [])
            }
            Modules.tasks.projects[project.id]?.data.append(block.id)
            // 创建任务
            for taskTitle in taskTitles {
                let task = Models.Task(
                    block: block.id,
                    parent: nil,
                    project: project.id,
                    title: taskTitle,
                    rank: LexoRank.next(curr: ""),
                    type: .task
                )
                Modules.tasks.tasks[task.id] = task
                Store.shared.context.insert(task)
                // Add to block catalog
                if Modules.tasks.catalogs[block.id] == nil {
                    Modules.tasks.catalogs[block.id] = Collection(data: [])
                }
                Modules.tasks.catalogs[block.id]?.data.append(task.id)
            }
        }
    }
    
    /// 在 inbox (Consts.uuid2) 里创建样例任务
    private static func createInboxSamples() {
        let inboxId = Consts.uuid2
        let tasks = [
            "This is your Inbox. If you create a task without selecting a project, it will appear here.",
            "Try creating a new task now!",
            "Inbox is great for quick capture and triage."
        ]
        for (index, taskTitle) in tasks.enumerated() {
            let task = Models.Task(
                block: nil,
                parent: nil,
                project: inboxId,
                title: taskTitle,
                rank: LexoRank.next(curr: ""),
                type: .task
            )
            Modules.tasks.tasks[task.id] = task
            Store.shared.context.insert(task)
            // Add to catalog
            if Modules.tasks.catalogs[inboxId] == nil {
                Modules.tasks.catalogs[inboxId] = Collection(data: [])
            }
            Modules.tasks.catalogs[inboxId]?.data.append(task.id)
        }
    }
    
    /// Recursively create sample projects
    private static func createSampleProject(_ sampleData: SampleData, parent: Models.Project?) -> Models.Project? {
        let project = Modules.projects.create(
            metas: sampleData.metas,
            at: 0,
            in: parent
        )
        // Set title after creation
        project?.title = sampleData.metas.title
        // Set notes if present
        if let notesArr = sampleData.initialContent?.notes, !notesArr.isEmpty {
            project?.notes = notesArr.reduce(AttributedString("")) { $0 + $1 }
        }
        // Create initial content if available
        if let initialContent = sampleData.initialContent {
            createInitialContent(for: project!, content: initialContent)
        }
        // Create children if any
        if let children = sampleData.children {
            for childData in children {
                createSampleProject(childData, parent: project)
            }
        }
        return project
    }
    
    /// Create initial content for sample projects
    private static func createInitialContent(for project: Models.Project, content: InitialContent) {
        switch project.type {
        case .pad:
            if let notes = content.notes {
                createSampleNotes(for: project, notes: notes)
            }
        case .task:
            if let tasks = content.tasks {
                createSampleTasks(for: project, tasks: tasks)
            }
        case .chat:
            break
        case .group:
            break // Groups don't have direct content
        }
    }
    
    /// Create sample notes
    private static func createSampleNotes(for project: Models.Project, notes: [AttributedString]) {
        for (index, noteContent) in notes.enumerated() {
            let note = Models.Note(
                parent: project.id,
                title: "Sample Note \(index + 1)",
                rank: LexoRank.next(curr: ""),
                content: noteContent
            )
            Modules.notes.notes[note.id] = note
            Store.shared.context.insert(note)
            // Add to catalog
            if Modules.notes.catalogs[project.id] == nil {
                Modules.notes.catalogs[project.id] = Collection(data: [])
            }
            Modules.notes.catalogs[project.id]?.data.append(note.id)
        }
    }
    
    /// Create sample tasks
    private static func createSampleTasks(for project: Models.Project, tasks: [String]) {
        for (index, taskTitle) in tasks.enumerated() {
            let task = Models.Task(
                block: nil,
                parent: nil,
                project: project.id,
                title: taskTitle,
                rank: LexoRank.next(curr: ""),
                type: .task
            )
            Modules.tasks.tasks[task.id] = task
            Store.shared.context.insert(task)
            // Add to catalog
            if Modules.tasks.catalogs[project.id] == nil {
                Modules.tasks.catalogs[project.id] = Collection(data: [])
            }
            Modules.tasks.catalogs[project.id]?.data.append(task.id)
        }
    }
} 
