import Infy
import RTex
import AppKit
import SwiftUI

fileprivate class TitleField: RTex, RTex.Delegate {
    private var data: Models.Note
    private var config: RTexc
    private var placeholder: String
    @MainActor var onSizeChanged: ((CGSize) -> Void)?

    init(data: Models.Note) {
        self.data = data
        self.config = RTexc(typography: .h4)
        self.placeholder = "Title"
        super.init(config: config)
        self.delegate = self
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rtex(_ rtex: RTex, didMount textView: NSTextView) {
        rtex.set(placeholder: NSHostingView(
            rootView: RTex_Placeholder(string: placeholder, typography: config.typography)
        ))
    }

    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {
        onSizeChanged?(size)
    }
    
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {
        data.title = text.string
    }
}

fileprivate class ContentField: RTex, RTex.Delegate {
    private var data: Models.Note
    @MainActor var onSizeChanged: ((CGSize) -> Void)?

    init(data: Models.Note) {
        self.data = data
        super.init(config: RTexc(typography: .tip))
        self.delegate = self
        
        register(plugin: RTex.RichEdit.Plugin(
            rules: [
                RTex.BoldFormatRule(),
                RTex.ItalicFormatRule(),
                RTex.BlockQuoteFormatRuleWithMarkdownSupport(),
                RTex.UnorderedListFormatRuleWithMarkdownSupport(),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 1),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 2),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 3),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 4),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 5),
                RTex.HeadingFormatRuleWithMarkdownSupport(level: 6)
            ]
        ))
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {
        onSizeChanged?(size)
    }
    
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {
        data.content = text.toAttributedString()
    }
}

class PadFeatureNote2: Infy.NodeRepresenter<Modules.Pads.Node> {
    private var data: Models.Note
    private var realView: NSView?
    private var isActive: Bool = false
    
    var coordinator: Modules.Pads.Coordinator?
    
    private lazy var menubar: Menubar = {
        let res = Menubar(onAction: { a in self.handleMenu(action: a) })
        return res
    }()

