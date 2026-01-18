import AppKit

extension Infy {
    public class SnapshotManager {
        private var baseURL: URL = .cachesDirectory
        private let fileManager = FileManager.default
        private let memoryCache = NSCache<NSString, NSImage>()

        public init() {}
        
        public func config(baseURL: URL, memorySize: Int = 1000) {
            self.baseURL = baseURL
            memoryCache.countLimit = memorySize
        }
        
        private func fileURL(for id: String, ext: String = ".png") -> URL {
            let ab = String(id.prefix(2))
            let cd = String(id.dropFirst(2).prefix(2))
            let dir = baseURL.appendingPathComponent(ab).appendingPathComponent(cd)
            try? fileManager.createDirectory(at: dir,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
            return dir.appendingPathComponent("\(id)\(ext)")
        }
        
        @MainActor public func save(id: String, view: NSView) async -> NSImage? {
            guard let image = U.snapshot(view: view) else {
                return nil
            }
            
            view.layoutSubtreeIfNeeded()
            view.needsDisplay = true
            view.display()
            
            let fileURL = fileURL(for: id)
            
            let result = await Task.detached(priority: .background) {
                guard let tiff = image.tiffRepresentation,
                      let bitmap = NSBitmapImageRep(data: tiff),
                      let pngData = bitmap.representation(using: .png, properties: [:]) else {
                    return false
                }
                
                do {
                    try pngData.write(to: fileURL, options: .atomic)
                    return true
                } catch {
                    return false
                }
            }.value
            
            if result {
                self.memoryCache.setObject(image, forKey: id as NSString)
            }

            return image
        }
        
        public func load(id: String) -> NSImage? {
            if let cached = memoryCache.object(forKey: id as NSString) {
                return cached
            }
            
            let fileURL = fileURL(for: id)
            guard let image = NSImage(contentsOf: fileURL) else {
                return nil
            }
            
            memoryCache.setObject(image, forKey: id as NSString)
            return image
        }
    }
}
