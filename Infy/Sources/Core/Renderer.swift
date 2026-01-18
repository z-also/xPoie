import AppKit

extension Infy {
    public class Renderer<D: Node> {
        public var size: CGSize
        public var root: ScrollView<D>
        public var document: DocumentView<D>
        public var coordinator: any Coordinator<D>
        
        private var hosting: (any Hosting<D>)?
        private var rendered: [UUID: NodeRepresenter<D>] = [:]

        @MainActor init(coordinator: any Coordinator<D>) {
            self.size = .zero
            self.root = ScrollView()
            self.document = DocumentView()
            self.coordinator = coordinator
            root.documentView = document
        }
        
        @MainActor public func set(size: CGSize) {
            self.size = size
            document.frame = CGRect(origin: .zero, size: size)
        }
        
        @MainActor internal func set(hosting: any Hosting<D>) {
            self.hosting = hosting
            root.hosting = hosting
            document.hosting = hosting
        }
        
        @MainActor internal func config(_ config: Config) {
            root.config(config)
        }
        
        @MainActor public func render(node: D) {
            if let curr = rendered[node.id] {
                return
            }
            
            if let view = coordinator.render(node: node) {
                print("[Infy] render", node.id)
                view._mount(hosting: hosting)
                document.addSubview(view)
                rendered[node.id] = view
            }
        }

        @MainActor public func render(nodes: [D]) {
            nodes.forEach{ render(node: $0) }
        }
        
        @MainActor public func viewport(bounds b: CGRect?) -> CGRect {
            let bounds = b ?? root.contentView.bounds
            return bounds
        }
        
        @MainActor public func view(for id: UUID) -> NodeRepresenter<D>? {
            rendered[id]
        }
        
        @MainActor public func clear() {
            rendered = [:]
            root.magnification = 1
            root.contentView.scroll(to: .zero)
            document.subviews.forEach{ $0.removeFromSuperview() }
        }
        
        @MainActor public func present(view: NSView) {
            document.addSubview(view)
        }
    }
}
