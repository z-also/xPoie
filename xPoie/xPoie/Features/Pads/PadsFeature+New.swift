import Infy
import AppKit

class PadFeature_NodeCreateGuide: NSViewController {
    var onCreate: ((Modules.Pads.NodeGenre) -> Void)?
    
    override func loadView() {
        self.view = Infy.Element()
    }
    
    func set(nodeGenres: [Modules.Pads.NodeGenre]) {
        let content = render(nodeGenres: nodeGenres)
        view.frame.size = NSSize(width: 300, height: 400)

        let glass = NSGlassEffectView()
        glass.contentView = content
        glass.cornerRadius = 16
        glass.frame = view.bounds
        
        view.addSubview(glass)
    }
    
    public func detach() {
        if view.superview != nil {
            view.removeFromSuperview()
        }
    }
    
    public func move(to point: CGPoint) {
        view.frame.origin = point
    }
    
    private func render(nodeGenres genres: [Modules.Pads.NodeGenre]) -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.distribution = .gravityAreas
        stack.spacing = 6
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let label = NSTextField(labelWithString: "Suggestions")
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .labelColor
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(label)
        stack.setCustomSpacing(60, after: label)
        
        for (_, genre) in genres.enumerated() {
            let card = NodeGenreCard(data: genre)
            card.onCreate = onCreate
            stack.addArrangedSubview(card)
            card.rightAnchor.constraint(equalTo: stack.rightAnchor,
                                        constant: -stack.edgeInsets.right).isActive = true
        }

        return stack
    }
}

fileprivate class NodeGenreCard: NSButton {
    private let data: Modules.Pads.NodeGenre
    var onCreate: ((Modules.Pads.NodeGenre) -> Void)?
    
    lazy private var icon: NSImageView = {
        let icon = NSImageView()
        let image = NSImage(systemSymbolName: data.icon,
                            accessibilityDescription: data.title)
        icon.image = image
        icon.alphaValue = 0.4
        icon.contentTintColor = .white
        return icon
    }()
    
    lazy private var label: NSTextField = {
        let label = NSTextField(labelWithString: data.title)
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
//    var contentColor: NSColor = .labelColor {
//        didSet {
//            // 直接設定 label
//            label.textColor = contentColor
//            
//            // 強制 icon tint（適用 template image / SF Symbol）
//            if let image = icon.image {
//                let tintedImage = image.copy() as! NSImage
//                tintedImage.isTemplate = true  // 重要！標記為 template
//                icon.image = tintedImage
//                icon.contentTintColor = contentColor  // 10.14+ 有效
//            }
//        }
//    }
    
    init(data: Modules.Pads.NodeGenre) {
        self.data = data
        super.init(frame: .zero)
        self.title = ""
        self.isBordered = false
        self.target = self
        self.action = #selector(onClick(_:))
        buildUI()
    }
    
    @objc private func onClick(_ sender: NSButton) {
        onCreate?(data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            icon.animator().alphaValue = 1.0
            label.animator().alphaValue = 1.0
        })
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            icon.animator().alphaValue = 0.4
            label.animator().alphaValue = 0.7
        })
    }
    
    private func buildUI() {
        wantsLayer = true
        layer?.cornerRadius = 24
        let stack = NSStackView(views: [icon, label])
        stack.orientation = .horizontal
        stack.spacing = 16
        stack.edgeInsets = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override func updateLayer() {
        super.updateLayer()
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
    }
}
