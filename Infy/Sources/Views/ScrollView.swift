import AppKit

extension Infy {
    public class ScrollView<D: Node>: NSScrollView {
        var hosting: (any Hosting<D>)?
        
        init() {
            super.init(frame: .zero)
            magnification = 1.0
            allowsMagnification = true
            hasHorizontalScroller = true
            hasVerticalScroller = true
            scrollerStyle = .overlay
            
            let clipView = ClipView()
            clipView.drawsBackground = false
            clipView.backgroundColor = .clear
            self.contentView = clipView
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(boundsDidChange),
                name: NSView.boundsDidChangeNotification,
                object: contentView
            )
        }
        
        @objc private func boundsDidChange() {
            hosting?.on(viewport: contentView.bounds)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func scrollWheel(with event: NSEvent) {
            super.scrollWheel(with: event)
        }
        
        public func config(_ config: Config) {
            minMagnification = config.magnification.lowerBound
            maxMagnification = config.magnification.upperBound
        }
    }
}

extension Infy {
    public class ClipView: NSClipView {}
    public class DocumentView<D: Node>: NSView, NSGestureRecognizerDelegate {
        var hosting: (any Hosting<D>)?
        
        public override var isFlipped: Bool { true }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            setupGestureRecognizers()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupGestureRecognizers()
        }
        
        private func setupGestureRecognizers() {
            let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
            clickGesture.numberOfClicksRequired = 1
            clickGesture.numberOfTouchesRequired = 1
            clickGesture.delegate = self
            addGestureRecognizer(clickGesture)
        }
        
        public func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer,
                                      shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
            guard event.type == .leftMouseDown else { return false }
            let point = convert(event.locationInWindow, from: nil)
            let hitView = hitTest(point)
            return hitView === self
        }
        
        var trackingArea: NSTrackingArea?

        override public func updateTrackingAreas() {
            super.updateTrackingAreas()
            
            if let oldArea = trackingArea {
                removeTrackingArea(oldArea)
            }
            
            // 关键：使用当前可见区域，而不是整个 bounds
            let visibleRect = enclosingScrollView?.documentVisibleRect ?? bounds
            
            let options: NSTrackingArea.Options = [
                .mouseMoved,
                .mouseEnteredAndExited,
                .activeAlways
            ]
            
            trackingArea = NSTrackingArea(rect: visibleRect,
                                          options: options,
                                          owner: self,
                                          userInfo: nil)
            addTrackingArea(trackingArea!)
        }
        
        override public func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            let point = self.convert(event.locationInWindow, from: nil)
            let hitView = hitTest(point)
            let nodeView = findNodeRepresenter(from: hitView)
            hosting?.on(hover: nodeView, point: point)
        }
        
        public override func mouseExited(with event: NSEvent) {
            hosting?.on(exited: event.locationInWindow)
        }
        
        @objc private func handleClick(_ gesture: NSClickGestureRecognizer) {
            let point = gesture.location(in: self)
            hosting?.on(tap: point)
        }
        
        private func findNodeRepresenter(from view: NSView?) -> NodeRepresenter<D>? {
            var current = view
            while let v = current {
                if let nodeRep = v as? any NodeRepresentable {
                    return nodeRep as? NodeRepresenter<D>
                }
                current = v.superview
            }
            return nil
        }
    }
}
