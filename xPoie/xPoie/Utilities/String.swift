import Foundation

extension String {
    subscript(at index: Int) -> Character? {
        guard index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
}
