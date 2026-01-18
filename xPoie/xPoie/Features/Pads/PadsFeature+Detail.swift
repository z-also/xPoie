import RTex
import AppKit
import SwiftUI

fileprivate class TitleField: RTex, RTex.Delegate {
    private var config: RTexc
    private var placeholder: String
    @MainActor var onSizeChanged: ((CGSize) -> Void)?
    @MainActor var onContentChange: ((NSAttributedString) -> Void)?
    @MainActor var onSubmit: (() -> Void)?
    
    init(placeholder: String) {
        self.placeholder = placeholder
        self.config = RTexc(typography: .h1)
        super.init(config: config)
        self.delegate = self
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rtex(_ rtex: RTex, didMount textView: NSTextView) {
        let placeholder = RTex_Placeholder(string: placeholder, typography: config.typography)
        rtex.set(placeholder: NSHostingView(rootView: placeholder))
    }

    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {
        onSizeChanged?(size)
    }
    
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {
        onContentChange?(text)
    }
    
    func rtex(_ rtex: RTex, intercept textView: NSTextView, keyDown event: NSEvent) -> RTex.Editing? {
        if RTex.U.isTab(event: event) || RTex.U.isEnter(event: event) {
            defer { self.onSubmit?() }
            return .ignore
        }
        return nil
    }
}

fileprivate class ContentField: RTex, RTex.Delegate {
    private var config: RTexc
    private var placeholder: String
    @MainActor var onSizeChanged: ((CGSize) -> Void)?
    @MainActor var onContentChange: ((NSAttributedString) -> Void)?
    
    init(placeholder: String) {
        self.placeholder = placeholder
        self.config = RTexcOmni(typography: .body)
        super.init(config: config)
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
    
    func rtex(_ rtex: RTex, didChangeSelection range: NSRange) {
        self.scrollRangeToVisible(range: range)
    }
    func rtex(_ rtex: RTex, didMount textView: NSTextView) {
        let placeholder = RTex_Placeholder(string: placeholder, typography: config.typography)
        rtex.set(placeholder: NSHostingView(rootView: placeholder))
    }

    func rtex(_ rtex: RTex, onSizeChanged size: CGSize) {
        onSizeChanged?(size)
    }
    
    func rtex(_ rtex: RTex, didChange text: NSAttributedString) {
        onContentChange?(text)
    }
}

fileprivate class ClipView: NSClipView {
    override var isFlipped: Bool { true }
}

fileprivate class StackView: NSStackView {
    override var isFlipped: Bool { true }
}

class PadDetailController: NSViewController {
    private var note: Models.Note?
    private var titleFieldHeightConstraint: NSLayoutConstraint?
    private var contentFieldHeightConstraint: NSLayoutConstraint?
    private var padding = NSEdgeInsets(top: 20, left: 56, bottom: 52, right: 56)

    private lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = false
        scroll.autohidesScrollers = true
        scroll.drawsBackground = false
        return scroll
    }()
    
    private lazy var clipView: ClipView = {
        let clipView = ClipView()
        clipView.drawsBackground = false
        clipView.translatesAutoresizingMaskIntoConstraints = false
        return clipView
    }()
    
    private lazy var stackView: StackView = {
        let stack = StackView(views: [titleField, contentField])
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.distribution = .gravityAreas
        stack.edgeInsets = padding
        return stack
    }()
    
    private lazy var titleField: TitleField = {
        let field = TitleField(placeholder: "Title")
        field.onSizeChanged = { [weak self] size in
            self?.onTitleFieldSizeChanged(size: size)
        }
        field.onContentChange = { [weak self] text in
            self?.note?.title = text.string
        }
//        field.wantsLayer = true
//        field.layer?.backgroundColor = NSColor.green.cgColor
        return field
    }()
    
    private lazy var contentField: ContentField = {
        let field = ContentField(placeholder: "Content")
        field.onSizeChanged = { [weak self] size in
            self?.onContentFieldSizeChanged(size: size)
        }
        field.onContentChange = { [weak self] text in
            self?.note?.content = text.toAttributedString()
        }
        return field
    }()

    override func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer?.zPosition = 1000
        self.view = view
        setupLayout()
        
        titleField.onSubmit = { self.contentField.receive(focus: true) }
    }
    
    private func setupLayout() {
        scrollView.contentView = clipView
        scrollView.documentView = stackView
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            clipView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            clipView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            clipView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            clipView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            stackView.widthAnchor.constraint(equalTo: clipView.widthAnchor),
            
            titleField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -padding.left - padding.right),
            contentField.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -padding.left - padding.right),
        ])
        
        titleField.heightAnchor.constraint(equalToConstant: 33).isActive = true
        
        contentFieldHeightConstraint = contentField.heightAnchor.constraint(equalToConstant: 600)
        contentFieldHeightConstraint?.priority = .defaultHigh
        contentFieldHeightConstraint?.isActive = true
        
        let minHeight = stackView.heightAnchor.constraint(greaterThanOrEqualTo: clipView.heightAnchor)
        minHeight.priority = .required
        minHeight.isActive = true
    }
    
    @MainActor func onTitleFieldSizeChanged(size: CGSize) {
        //
    }
    
    @MainActor private func onContentFieldSizeChanged(size: CGSize) {
        let newHeight = max(size.height, 300)
        if contentFieldHeightConstraint?.constant != newHeight {
            contentFieldHeightConstraint?.constant = newHeight
            triggerLayoutUpdate()
        }
    }
    
    @MainActor private func triggerLayoutUpdate() {
        stackView.invalidateIntrinsicContentSize()
        stackView.layoutSubtreeIfNeeded()
        scrollView.documentView?.layoutSubtreeIfNeeded()
        scrollView.flashScrollers()
    }
    
    public func set(note: Models.Note) {
        self.note = note
        titleField.set(text: NSAttributedString(string: note.title))
        contentField.set(text: note.content.toNSAttributedString())
        DispatchQueue.main.async {
            self.triggerLayoutUpdate()
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        triggerLayoutUpdate()
    }
    
    public func snapshotRoot() -> NSView {
        return stackView
    }
}
