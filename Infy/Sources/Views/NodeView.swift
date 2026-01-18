import AppKit
import SwiftUI

extension Infy {
    open class Element: NSView {
        public var isDragging: Bool = false
        public var isResizing: Bool = false
        public var isResizable: Bool = false
        
        public var mouseOrigin: NSPoint?
        public var mouseDownLocation: NSPoint?
        
        open override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            mouseOrigin = event.locationInWindow
            mouseDownLocation = event.locationInWindow
            if isResizable && canResize(at: event.locationInWindow) {
                isResizing = true
            }
        }
        
        open override func mouseDragged(with event: NSEvent) {
            super.mouseDragged(with: event)
            let loc = event.locationInWindow
            let magnification = (enclosingScrollView?.magnification) ?? 1.0
            
            guard let origin = mouseOrigin else { return }
            
            let deltaX = (loc.x - origin.x) / magnification
            let deltaY = (loc.y - origin.y) / magnification

            if isResizing {
                var newFrame = self.frame
                newFrame.size.width += deltaX
                newFrame.size.height -= deltaY
                
                var newOrigin = loc
                
                let minSize: CGFloat = 100
                if newFrame.width < minSize {
                    newFrame.size.width = minSize
                    newOrigin.x = origin.x
                }
                
                if newFrame.height < minSize {
                    newFrame.size.height = minSize
                    newOrigin.y = origin.y
                }
                
                self.frame = newFrame
                mouseOrigin = newOrigin
            } else {
                var newFrame = self.frame
                newFrame.origin.x += deltaX
                newFrame.origin.y -= deltaY
                self.frame = newFrame
                mouseOrigin = loc
                isDragging = true
            }
        }
        
        open override func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)
            isResizing = false
            isDragging = false
            mouseOrigin = nil
        }

        open func canResize(at point: NSPoint) -> Bool { false }
    }
    
    open class NodeRepresenter<D: Node>: Element, @MainActor NodeRepresentable {
        public var node: D
        public var snapshot: NSImage?

        private var resizeOrigin: NSPoint?
        
        private let resizeHandleSize: CGFloat = 12.0
        private let resizeHandleColor: NSColor = .gray.withAlphaComponent(0.4)

        internal var hosting: (any Hosting<D>)?
        
        open override var isFlipped: Bool { true }

        @MainActor public init(node: D) {
            self.node = node
            super.init(frame: node.frame)
            self.isResizable = true
        }
        
        required public init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        open override func canResize(at point: NSPoint) -> Bool {
            let locationInView = convert(point, from: nil)
            return isPointInResizeHandle(locationInView)
        }
        
        open override func mouseUp(with event: NSEvent) {
            if isResizing {
                hosting?.on(resize: self, frame: self.frame)
            } else if isDragging {
                hosting?.on(move: self, frame: self.frame)
            } else if let downLoc = mouseDownLocation {
                let upLoc = event.locationInWindow
                let distance = hypot(upLoc.x - downLoc.x, upLoc.y - downLoc.y)
                
                if distance < 2 {  // 容忍 5 像素抖动，认为是 click
                    let pointInDocument = convert(upLoc, from: nil)
                    hosting?.on(tap: self, point: pointInDocument)
                }
            }

            super.mouseUp(with: event)
        }
        
        private func isPointInResizeHandle(_ point: NSPoint) -> Bool {
            let handleRect = NSRect(
                x: bounds.maxX - resizeHandleSize - 6,
                y: bounds.maxY - resizeHandleSize - 6,
                width: resizeHandleSize,
                height: resizeHandleSize
            )
            return handleRect.contains(point)
        }
        
        open override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            if isResizable {
                drawResizeHandle()
            }
        }
        
        private func drawResizeHandle() {
            let path = NSBezierPath()
            path.lineWidth = 3.0
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            
            let radius: CGFloat = 5.0
            let spacing: CGFloat = 6.0
            let x = bounds.maxX - spacing
            let y = bounds.maxY - spacing
            
            path.move(to: NSPoint(x: x - resizeHandleSize, y: y))
            path.line(to: NSPoint(x: x - radius, y: y))
            path.appendArc(withCenter: NSPoint(x: x - radius, y: y - radius),
                           radius: radius,
                           startAngle: 90,
                           endAngle: 0,
                           clockwise: true)
            path.line(to: NSPoint(x: x, y: y - resizeHandleSize))
            resizeHandleColor.setStroke()
            path.stroke()
        }
        
        public func update(frame: CGRect) {
            self.frame = frame
            hosting?.on(resize: self, frame: frame)
        }
        
        public func saveSnapshot() async {
            snapshot = await hosting?.snapshot(save: node.id, view: self)
        }
        
        public func getSnapshot() -> NSImage? {
            snapshot = hosting?.snapshot(get: node.id)
            return snapshot
        }
        
        internal func _mount(hosting: (any Hosting<D>)?) {
            self.hosting = hosting
            mount()
        }
        
        open func mount() {}
        
        public func present(menu: NSView?) {
            hosting?.on(node: self, menu: menu)
        }
    }
}
