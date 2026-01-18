import AppKit

public class YoImageAttachment: NSTextAttachment {
    public var maxWidth: Double = 600
    public var maxHeight: Double = 400
    private var originalSize: CGSize = .zero
    
    /// The relative path to the image file in the managed directory
    public var imagePath: String?

    public override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
        // Ensure attachment displays images properly
        self.lineLayoutPadding = 0
        setupImage()
    }
    
    public convenience init(imagePath: String) {
        self.init(data: nil, ofType: nil)
        self.imagePath = imagePath
        loadImageFromPath()
        setupImage()
    }
    
    public convenience init(image: NSImage) {
        self.init(data: nil, ofType: nil)
        // Set the image directly - this is crucial for TextKit2
        self.image = image
        
        // Store image in managed directory and save path asynchronously
        if let relativePath = ImageFileManager.shared.copyImage(image) {
            self.imagePath = relativePath
        }
        setupImage()
    }
    
    required init?(coder: NSCoder) {
        self.maxWidth = coder.decodeDouble(forKey: "maxWidth")
        self.maxHeight = coder.decodeDouble(forKey: "maxHeight")
        self.originalSize = coder.decodeSize(forKey: "originalSize")
        self.imagePath = coder.decodeObject(forKey: "imagePath") as? String
        super.init(coder: coder)
        loadImageFromPath()
        setupImage()
    }
    
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(maxWidth, forKey: "maxWidth")
        coder.encode(maxHeight, forKey: "maxHeight")
        coder.encode(originalSize, forKey: "originalSize")
        coder.encode(imagePath, forKey: "imagePath")
    }
    
    public override class var supportsSecureCoding: Bool {
        return true
    }

    /// Load image from the stored path
    private func loadImageFromPath() {
        guard let imagePath = imagePath else { 
            return
        }
        let loadedImage = ImageFileManager.shared.loadImage(at: imagePath)
        if let loadedImage = loadedImage {
            self.image = loadedImage
        } else {
        }
    }
    
    private func setupImage() {
        guard let image = self.image else { 
            return
        }
        
        originalSize = image.size
        
        // Calculate scaled size while maintaining aspect ratio
        let scaledSize = calculateScaledSize(for: image.size)
        bounds = CGRect(origin: .zero, size: scaledSize)
    }
    
    private func calculateScaledSize(for imageSize: CGSize) -> CGSize {
        let widthRatio = maxWidth / imageSize.width
        let heightRatio = maxHeight / imageSize.height
        let scaleFactor = min(widthRatio, heightRatio, 1.0) // Don't scale up
        
        return CGSize(
            width: imageSize.width * scaleFactor,
            height: imageSize.height * scaleFactor
        )
    }
    
    /// Updates the maximum display size and recalculates bounds
    public func setMaxSize(width: CGFloat, height: CGFloat) {
        maxWidth = width
        maxHeight = height
        
        if let image = self.image {
            let scaledSize = calculateScaledSize(for: image.size)
            bounds = CGRect(origin: .zero, size: scaledSize)
        }
    }
    
    /// Returns the original image size
    public var originalImageSize: CGSize {
        return originalSize
    }
    
    /// Returns the current display size
    public var displaySize: CGSize {
        return bounds.size
    }
    
    /// Override to ensure proper bounds for TextKit2
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        guard let image = self.image else {
            return CGRect(x: 0, y: 0, width: 20, height: 20) // Placeholder size
        }
        
        let scaledSize = calculateScaledSize(for: image.size)
        let rect = CGRect(origin: .zero, size: scaledSize)
        return rect
    }
    
    /// Override to provide image for rendering
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {
        let img = self.image
        return img
    }
}

/// Extension for creating image attachments from various sources
public extension YoImageAttachment {
    /// Create attachment from URL by copying file to managed directory
    static func from(url: URL) -> YoImageAttachment? {
        // Copy file to managed directory
        guard let relativePath = ImageFileManager.shared.copyImage(from: url) else { return nil }
        return YoImageAttachment(imagePath: relativePath)
    }
    
    /// Create attachment from data by saving to managed directory
    static func from(data: Data) -> YoImageAttachment? {
        // Determine file extension from data
        let ext: String
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            ext = "png"
        } else if data.starts(with: [0xFF, 0xD8, 0xFF]) {
            ext = "jpg"
        } else {
            ext = "png" // Default to PNG
        }
        
        guard let relativePath = ImageFileManager.shared.copyImage(from: data, withExtension: ext) else { return nil }
        return YoImageAttachment(imagePath: relativePath)
    }
    
    /// Create attachment from pasteboard by copying data to managed directory
    static func from(pasteboard: NSPasteboard) -> YoImageAttachment? {
        // Try to get image directly first and save it
        if let image = NSImage(pasteboard: pasteboard) {
            return YoImageAttachment(image: image)
        }
        
        // Try to get image data from pasteboard and save to managed directory
        if let data = pasteboard.data(forType: .tiff) {
            return YoImageAttachment.from(data: data)
        }
        
        // Try PNG format
        if let data = pasteboard.data(forType: .png) {
            return YoImageAttachment.from(data: data)
        }
        
        // Try file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            for url in urls {
                if let attachment = YoImageAttachment.from(url: url) {
                    return attachment
                }
            }
        }
        
        return nil
    }
    
    /// Delete the associated image file
    func deleteImageFile() {
        guard let imagePath = imagePath else { return }
        ImageFileManager.shared.deleteImage(at: imagePath)
        self.imagePath = nil
        self.image = nil
    }
    
    /// Check if the image file exists
    var imageFileExists: Bool {
        guard let imagePath = imagePath else { return false }
        return ImageFileManager.shared.imageExists(at: imagePath)
    }
}

