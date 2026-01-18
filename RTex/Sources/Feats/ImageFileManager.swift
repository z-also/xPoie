import Foundation
import AppKit

/// Manages image file storage in the app's iCloud-synced directory
class ImageFileManager {
    nonisolated(unsafe) static let shared = ImageFileManager()
    
    private let imageDirectoryName = "RTexImages"
    private var imageDirectory: URL?
    
    private init() {
        setupImageDirectory()
    }
    
    /// Sets up the image storage directory in the app's iCloud container
    private func setupImageDirectory() {
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            // Fallback to Documents directory if iCloud is not available
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            imageDirectory = documentsURL.appendingPathComponent(imageDirectoryName)
            createDirectoryIfNeeded()
            return
        }
        
        // Use iCloud Documents directory
        imageDirectory = containerURL.appendingPathComponent("Documents").appendingPathComponent(imageDirectoryName)
        createDirectoryIfNeeded()
    }
    
    /// Creates the image directory if it doesn't exist
    private func createDirectoryIfNeeded() {
        guard let imageDirectory = imageDirectory else { return }
        
        if !FileManager.default.fileExists(atPath: imageDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
            } catch {
            }
        } else {
        }
    }
    
    /// Copies an image to the managed directory and returns the relative path
    func copyImage(_ image: NSImage, withName name: String? = nil) -> String? {
        guard let imageDirectory = imageDirectory else { 
            return nil
        }
        
        // Generate unique filename
        let fileName = name ?? "\(UUID().uuidString).png"
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        
        // Convert NSImage to PNG data
        guard let imageData = image.pngData else { 
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return fileName // Return relative path
        } catch {
            return nil
        }
    }
    
    /// Copies an image from URL to the managed directory
    func copyImage(from sourceURL: URL) -> String? {
        guard let imageDirectory = imageDirectory else { return nil }
        
        let fileName = "\(UUID().uuidString).\(sourceURL.pathExtension)"
        let destinationURL = imageDirectory.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return fileName // Return relative path
        } catch {
            return nil
        }
    }
    
    /// Copies image data to the managed directory
    func copyImage(from data: Data, withExtension ext: String = "png") -> String? {
        guard let imageDirectory = imageDirectory else { return nil }
        
        let fileName = "\(UUID().uuidString).\(ext)"
        let fileURL = imageDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileName // Return relative path
        } catch {
            return nil
        }
    }
    
    /// Loads an image from the managed directory using relative path
    func loadImage(at relativePath: String) -> NSImage? {
        guard let imageDirectory = imageDirectory else { 
            return nil
        }
        
        let fileURL = imageDirectory.appendingPathComponent(relativePath)
        
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        let image = NSImage(contentsOf: fileURL)
        if image != nil {
        } else {
        }
        
        return image
    }
    
    /// Gets the full URL for a relative path
    func fullURL(for relativePath: String) -> URL? {
        guard let imageDirectory = imageDirectory else { return nil }
        return imageDirectory.appendingPathComponent(relativePath)
    }
    
    /// Deletes an image file
    func deleteImage(at relativePath: String) {
        guard let imageDirectory = imageDirectory else { return }
        
        let fileURL = imageDirectory.appendingPathComponent(relativePath)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    /// Checks if an image file exists
    func imageExists(at relativePath: String) -> Bool {
        guard let imageDirectory = imageDirectory else { return false }
        
        let fileURL = imageDirectory.appendingPathComponent(relativePath)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    /// Gets the image directory URL (for debugging)
    var currentImageDirectory: URL? {
        return imageDirectory
    }
}

// MARK: - NSImage Extensions

extension NSImage {
    /// Converts NSImage to PNG data
    var pngData: Data? {
        guard let tiffData = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else { return nil }
        
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
