import AppKit

extension Infy.Infy {
    @MainActor public func set(size: CGSize) {
        renderer.set(size: size)
    }
    
    @MainActor public func render(bounds: CGRect?) {
        let bounds = renderer.viewport(bounds: bounds)
        for (_, nodes) in data.query(bounds: bounds) {
            renderer.render(nodes: nodes)
        }
    }
    
    @MainActor public func nodes(bounds: CGRect?) -> [Infy.NodeRepresenter<D>] {
        var res: [Infy.NodeRepresenter<D>] = []
        let bounds = renderer.viewport(bounds: bounds)
        for (_, nodes) in data.query(bounds: bounds) {
            res.append(contentsOf: nodes.compactMap{ renderer.view(for: $0.id) })
        }
        return res
    }
}
