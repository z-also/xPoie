import AppKit
import SwiftUI

public class YoImagePlugin: RTex.Plugin {
    private weak var rtex: RTex!
    private weak var textView: NSTextView?
    private weak var layoutManager: NSTextLayoutManager?
    
    private var imageConfig: RTex.ImageConfig {
        return rtex?.config.imageConfig ?? RTex.ImageConfig()
    }
    
    public init() {}
    
    public func setup(rtex: NSView, textView: NSTextView, layoutManager: NSTextLayoutManager) {
        self.rtex = rtex as? RTex
        self.textView = textView
        self.layoutManager = layoutManager
        
        textView.registerForDraggedTypes([.fileURL, .png, .tiff])
    }
    
    public func selectionDidChange(range: NSRange, rect: CGRect?) {
        // Handle selection changes if needed for image operations
    }
    
    public func process(input: Character, in textStorage: NSTextStorage, at range: NSRange) -> RTex.Editing? {
        // Handle special image-related characters if needed
        return nil
    }
    
    public func handlePaste(_ pasteboard: NSPasteboard, in textView: NSTextView) -> Bool {
        guard let rtex = rtex else { return false }
        guard imageConfig.allowPaste else { return false }
        
        // Direct attachment creation - no manager needed
        guard let imageAttachment = YoImageAttachment.from(pasteboard: pasteboard) else { return false }
        
        configureAttachment(imageAttachment)
        insertImageAttachment(imageAttachment, in: textView)
        
        // Notify delegate
        if let textStorage = textView.textStorage {
            rtex.delegate?.rtex(rtex, didChange: textStorage)
        }
        
        return true
    }
    