    init(node: Modules.Pads.Node, data: Models.Note) {
        self.data = data
        super.init(node: node)
        wantsLayer = true
//        layer?.borderColor = NSColor(Modules.vars.theme.fill.popover).cgColor
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderWidth = 1.0
        layer?.cornerRadius = 12.0
        layer?.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var snapshotView: NSImageView = {
        let v = NSImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var editableContentView: Content = {
        let v = Content(data: data)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private func display(view: NSView) {
        realView?.removeFromSuperview()
        
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        realView = view
    }

    override public func mount() {
        setActive(false)
    }
    
    private func displaySnapshotView() {
        if let img = getSnapshot() {
            snapshotView.image = img
            display(view: snapshotView)
        } else {
            display(view: editableContentView)
        }
    }
    
    private func displayEditableContentView() {
        display(view: editableContentView)
    }
    
    func setActive(_ active: Bool) {
        isActive = active
        layer?.borderColor = active ? NSColor.secondaryLabelColor.cgColor : NSColor.clear.cgColor

        if isActive {
            displayEditableContentView()
            present(menu: menubar)
        } else {
            Task {
                present(menu: nil)
                if realView != nil {
                    await saveSnapshot()
                }
                displaySnapshotView()
            }
        }
        
        isResizable = active
        needsDisplay = true
    }
    
    
    private func handleMenu(action: Action) -> Void {
        switch action.type {
        case .expand:
            coordinator?.present(detail: self)
        case .sticky:
            NotesFeatureSticky.shared.toggleSticky(for: data)
        }
    }
    
    override func updateLayer() {
        super.updateLayer()
//        layer?.borderColor = NSColor(Modules.vars.theme.fill.popover).cgColor
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
}

fileprivate class Content: NSView {
    private var data: Models.Note
    private var padding: CGFloat = 16
    private let minimumTotalHeight: CGFloat = 200
    private var titleFieldHeightConstraint: NSLayoutConstraint?
    
    var updateFrame: ((NSRect) -> Void)?

    private lazy var titleField: TitleField = {
        let field = TitleField(data: data)
        field.onSizeChanged = { self.onTitleFieldSizeChanged(size: $0) }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private lazy var contentField: ContentField = {
        let field = ContentField(data: data)
        field.onSizeChanged = { self.onContentFieldSizeChanged(size: $0) }
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    init(data: Models.Note) {
        self.data = data
        super.init(frame: .zero)
        build()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func build() {
        addSubview(titleField)
        addSubview(contentField)
        
        titleFieldHeightConstraint = titleField.heightAnchor.constraint(equalToConstant: 120)
        titleFieldHeightConstraint?.priority = .required - 1
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            titleField.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
            titleField.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding),
            titleFieldHeightConstraint!,

            contentField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: padding),
            contentField.leftAnchor.constraint(equalTo: leftAnchor, constant: padding),
            contentField.rightAnchor.constraint(equalTo: rightAnchor, constant: -padding),
            contentField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
        
        titleField.set(text: NSAttributedString(string: data.title))
        contentField.set(text: NSAttributedString(data.content))
    }
    
    @MainActor private func onTitleFieldSizeChanged(size: CGSize) {
//        let titleFieldHeight = max(size.height, 48)
//        let contentFieldHeight = contentField.frame.height
//        titleFieldHeightConstraint?.constant = titleFieldHeight
//        revalidateFrame(titleFieldHeight: titleFieldHeight, contentFieldHeight: contentFieldHeight)
    }
    
    @MainActor private func onContentFieldSizeChanged(size: CGSize) {
//        let titleFieldHeight = titleField.frame.height
//        let contentFieldHeight = max(size.height, 100)
//        revalidateFrame(titleFieldHeight: titleFieldHeight, contentFieldHeight: contentFieldHeight)
    }
    
    private func revalidateFrame(titleFieldHeight: CGFloat, contentFieldHeight: CGFloat) {
        let newTotalHeight = max(
            minimumTotalHeight,
            padding + titleFieldHeight + padding + contentFieldHeight + padding
        )
        
        var newFrame = self.frame
        guard newTotalHeight != newFrame.height else { return }
        
        newFrame.size.height = newTotalHeight
        updateFrame?(newFrame)
    }
}

fileprivate struct Action {
    let icon: String
    let type: `Type`
    
    enum `Type` {
        case expand
        case sticky
    }
}

fileprivate class Menubar: NSView {
    private var onAction: (Action) -> Void
    
    init(onAction: @escaping (Action) -> Void) {
        self.onAction = onAction
        super.init(frame: .zero)
        build()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentView: NSStackView = {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 4
        stack.edgeInsets = NSEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func build() {
        wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false
        
        let actions: [Action] = [
            .init(icon: "arrow.down.backward.and.arrow.up.forward", type: .expand),
            .init(icon: "rectangle.on.rectangle", type: .sticky)
        ]
        
        actions.forEach { action in
            let btn = MenuItem(data: action, onAction: onAction)
            contentView.addArrangedSubview(btn)
        }
        
        let glass = NSGlassEffectView()
        glass.contentView = contentView
        glass.cornerRadius = 999
        addSubview(glass)
        
        glass.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glass.leadingAnchor.constraint(equalTo: leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: trailingAnchor),
            glass.topAnchor.constraint(equalTo: topAnchor),
            glass.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

fileprivate class MenuItem: NSButton {
    private let data: Action
    var onAction: ((Action) -> Void)?
    
    lazy private var icon: NSImageView = {
        let icon = NSImageView()
        let image = NSImage(systemSymbolName: data.icon,
                            accessibilityDescription: "")
        icon.image = image
        icon.alphaValue = 0.4
        icon.contentTintColor = .labelColor
        return icon
    }()
    
    init(data: Action, onAction: ((Action) -> Void)?) {
        self.data = data
        super.init(frame: .zero)
        self.title = ""
        self.isBordered = false
        self.target = self
        self.onAction = onAction
        self.action = #selector(onClick(_:))
        buildUI()
    }
    
    @objc private func onClick(_ sender: NSButton) {
        onAction?(data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            icon.animator().alphaValue = 1.0
        })
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            icon.animator().alphaValue = 0.4
        })
    }
    
    private func buildUI() {
        wantsLayer = true
        let stack = NSStackView(views: [icon])
        stack.orientation = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.wantsLayer = true
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),

            icon.widthAnchor.constraint(equalToConstant: 26),
            icon.heightAnchor.constraint(equalToConstant: 26)
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
//        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
    }
}
