import Infy
import AppKit
import SwiftUI

fileprivate typealias Node = Modules.Pads.Node

fileprivate typealias ShiftedNode = (
    node: Infy.NodeRepresenter<Node>, from: CGRect, to: CGRect
)

fileprivate protocol Controller: Modules.Pads.Coordinator {
    func takeDetailSnapshot()
    func add(node: Node)
    func present(detail note: Models.Note)
}

fileprivate class Coordinator: Infy.Coordinator, Infy.Delegate, Modules.Pads.Coordinator {
    typealias D = Node
    
    private var pad: Models.Pad
    private var infy: Infy.Infy<Node>!
    private var project: Models.Project
    
    private var size: CGSize
    private var controller: Controller?
    private var activeNodeRepresenter: PadFeatureNote2?
    private var nodeCreateGuide: PadFeature_NodeCreateGuide?
    
    private var shiftedNodes: [ShiftedNode] = []

    @MainActor init(pad: Models.Pad, project: Models.Project) {
        self.pad = pad
        self.project = project
        self.size = .init(width: 8000, height: 8000)
    }
    
    @MainActor func render(node: Node) -> Infy.NodeRepresenter<Node>? {
        switch node.type {
        case .note:
            if let note = Modules.notes.notes[node.id] {
                let representer = PadFeatureNote2(node: node, data: note)
                representer.coordinator = self
                return representer
            }
        case .media:
            if let thing = Modules.things.things[node.id] {
                return PadFeature_Media(node: node, data: thing)
            }
        }
        return nil
    }
    
    @MainActor func on(_ infy: Infy.Infy<Node>, tap point: CGPoint) {
        if Modules.pads.intent == .new {
            resetCreateIntent()
            return
        }
        
        if let current = activeNodeRepresenter {
            current.setActive(false)
            activeNodeRepresenter = nil
        }
    }

    @MainActor func on(_ infy: Infy.Infy<Node>, tap node: Infy.NodeRepresenter<Node>, point: CGPoint) {
        if let node = node as? PadFeatureNote2 {
            perform(infy: infy, select: node)
        }
    }
    
    @MainActor func on(_ infy: Infy.Infy<Node>, move node: Infy.NodeRepresenter<Node>, frame: CGRect) {
        perform(infy: infy, update: node, frame: frame)
    }
    
    @MainActor func on(_ infy: Infy.Infy<Node>, resize node: Infy.NodeRepresenter<Node>, frame: CGRect) {
        perform(infy: infy, update: node, frame: frame)
    }

    @MainActor func on(_ infy: Infy.Infy<Node>, hover node: Infy.NodeRepresenter<Node>?, point: CGPoint) {
        if Modules.pads.intent == .new {
            showOrMoveNewCard(at: point, in: infy)
        }
    }
    
    @MainActor func on(_ infy: Infy.Infy<Node>, exited point: CGPoint) {
        if Modules.pads.intent == .new {
            resetCreateIntent()
        }
    }

    @MainActor private func resetCreateIntent() {
        Modules.pads.set(intent: .none)
    }
    
    @MainActor public func resetIntent() {
        resetCreateIntent()
    }
    
    @MainActor public func takeSnapshot() {
        controller?.takeDetailSnapshot()
    }
    
    @MainActor public func perform(infy: Infy.Infy<Node>, restoreShiftedNodes: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shiftedNodes.forEach{
                $0.node.animator().frame = $0.from
            }
            infy.renderer.root.animator().alphaValue = 1.0
        } completionHandler: {
            self.shiftedNodes = []
        }
    }
    
    @MainActor private func perform(infy: Infy.Infy<Node>, create point: CGPoint) {
        let frame = CGRect(x: point.x, y: point.y, width: 360, height: 300)
        
        if let note = Modules.notes.createNote(at: 0, in: project.id, frame: frame) {
            let node = Node(id: note.id, type: .note, frame: frame)
            infy.add(node: node)
            infy.renderer.render(node: node)
            Modules.pads.add(note: note, at: frame, for: pad)
            try? Store.shared.context.save()
        }
    }
    
    @MainActor private func perform(infy: Infy.Infy<Node>, select node: PadFeatureNote2) {
        if let curr = activeNodeRepresenter, curr != node {
            curr.setActive(false)
        }
        
        guard node.node.type == .note, let note = Modules.notes.notes[node.node.id] else {
            return
        }
        
        node.setActive(true)
        self.activeNodeRepresenter = node
        Modules.pads.set(editingNote: note)
    }
    
    @MainActor private func perform(infy: Infy.Infy<Node>, update node: Infy.NodeRepresenter<Node>, frame: CGRect) {
        if let note = Modules.notes.notes[node.node.id] {
            Modules.pads.set(note: note, at: frame, for: pad)
        }
    }
    
    @MainActor private func showOrMoveNewCard(at point: CGPoint, in infy: Infy.Infy<Node>) {
        if nodeCreateGuide == nil {
            nodeCreateGuide = PadFeature_NodeCreateGuide()
            nodeCreateGuide?.onCreate = onCreate
            nodeCreateGuide?.set(nodeGenres: Modules.pads.nodeGenres)
        }
        
        let vc = nodeCreateGuide!
        
        if vc.view.superview == nil {
            infy.renderer.present(view: vc.view)
        }
        
        vc.move(to: CGPoint(x: point.x + 12, y: point.y + 12))
    }
    
    @MainActor private func shift(node: Infy.NodeRepresenter<Node>, around: Infy.NodeRepresenter<Node>) -> ShiftedNode? {
        let dx = node.frame.midX - around.frame.midX
        let dy = node.frame.midY - around.frame.midY
        
        let distance = sqrt(dx * dx + dy * dy)
        let maxInfluenceDistance: CGFloat = 1000
        guard distance > 0 && distance <= maxInfluenceDistance else {
            return nil
        }
        
        let dirx = dx / distance
        let diry = dy / distance
        
        let maxx: CGFloat = 320
        let maxy: CGFloat = 240
        
        // 系数：越近越大（使用反比例或线性衰减）
        // 选项1：线性衰减（简单清晰）
        // let factor = 1 - (distance / maxInfluenceDistance) // 近 -> ~1，远 -> ~0
        // 选项2：非线性（更强烈的“近大远小”效果，比如平方反比）
        let factor = pow(1 - (distance / maxInfluenceDistance), 2)
        // 选项3：使用 1/distance 的反比（更剧烈，近的时候推得很开）
        // let factor = (maxInfluenceDistance / distance).clamped(to: 0...2)
        
        var newFrame = node.frame
        newFrame.origin.x += dirx * maxx * factor
        newFrame.origin.y += diry * maxy * factor
        
        return (node, node.frame, newFrame)
    }
    
    func reset(pad: Models.Pad, project: Models.Project) {
        self.pad = pad
        self.project = project
        self.shiftedNodes = []
        self.activeNodeRepresenter = nil
    }
    
    @MainActor func onCreate(genre: Modules.Pads.NodeGenre) {
        if let frame = nodeCreateGuide?.view.frame {
            nodeCreateGuide?.detach()
            create(genre: genre, frame: frame)
        }
    }
    
    private func create(genre: Modules.Pads.NodeGenre, frame: NSRect) {
        let type = genre.type
        
        switch type {
        case .note:
            if let note = Modules.notes.createNote(at: 0, in: project.id, frame: frame) {
                let node = Node(id: note.id, type: .note, frame: frame)
                controller?.add(node: node)
                Modules.pads.add(note: note, at: frame, for: pad)
                try? Store.shared.context.save()
            }
        case .media:
            // 创建媒体类型的节点
            if let mediaThing = Modules.things.createThing(in: project.id, frame: frame) {
                let node = Node(id: mediaThing.id, type: .media, frame: frame)
                controller?.add(node: node)
                // 添加到 pad
                Modules.pads.add(thing: mediaThing, at: frame, for: pad)
            }
        }
    }
    
    func attach(infy: Infy.Infy<Node>, controller: Controller) {
        self.infy = infy
        self.controller = controller
        infy.delegate = self
    }

    @MainActor func present(detail node: Infy.NodeRepresenter<Node>) {
        guard node.node.type == .note else {
            return
        }
        
        let neigbor = node.frame.insetBy(dx: -800, dy: -800)
        let neigborNodes = infy.nodes(bounds: neigbor).filter{ $0.node.id != node.node.id }
        self.shiftedNodes = neigborNodes.compactMap{ shift(node: $0, around: node) }
        
//        shiftedNodes.forEach { n in
//            NSAnimationContext.runAnimationGroup { context in
//                context.duration = 0.3
//                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                n.node.animator().frame = n.to
//                infy.renderer.root.animator().alphaValue = 0.0
//            } completionHandler: {
//
//            }
//        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shiftedNodes.forEach {
                $0.node.animator().frame = $0.to
            }
            infy.renderer.root.animator().alphaValue = 0.0
        } completionHandler: {
            
        }
        controller?.present(detail: node)
        Modules.pads.toggle(immersive: true)
    }
}