    public func canAcceptDrag(_ sender: NSDraggingInfo) -> Bool {
        guard let rtex = rtex else { return false }
        guard imageConfig.allowDragDrop else { return false }
        
        // Direct check - simplified logic
        let pasteboard = sender.draggingPasteboard
        return pasteboard.availableType(from: [.tiff, .png]) != nil ||
               (pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL])?.contains { url in
                   ["png", "jpg", "jpeg", "gif", "tiff", "heic", "webp"].contains(url.pathExtension.lowercased())
               } ?? false
    }
    
    public func handleDragOperation(_ sender: NSDraggingInfo, in textView: NSTextView) -> Bool {
        guard let rtex = rtex else { return false }
        guard imageConfig.allowDragDrop else { return false }
        
        // Direct drag handling
        let pasteboard = sender.draggingPasteboard
        guard let imageAttachment = YoImageAttachment.from(pasteboard: pasteboard) else { return false }
        
        // Set cursor at drop location
        let dropPoint = textView.convert(sender.draggingLocation, from: nil)
        let charIndex = textView.characterIndexForInsertion(at: dropPoint)
        textView.setSelectedRange(NSRange(location: charIndex, length: 0))
        
        configureAttachment(imageAttachment)
        insertImageAttachment(imageAttachment, in: textView)
        
        // Notify delegate
        if let textStorage = textView.textStorage {
            rtex.delegate?.rtex(rtex, didChange: textStorage)
        }
        
        return true
    }
    
    // MARK: - Public Image Operations
    
    /// Insert an image from a URL
    public func insertImage(from url: URL) {
        guard let textView = textView else { return }
        guard let imageAttachment = YoImageAttachment.from(url: url) else { return }
        configureAttachment(imageAttachment)
        insertImageAttachment(imageAttachment, in: textView)
    }
    
    /// Insert an image from data
    public func insertImage(from data: Data) {
        guard let textView = textView else { return }
        guard let imageAttachment = YoImageAttachment.from(data: data) else { return }
        configureAttachment(imageAttachment)
        insertImageAttachment(imageAttachment, in: textView)
    }
    
    /// Insert an NSImage directly
    public func insertImage(_ image: NSImage) {
        guard let textView = textView else { return }
        let imageAttachment = YoImageAttachment(image: image)
        configureAttachment(imageAttachment)
        insertImageAttachment(imageAttachment, in: textView)
    }
    
    /// Show image picker dialog
    public func showImagePicker() {
        guard let textView = textView else { return }
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.png, .jpeg, .gif, .tiff, .bmp, .ico, .heic, .heif, .webP]
        panel.title = "Select Image"
        panel.message = "Choose an image to insert"
        
        if panel.runModal() == .OK, let url = panel.url {
            insertImage(from: url)
        }
    }
    
    // MARK: - Helper Methods
    
    private func configureAttachment(_ attachment: YoImageAttachment) {
        attachment.setMaxSize(width: imageConfig.maxWidth, height: imageConfig.maxHeight)
    }
    
    private func insertImageAttachment(_ attachment: YoImageAttachment, in textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        
        // Create centered attributed string
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 8
        paragraphStyle.paragraphSpacingBefore = 4
        
        attachmentString.addAttributes([.paragraphStyle: paragraphStyle], 
                                     range: NSRange(location: 0, length: attachmentString.length))
        attachmentString.append(NSAttributedString(string: "\n", attributes: [.paragraphStyle: paragraphStyle]))
        
        // Insert at current selection
        let range = textView.selectedRange()
        textStorage.replaceCharacters(in: range, with: attachmentString)
        
        // Update cursor position
        let newLocation = range.location + attachmentString.length
        textView.setSelectedRange(NSRange(location: newLocation, length: 0))
        
        // Force layout update
        textView.needsLayout = true
        if let layoutManager = textView.textLayoutManager {
            layoutManager.invalidateLayout(for: layoutManager.documentRange)
        }
    }
    
    /// Get all image attachments in the text
    public func getAllImages() -> [(range: NSRange, attachment: YoImageAttachment)] {
        guard let textView = textView, let textStorage = textView.textStorage else { return [] }
        
        var images: [(range: NSRange, attachment: YoImageAttachment)] = []
        let fullRange = NSRange(location: 0, length: textStorage.length)
        
        textStorage.enumerateAttribute(.attachment, in: fullRange) { value, range, _ in
            if let attachment = value as? YoImageAttachment {
                images.append((range: range, attachment: attachment))
            }
        }
        
        return images
    }
    
    /// Remove image at specific range and clean up associated file
    public func removeImage(at range: NSRange) {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        
        // Clean up file before deletion
        textStorage.enumerateAttribute(.attachment, in: range) { value, _, _ in
            if let attachment = value as? YoImageAttachment {
                attachment.deleteImageFile()
            }
        }
        
        textStorage.deleteCharacters(in: range)
    }
    
    /// Replace image at specific range and clean up old file
    public func replaceImage(at range: NSRange, with newImage: NSImage) {
        guard let textView = textView, let textStorage = textView.textStorage else { return }
        
        // Clean up old image
        textStorage.enumerateAttribute(.attachment, in: range) { value, _, _ in
            if let attachment = value as? YoImageAttachment {
                attachment.deleteImageFile()
            }
        }
        
        let attachment = YoImageAttachment(image: newImage)
        configureAttachment(attachment)
        
        let imageString = NSAttributedString(attachment: attachment)
        textStorage.replaceCharacters(in: range, with: imageString)
    }
    
    /// Update image size constraints and refresh all images
    public func updateImageSizeConstraints(maxWidth: CGFloat, maxHeight: CGFloat) {
        // Update the source configuration instead of local copies
        // Note: This would require YoImageConfig to be mutable
        // For now, we can update existing images with new constraints
        guard let textView = textView else { return }
        
        let images = getAllImages()
        for (_, attachment) in images {
            attachment.setMaxSize(width: maxWidth, height: maxHeight)
        }
        
        textView.needsLayout = true
    }
    
    /// Clean up orphaned image files
    public func cleanupOrphanedImages() {
        // Simplified - rely on manual cleanup when removing images
        // Could be extended to scan directory vs current attachments if needed
    }
    
    /// Get the current image storage directory for debugging
    public var imageStorageDirectory: URL? {
        return ImageFileManager.shared.currentImageDirectory
    }
}
    
// MARK: - Image Toolbar Extension

public extension YoImagePlugin {
    /// Create a toolbar button for image insertion
    func createImageToolbarButton() -> some View {
        Button(action: showImagePicker) {
            Image(systemName: "photo")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(NSColor.labelColor))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.clear)
        )
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .help("Insert Image (stored in iCloud)")
    }
}
