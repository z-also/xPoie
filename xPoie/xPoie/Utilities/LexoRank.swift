import Foundation

struct LexoRank {
    static func next(curr c: String) -> String {
        let curr = c.isEmpty ? "00000000" : c
        let length = curr.count
        var index = length - 1
        var result = ""
        
        while index >= 0 {
            let char = curr[at: index]!
            if char != "z" {
                result = String(curr.prefix(index)) + String(Character(UnicodeScalar(char.asciiValue! + 1)))
                break
            }
            index -= 1
        }
        
        if index < 0 {
            result = curr + "1"
        } else if index + 1 < length {
            result += String(repeating: "0", count: length - index - 2) + "1"
        }
        
        return result
    }
    
    static func between(prev: String, next: String) -> String {
        var result = ""
        
        guard !prev.isEmpty && !next.isEmpty else {
            return Self.next(curr: prev)
        }

        for index in 0..<max(prev.count, next.count) {
            let pchar = prev[at: index] ?? "0"
            let nchar = next[at: index] ?? "z"
            
            if pchar == nchar || pchar.asciiValue! + 1 >= nchar.asciiValue! {
                result.append(pchar)
                continue
            }
            
            result.append(Character(UnicodeScalar((pchar.asciiValue! + nchar.asciiValue!) / 2)))
            break
        }
        
        if result == prev || result == next {
            result = result + "U"
        }
        
        return result
    }
}
