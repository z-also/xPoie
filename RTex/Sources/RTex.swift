import AppKit

open class RTex: NSView {
    let textView: TextView
    let container: TextContainer
    let layoutManager: LayoutManager
    let contentStorage: ContentStorage
    
    var config: RTex.Config
    var plugins: [RTex.Plugin] = []
    public weak var delegate: RTex.Delegate?
    
    internal var placeholder: NSView?
    
    override open var isFlipped: Bool { true }
    
    private var mounted = false
    
    var editing: Editing?

    public init(config: RTex.Config) {
        self.config = config
        layoutManager = LayoutManager()
        contentStorage = ContentStorage()

        container = TextContainer(size: .zero)
        container.widthTracksTextView = true
        container.heightTracksTextView = false
        container.lineFragmentPadding = .zero

        layoutManager.textContainer = container
        contentStorage.addTextLayoutManager(layoutManager)

        textView = TextView(frame: .zero, textContainer: container)
        textView.backgroundColor = .clear
        textView.typingAttributes = config.typingAttributes
        textView.textContainerInset = .zero

        super.init(frame: .zero)

        addSubview(textView)
        textView.holder = self
        textView.hosting = self
        textView.delegate = self
        textView.allowsUndo = true
        layoutManager.delegate = self
        contentStorage.delegate = self
        contentStorage.textStorage?.delegate = self

        Utilities.constraint(textView, to: self)
        Utilities.constraint(self, to: superview)

        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NotificationCenter.default.addObserver(forName: NSTextView.willSwitchToNSLayoutManagerNotification, object: textView, queue: .main) { _ in
            print("[RTex] willSwitchToNSLayoutManagerNotification: TextKit1 fallback about to happen!")
        }
        NotificationCenter.default.addObserver(forName: NSTextView.didSwitchToNSLayoutManagerNotification, object: textView, queue: .main) { _ in
            print("[RTex] didSwitchToNSLayoutManagerNotification: TextKit1 fallback happened!")
        }
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func set(text: NSAttributedString) {
        contentStorage.textStorage?.setAttributedString(text)
        if Utilities.isEmpty(text) {
            set(typingAttributes: config.attributes(for: .body))
        }
        revalidatePlaceholderViewVisibility()
    }

    public func set(config: RTex.Config) {
        self.config = config
        set(text: contentStorage.attributedString!)
    }
    
    public func receive(focus: Bool) {
        textView.receive(focus: focus)
    }

    public func revalidateSize() {
        let rect = Utilities.calcContentRect(layoutManager: layoutManager, contentStorage: contentStorage)
        delegate?.rtex(self, onSizeChanged: rect.size)
    }
    
    open override func viewDidMoveToWindow() {
        guard mounted == false else { return }
        mounted = true
        revalidateSize()
        delegate?.rtex(self, didMount: textView)
    }
    
    public var cursorRect: CGRect? {
        let range = textView.selectedRange()
        return textView.firstRect(forCharacterRange: range, actualRange: nil)
    }
    
    public func insertText(_ text: String) {
        textView.insertText(text, replacementRange: textView.selectedRange())
    }
    
    public var selectedRange: NSRange {
        return textView.selectedRange()
    }
    
    public func setSelectedRange(_ range: NSRange) {
        textView.selectedRange = range
    }
}
