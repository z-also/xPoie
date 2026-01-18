import AppKit

public extension Infy.Infy {
    @MainActor func add(node: D) {
        data.add(node: node)
    }
    
    @MainActor func remove(node: D) {
        data.remove(node: node)
    }
}