class PadController: NSViewController, @MainActor Controller {
    private var pad: Models.Pad
    private var project: Models.Project
    
    private var infy: Infy.Infy<Node>
    private var coordinator: Coordinator
    
    private let toolbar: NSHostingView<PadFeatureToolbar>
    private let edgeMasking: NSHostingView<PadEdgeMasking>
    private var detail: PadDetailController

    private var canvasOriginalTransform: CATransform3D = CATransform3DIdentity
    
    init(project: Models.Project) {
        self.project = project
        self.pad = Modules.pads.pads[project.id]!
        self.coordinator = Coordinator(pad: pad, project: project)
        self.infy = Infy.Infy(
            config: .init(
                cell: .init(width: 800, height: 800),
                magnification: 0.1...1,
                snapshotsPath: Consts.padNodeSnapshotsCacheDirectory
            ),
            coordinator: coordinator,
        )
        self.infy.delegate = coordinator
        
        self.edgeMasking = NSHostingView(rootView: PadEdgeMasking())
        self.toolbar = NSHostingView(rootView: PadFeatureToolbar(
            resetIntent: coordinator.resetIntent,
            takeSnapshot: coordinator.takeSnapshot
        ))
        
        self.detail = PadDetailController()

        super.init(nibName: nil, bundle: nil)
        
        coordinator.attach(infy: infy, controller: self)
        
        toolbar.wantsLayer = true
        toolbar.layer?.zPosition = 10000
        toolbar.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
        setupLayout()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        observeChanges()
        renderNodes()
    }
    
