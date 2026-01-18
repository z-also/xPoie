import AppKit

extension Infy {
    public class Data<D: Node> {
        private var storage: SpatialDataGrid<D>

        init(cell: CGSize) {
            storage = SpatialDataGrid(cell: cell)
        }
        
        func add(node: D) {
            storage.add(node, frame: node.frame)
        }
        
        func remove(node: D) {
            storage.remove(node, frame: node.frame)
        }
        
        func query(bounds: CGRect) -> [Int: [D]] {
            return storage.query(bounds: bounds)
        }
        
        func clear() {
            storage.clear()
        }
    }
}
