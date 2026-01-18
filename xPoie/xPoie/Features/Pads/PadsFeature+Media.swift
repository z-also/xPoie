import Infy
import AppKit

class PadFeature_Media: Infy.NodeRepresenter<Modules.Pads.Node> {
    private let mediaThing: Models.Thing
    private let containerView: NSView
    private let button: NSButton
    private let imageView: NSImageView
    private let textField: NSTextField
    
    init(node: Modules.Pads.Node, data: Models.Thing) {
        self.mediaThing = data
        
        // 创建容器视图
        self.containerView = NSView()
        self.containerView.wantsLayer = true
        self.containerView.layer?.backgroundColor = NSColor.gray.withAlphaComponent(0.1).cgColor
        self.containerView.layer?.cornerRadius = 8
        self.containerView.layer?.borderWidth = 1
        self.containerView.layer?.borderColor = NSColor.gray.withAlphaComponent(0.3).cgColor
        
        // 创建图片视图
        self.imageView = NSImageView()
        let image = NSImage(systemSymbolName: "photo.on.rectangle.angled", accessibilityDescription: nil)
        self.imageView.image = image
        self.imageView.contentTintColor = NSColor.gray
        self.imageView.imageScaling = .scaleProportionallyUpOrDown
        
        // 创建文本字段
        self.textField = NSTextField(labelWithString: "click to select media from device")
        self.textField.textColor = NSColor.gray
        self.textField.font = NSFont.systemFont(ofSize: 14)
        self.textField.alignment = .center
        
        // 创建按钮
        self.button = NSButton()
        self.button.bezelStyle = .texturedSquare
        self.button.isBordered = false
        self.button.title = ""
        
        super.init(node: node)
        
        setupView()
        self.button.target = self
        self.button.action = #selector(selectMedia)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // 设置容器视图
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // 设置按钮覆盖整个容器
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
        
        // 设置图片视图
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        // 设置文本字段
        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)
        
        // 添加约束
        NSLayoutConstraint.activate([
            // 容器视图约束
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // 按钮约束
            button.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48),
            button.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 48),
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -48),
            button.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -48),
            
            // 图片视图约束
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48),
            
            // 文本字段约束
            textField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            textField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textField.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor, constant: -32)
        ])
    }
    
    @objc private func selectMedia() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.image]
        openPanel.allowsMultipleSelection = false
        
        // 使用 beginSheetModal 方法，会自动禁止底层窗口交互
        if let window = self.window {
            openPanel.beginSheetModal(for: window) { [weak self] result in
                guard let self = self, result == .OK, let url = openPanel.urls.first else {
                    return
                }
                
                // 这里可以添加媒体文件的处理逻辑
                // 例如：将选中的媒体文件与媒体对象关联
            }
        }
    }
}
