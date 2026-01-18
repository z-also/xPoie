import AppKit
import CoreGraphics

extension Infy {
    public struct U {
        @MainActor static func snapshot(view: NSView) -> NSImage? {
            let bounds = view.bounds
            guard let bitmap = view.bitmapImageRepForCachingDisplay(in: bounds) else {
                return nil
            }
            view.cacheDisplay(in: bounds, to: bitmap)
            let image = NSImage(size: bounds.size)
            image.addRepresentation(bitmap)
            return image
        }
        @MainActor static func cgSnapshot(view: NSView) -> NSImage? {
            let bounds = view.bounds
            let image = NSImage(size: bounds.size)
            image.lockFocusFlipped(true)
            guard let context = NSGraphicsContext.current?.cgContext else {
                image.unlockFocus()
                return nil
            }
            view.layer?.render(in: context)
            image.unlockFocus()
            return image
        }
    }
}
