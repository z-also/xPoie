import AppKit

open class Infy {}

extension Infy {
    open class Infy<D: Node> {
        public var data: Data<D>
        public var renderer: Renderer<D>
        public var delegate: (any Delegate<D>)?
        public var snapshots: SnapshotManager
        
        internal var menus: [UUID: NSView] = [:]
        
        @MainActor public init(config: Config, coordinator: any Coordinator<D>) {
            self.data = .init(cell: config.cell)
            self.renderer = .init(coordinator: coordinator)
            self.snapshots = SnapshotManager()
            self.config(config)
            renderer.set(hosting: self)
        }
        
        @MainActor public func config(_ config: Config) {
            renderer.config(config)
            snapshots.config(baseURL: config.snapshotsPath)
        }
        
        @MainActor public func clear() {
            data.clear()
            renderer.clear()
        }
    }
}
