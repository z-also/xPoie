import AppKit

extension Infy {
    public protocol Node<D>: Identifiable {
        associatedtype D
        var id: UUID { get }
        var type: D { get set }
        var frame: CGRect { get }
    }
    
    public protocol NodeRepresentable<D>: NSView {
        associatedtype D: Node
        var node: D { get set }
    }

    public struct Config: Sendable {
        let cell: CGSize
        let magnification: ClosedRange<CGFloat>
        let snapshotsPath: URL
        
        public init(cell: CGSize,
                    magnification: ClosedRange<CGFloat>,
                    snapshotsPath: URL) {
            self.cell = cell
            self.magnification = magnification
            self.snapshotsPath = snapshotsPath
        }
    }
}

extension Infy {
    public protocol Coordinator<D> {
        associatedtype D: Node
        @MainActor func render(node: D) -> NodeRepresenter<D>?
    }
    
    public protocol Delegate<D> {
        associatedtype D: Node
        @MainActor func on(_ infy: Infy<D>, tap point: CGPoint)
        @MainActor func on(_ infy: Infy<D>, tap node: NodeRepresenter<D>, point: CGPoint)
        @MainActor func on(_ infy: Infy<D>, move node: NodeRepresenter<D>, frame: CGRect)
        @MainActor func on(_ infy: Infy<D>, hover node: NodeRepresenter<D>?, point: CGPoint)
        @MainActor func on(_ infy: Infy<D>, exited point: CGPoint)
        @MainActor func on(_ infy: Infy<D>, resize node: NodeRepresenter<D>, frame: CGRect)
    }
    
    internal protocol Hosting<D> {
        associatedtype D: Node
        @MainActor func on(tap point: CGPoint)
        @MainActor func on(tap node: NodeRepresenter<D>, point: CGPoint)
        @MainActor func on(viewport bounds: CGRect)
        @MainActor func on(move node: NodeRepresenter<D>, frame: CGRect)
        @MainActor func on(hover node: NodeRepresenter<D>?, point: CGPoint)
        @MainActor func on(exited point: CGPoint)
        @MainActor func on(resize node: NodeRepresenter<D>, frame: CGRect)
        @MainActor func snapshot(get id: UUID) -> NSImage?
        @MainActor func snapshot(save id: UUID, view: NSView) async -> NSImage?
        @MainActor func on(node: NodeRepresenter<D>, menu: NSView?)
    }
}
