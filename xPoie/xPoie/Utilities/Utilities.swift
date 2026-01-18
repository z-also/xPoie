import AppKit
import Foundation

struct Utilities {
    static func rect(from str: String) -> CGRect {
        let components = str.components(separatedBy: ",")
        guard components.count == 4,
              let x = Double(components[0]),
              let y = Double(components[1]),
              let width = Double(components[2]),
              let height = Double(components[3]) else {
            return .zero
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    static func string(from rect: CGRect) -> String {
        guard rect != .zero else {
            return ""
        }
        return "\(rect.origin.x),\(rect.origin.y),\(rect.size.width),\(rect.size.height)"
    }
    
    static func sf(cursor: String, description: String = "") -> NSCursor {
        guard let image = NSImage(systemSymbolName: cursor, accessibilityDescription: description) else {
            return NSCursor.arrow
        }
                
        let greenConfig = NSImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
        let greenImage = image.withSymbolConfiguration(greenConfig)!
        
        let sizedConfig = NSImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        let finalImage = greenImage.withSymbolConfiguration(sizedConfig)!
        
        return NSCursor(image: finalImage, hotSpot: NSMakePoint(16, 16))
    }
}
