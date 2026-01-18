import AppKit

extension Infy.Infy: Infy.Hosting {
    @MainActor func on(viewport bounds: CGRect) {
        render(bounds: bounds)
    }
    
    @MainActor func on(move node: Infy.NodeRepresenter<D>, frame: CGRect) {
        delegate?.on(self, move: node, frame: frame)
    }
    
    @MainActor func on(hover node: Infy.NodeRepresenter<D>?, point: CGPoint) {
        delegate?.on(self, hover: node, point: point)
    }

    @MainActor func on(tap point: CGPoint) {
        delegate?.on(self, tap: point)
    }
    
    @MainActor func on(tap node: Infy.NodeRepresenter<D>, point: CGPoint) {
        delegate?.on(self, tap: node, point: point)
    }
    
    @MainActor func on(exited point: CGPoint) {
        delegate?.on(self, exited: point)
    }

    @MainActor func on(resize node: Infy.NodeRepresenter<D>, frame: CGRect) {
        delegate?.on(self, resize: node, frame: frame)
    }
    
    @MainActor func snapshot(get id: UUID) -> NSImage? {
        snapshots.load(id: id.uuidString)
    }
    
    @MainActor func snapshot(save id: UUID, view: NSView) async -> NSImage? {
        await snapshots.save(id: id.uuidString, view: view)
    }
    
    @MainActor func on(node: Infy.NodeRepresenter<D>, menu: NSView?) {
        guard let menu = menu else {
            if let existed = menus[node.node.id] {
                existed.removeFromSuperview()
                menus.removeValue(forKey: node.node.id)
            }
            return
        }
        
        menus[node.node.id] = menu
        renderer.present(view: menu)
        
        menu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menu.centerXAnchor.constraint(equalTo: node.centerXAnchor),
            menu.bottomAnchor.constraint(equalTo: node.topAnchor, constant: -12),
        ])
    }
}