    private func observeChanges() {
        withObservationTracking {
            _ = Modules.pads.immersive
        } onChange: {
            DispatchQueue.main.async {
                if !Modules.pads.immersive {
                    self.hideNotesFeaturePage()
                }
            }
            self.observeChanges()
        }
    }
    
    private func setupLayout() {
        let canvas = infy.renderer.root
        canvas.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvas)
        
        edgeMasking.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(edgeMasking)
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            edgeMasking.topAnchor.constraint(equalTo: view.topAnchor),
            edgeMasking.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            edgeMasking.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            edgeMasking.heightAnchor.constraint(equalToConstant: 50),
            
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }
    
    public func takeDetailSnapshot() {
        if let note = Modules.pads.editingNote {
        }
    }
    
    private func renderNodes() {
        infy.clear()
        
        let size = CGSize(width: 8000, height: 8000)
        infy.set(size: size)
        
        pad.nodes.forEach { n in
            let node = Node(
                id: n.key,
                type: .note,
                frame: n.value.frame
            )
            infy.add(node: node)
        }
        
        infy.render(bounds: nil)
    }
    
    private func showNotesFeaturePage(note: Models.Note) {
        detail.view.alphaValue = 0.0
        view.addSubview(detail.view, positioned: .below, relativeTo: toolbar)
        
        detail.set(note: note)
        
        NSLayoutConstraint.activate([
            detail.view.topAnchor.constraint(equalTo: view.topAnchor),
            detail.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            detail.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detail.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            detail.view.animator().alphaValue = 1
        } completionHandler: {

        }
    }
    
    private func hideNotesFeaturePage() {
        coordinator.perform(infy: infy, restoreShiftedNodes: true)
//        guard let detailPage = detailPage else {
//            return
//        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            detail.view.animator().alphaValue = 0
        } completionHandler: {
            self.detail.view.removeFromSuperview()
        }

//        detailPage.animate(scale: 0, alpha: 0) {
//            self.detailPage.removeFromSuperview()
////            self.detailPage = nil
//        }
        
    }
    
    func present(detail note: Models.Note) {
        showNotesFeaturePage(note: note)
    }
    
    func reset(project: Models.Project) {
        guard project.id != self.project.id else {
            return
        }
        infy.clear()
        self.project = project
        self.pad = Modules.pads.pads[project.id]!
        self.coordinator.reset(pad: self.pad, project: project)
    }
    
    private func clear() {
        infy.clear()
    }
    
    fileprivate func add(node: Node) {
        infy.add(node: node)
        infy.renderer.render(node: node)
    }
    
    @MainActor func present(detail node: Infy.NodeRepresenter<Modules.Pads.Node>) {
        if let note = Modules.notes.notes[node.node.id] {
            showNotesFeaturePage(note: note)
        }
    }
}

struct PadRepresentable: NSViewControllerRepresentable {
    let project: Models.Project
    
    func makeNSViewController(context: Context) -> PadController {
        return PadController(project: project)
    }
    
    func updateNSViewController(_ nsViewController: PadController, context: Context) {
        nsViewController.reset(project: project)
    }
}
