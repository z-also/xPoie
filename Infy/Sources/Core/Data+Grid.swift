import AppKit

extension Infy {
    class SpatialDataGrid<D: Node> {
        private let cell: CGSize
        private let prime: Int = 92821
        private var buckets: [Int: [D]] = [:]

        init(cell: CGSize) {
            self.cell = cell
        }
        
        func add(_ object: D, frame: CGRect) {
            iterate(bounds: frame) { hash in
                if buckets[hash] == nil {
                    buckets[hash] = []
                }
                print("[Infy] add", object.id, " at ", hash)
                buckets[hash]?.append(object)
            }
        }
        
        func remove(_ object: D, frame: CGRect) {
            iterate(bounds: frame) { hash in
                buckets[hash]?.removeAll { $0.id == object.id }
                if buckets[hash]?.isEmpty ?? false {
                    buckets.removeValue(forKey: hash)
                }
            }
        }
        
        func query(bounds: CGRect) -> [Int: [D]] {
            var results: [Int: [D]] = [:]
            iterate(bounds: bounds) { hash in
                if let objects = buckets[hash], !objects.isEmpty {
                    results[hash] = objects
                }
            }
            return results
        }
        
        func clear() {
            buckets.removeAll()
        }
        
        private func hash(x: Int, y: Int) -> Int {
            x * prime + y
        }
        
        private func coord(x: CGFloat, y: CGFloat) -> (Int, Int) {
            (Int(floor(x / cell.width)), Int(floor(y / cell.height)))
        }

        private func iterate(bounds: CGRect, using: (Int) -> Void) {
            let (minX, minY) = coord(x: bounds.minX, y: bounds.minY)
            let (maxX, maxY) = coord(x: bounds.maxX, y: bounds.maxY)
            for x in minX...maxX {
                for y in minY...maxY {
                    using(hash(x: x, y: y))
                }
            }
        }
    }
}
