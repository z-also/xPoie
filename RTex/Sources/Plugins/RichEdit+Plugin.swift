import AppKit
import SwiftUI

extension RTex {
    public class RichEdit {}
}

extension RTex.RichEdit {
    @Observable public class State {
        public var actives: [RTex.FormatType: Bool] = [:]
    }
}

extension RTex.RichEdit {
    public class Plugin: RTex.Plugin {
        private var toolbarHostingView: NSHostingView<AnyView>?
        private weak var rtex: RTex!
        private weak var textView: NSTextView?
        
        private let rules: [any RTex.FormatRule]
        
        public var state = State()
        
        public init(rules: [RTex.FormatRule]) {
            self.rules = rules
        }
        
        /// 注入 SwiftUI 工具栏视图
        public func setToolbarView<V: View>(_ view: V) {
            toolbarHostingView = NSHostingView(rootView: AnyView(view))
            toolbarHostingView?.isHidden = true
        }
        
        /// 创建带有状态管理的工具栏
        public func createToolbar() {
            let toolbarWithState = ToolbarWithState(plugin: self)
            setToolbarView(toolbarWithState)
        }
        
        /// 设置 TextKit2 组件引用
        public func setup(rtex: RTex, textView: NSTextView, layoutManager: NSTextLayoutManager) {
            self.rtex = rtex
            self.textView = textView
            
            // 自动创建工具栏
            createToolbar()
        }
        
        public func intercept(enter range: NSRange) -> RTex.Editing? {
            let paragraph = rtex.paragraph(at: range)
            let format = rtex.format(forTypingParagraph: paragraph)
            return rule(for: format)?.break(rtex, at: range, paragraph: paragraph)
        }
        
        public func intercept(delete range: NSRange) -> RTex.Editing? {
            let paragraph = rtex.paragraph(at: range)
            let format = rtex.format(forTypingParagraph: paragraph)
            return rule(for: format)?.delete(rtex, at: range, paragraph: paragraph)
        }
        
        public func process(input: Character,
                            in textStorage: NSTextStorage,
                            at range: NSRange) -> RTex.Editing? {
            let string = textStorage.string as NSString
            let lineRange = string.lineRange(for: range)
            let paragraphRange = string.paragraphRange(for: range)
            
            print("[Debug] RichEdit plugin process input: '\(input)' at range: \(range), lineRange:\(lineRange), paragraphRange: \(paragraphRange), paragraph text: '\(string.substring(with: paragraphRange))'")
            
            for rule in rules.filter({ $0.trigger(by: input) }) {
                print("[Debug] hit rule", rule.type)
                if let result = rule.process(rtex, text: string, paragraphRange: paragraphRange, at: range) {
                    print("[Debug] Rule matched! Type: \(result.type), range: \(result.range), replacement: '\(result.replacement)', cursor: \(result.cursor)")
                    
                    rtex.performEditingTransaction {
                        rule.apply(rtex, with: result)
                    }
                    
                    return RTex.Editing(
                        selectedRange: NSRange(location: result.cursor ?? 0, length: 0),
//                        typingAttributes: [.rtexFormat: result.type]
                        typingAttributes: rtex.config.attributes(for: result.type)
                    )
                }
            }
            
            return nil
        }

        public func selectionDidChange(range: NSRange) {
            guard let textView = textView, let toolbar = toolbarHostingView, let rtex = rtex else {
                hideToolbar()
                return
            }
            
            if range.length > 0 {
                updateToolbarState(for: range, in: textView)
                showToolbar(for: range, in: textView, rtex: rtex)
            } else {
                hideToolbar()
            }
        }
        
        private func rule(for type: RTex.FormatType) -> RTex.FormatRule? {
            let rule = rules.first { $0.type == type }
            return rule
        }
        
        /// 更新指定格式的状态
        public func updateState(format: RTex.FormatType, value: Bool) {
            DispatchQueue.main.async {
                self.state.actives[format] = value
            }
        }
        
        
        // 通用的格式切换方法
        private func toggleFormat(_ format: RTex.FormatType) {
            guard let textView = textView else { return }
            
            // 获取当前选中范围
            let range = textView.selectedRange
            
            // 获取当前格式状态，默认为false
            let currentState = state.actives[format] ?? false
            
            // 切换状态
            let newState = !currentState
            
            // 应用新状态
            applyFormat(format, to: range)
            
            // 更新状态
            updateState(format: format, value: newState)
        }
        
        /// 切换粗体格式
        public func toggleBold() {
            toggleFormat(.bold)
        }
        
        /// 切换斜体格式
        public func toggleItalic() {
            toggleFormat(.italic)
        }
        
        /// 切换删除线格式
        public func toggleStrikethrough() {
//            toggleFormat(.strikethrough)
        }
        
        /// 添加链接
        public func addLink() {
//            guard let textView = textView, let window = textView.window else { return }
//            
//            // 显示链接输入对话框
//            let alert = NSAlert()
//            alert.messageText = "添加链接"
//            alert.informativeText = "请输入URL地址"
//            alert.addButton(withTitle: "确定")
//            alert.addButton(withTitle: "取消")
//            
//            // 添加文本输入框
//            let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
//            inputTextField.placeholderString = "https://"
//            alert.accessoryView = inputTextField
//            
//            // 确保文本框获得焦点
//            inputTextField.becomeFirstResponder()
//            
//            // 显示对话框
//            let response = alert.runModal()
//            
//            if response == .alertFirstButtonReturn, let urlString = inputTextField.stringValue, !urlString.isEmpty {
//                // 应用链接格式
//                applyFormat(.link(urlString), to: textView.selectedRange)
//            }
        }
        
        /// 添加代码格式
        public func addCode() {
//            toggleFormat(.code)
        }
        
        // MARK: - 私有辅助方法
        
        /// 应用格式到指定范围
        private func applyFormat(_ format: RTex.FormatType, to range: NSRange) {
            guard let textView = textView,
                  let rtex = rtex else { return }

            // 获取对应的格式规则
            if let rule = rule(for: format) {
                // 调用规则的 apply 方法来应用格式
                rule.apply(rtex, with: .init(type: format, range: range))
            }
        }
        
        /// 更新工具栏状态
        private func updateToolbarState(for range: NSRange, in textView: NSTextView) {
            guard let textStorage = textView.textStorage else { return }
            
            // 重置状态
            var newState = State()
            
            // 使用 rules 计算格式状态
            for rule in rules {
                // 对每个规则，检查选中文本是否匹配
//                let isActive = rule.match(rtex, range: range)
//                
//                // 使用规则的类型作为键设置状态
//                newState.actives[rule.type] = isActive
            }
            
            // 如果没有匹配的规则，对于基本的文本格式（粗体、斜体），我们可以进行回退检查
            if range.length > 0 {
                // 对于粗体和斜体的回退检查，仅在没有对应的规则时执行
                let hasBoldRule = rules.contains { $0.type == .bold }
                let hasItalicRule = rules.contains { $0.type == .italic }
                
                // 只有在没有对应的规则时才进行回退检查
                if !hasBoldRule {
                    hasFontTrait(textStorage, range: range, trait: .boldFontMask) {
                        if $0 {
                            newState.actives[.bold] = true
                        }
                    }
                }
                
                if !hasItalicRule {
                    hasFontTrait(textStorage, range: range, trait: .italicFontMask) {
                        if $0 {
                            newState.actives[.italic] = true
                        }
                    }
                }
            }
            
            // 在主线程更新状态
            DispatchQueue.main.async {
                self.state = newState
            }
        }
        
        // 辅助方法：检查文本范围内的字体特性
        private func hasFontTrait(_ textStorage: NSTextStorage, range: NSRange, trait: NSFontTraitMask, completion: @escaping (Bool) -> Void) {
            var traitCount = 0
            var totalLength = 0
            
            for i in 0..<range.length {
                let location = range.location + i
                if location < textStorage.length {
                    let font = textStorage.attribute(.font, at: location, effectiveRange: nil) as? NSFont
                    if let font = font,
                       NSFontManager.shared.traits(of: font).contains(trait) {
                        traitCount += 1
                    }
                    totalLength += 1
                }
            }
            
            completion(totalLength > 0 && traitCount == totalLength)
        }
        
        private func showToolbar(for range: NSRange, in textView: NSTextView, rtex: NSView) {
            guard let toolbar = toolbarHostingView, let window = rtex.window else { return }
            if toolbar.superview != rtex {
                rtex.addSubview(toolbar)
            }
            let rectInScreen = textView.firstRect(forCharacterRange: range, actualRange: nil)
            let rectInWindow = window.convertFromScreen(rectInScreen)
            let rectInRTex = rtex.convert(rectInWindow, from: nil)
            let toolbarSize = toolbar.fittingSize
            
            // 计算初始位置
            var x = rectInRTex.midX - toolbarSize.width / 2
            var y = rectInRTex.minY - toolbarSize.height - 8
            
            // 添加边界限制，确保 toolbar 完全显示在 RTex 内部
            // 水平边界限制
            let rtexWidth = rtex.bounds.width
            x = max(0, min(x, rtexWidth - toolbarSize.width))
            
            // 垂直边界限制
            let rtexHeight = rtex.bounds.height
            y = max(0, min(y, rtexHeight - toolbarSize.height))
            
            toolbar.frame = NSRect(x: x, y: y, width: toolbarSize.width, height: toolbarSize.height)
            toolbar.isHidden = false
            toolbar.translatesAutoresizingMaskIntoConstraints = true
        }
        
        private func hideToolbar() {
            toolbarHostingView?.isHidden = true
        }
    }
}


// MARK: - 工具栏状态视图

private struct ToolbarWithState: View {
    var plugin: RTex.RichEdit.Plugin
    private var state: RTex.RichEdit.State
    
    init(plugin: RTex.RichEdit.Plugin) {
        self.plugin = plugin
        self.state = plugin.state
    }
    
    var body: some View {
        // 简洁的工具栏实现
        YoRichEditToolbar(
            // 保持现有的操作回调
            onBold: { plugin.toggleBold() },
            onItalic: { plugin.toggleItalic() },
            onLink: { plugin.addLink() },
            onCode: { plugin.addCode() },
            // 直接访问actives字典获取状态，默认为false
            isBold: state.actives[.bold] ?? false,
            isItalic: state.actives[.italic] ?? false
        )
    }
}

//    public func intercept(input char: Character, at range: NSRange) -> RTex.Editing? {
//        print("[RichEdit] intercept input: '\(char)' at range: \(range), typingAttributes: \(rtex.textView.typingAttributes)")
//
//        return nil
//
//        let isNewLine = char == "\n" || char == "\r"
//        guard isNewLine else { return nil }
//
//        guard let rtexFormat = rtex.textView.typingAttributes[.rtexFormat] as? RTex.FormatType,
//              let formatRule = RTex.FormatRulesSet.rule(for: rtexFormat) else {
//            return nil
//        }
//
//        guard rtexFormat != .body else {
//            return nil
//        }
//
//        guard let content = rtex.contentStorage.attributedString,
//              let textStorage = rtex.textView.textStorage else { return nil }
//
//        let string = content.string as NSString
//        let paragraphRange = string.paragraphRange(for: range)
//        let paragraphContent = content.attributedSubstring(from: paragraphRange)
//
//        print("ggggggggggggggggg paragraphRange: \(paragraphRange), total: \(string.length), cursor: \(range.location), formatRule: \(formatRule)")
//
//        // 空段落：统一退出当前格式，恢复正文
//        if paragraphContent.string.isEmpty || paragraphContent.string == "\n" {
//
//            rtex.performEditingTransaction {
////                formatRule.remove(from: textStorage, range: paragraphRange, config: self.rtex.config)
//                rtex.textView.typingAttributes = rtex.config.attributes(for: .body)
//                textStorage.insert(NSAttributedString(string: "",attributes: rtex.config.attributes(for: .body)), at: range.upperBound)
//            }
//
//            return RTex.Editing(
//                behavior: .ignore,
//                selectedRange: NSRange(location: paragraphRange.location, length: 0),
//                typingAttributes: rtex.config.attributes(for: .body)
//            )
//        }
//
//
//        rtex.performEditingTransaction {
////                formatRule.remove(from: textStorage, range: paragraphRange, config: self.rtex.config)
////            rtex.textView.typingAttributes = rtex.config.attributes(for: .body)
//            textStorage.insert(NSAttributedString(string: "\n",attributes: [.rtexFormat: rtexFormat]), at: range.upperBound)
//
//        }
//
//
//
//        return RTex.Editing(
//            behavior: .ignore
////                selectedRange: NSRange(location: paragraphRange.location, length: 0),
////                typingAttributes: rtex.config.attributes(for: .body)
//        )
//
//        return nil
//
//        let editing = formatRule.onNewline(currentLine: paragraphContent, config: rtex.config)
//
//        print("[RichEditPlugin] onNewline, formatRule: \(formatRule), result: \(editing)")
//
//        return editing
//
////        rtex.performEditingTransaction {
////            let insertAttr = NSMutableAttributedString()
////            insertAttr.append(NSAttributedString(string: "\n", attributes: [.rtexFormat: RTex.FormatType.blockquote]))
////            textStorage.replaceCharacters(in: range, with: insertAttr)
////        }
////
////        return RTex.Editing(
////            behavior: .accept,
////            selectedRange: NSRange(location: range.location, length: 0)
////        )
//
//        // 非空段落：尝试规则续行
////        if let (prefix, attrs) = formatRule.onNewline(currentLine: textStorage.attributedSubstring(from: paragraphRange), config: rtex.config) {
////            rtex.performEditingTransaction {
////                let insertAttr = NSMutableAttributedString()
////                insertAttr.append(NSAttributedString(string: "\n"))
////                insertAttr.append(NSAttributedString(string: prefix, attributes: attrs))
////                textStorage.replaceCharacters(in: range, with: insertAttr)
////            }
////            return RTex.Editing(
////                behavior: .ignore,
////                selectedRange: NSRange(location: range.location + 1 + prefix.count, length: 0),
////                typingAttributes: attrs
////            )
////        }
//
//        // 无续行：接受换行，同时切到正文属性
//        return RTex.Editing(
//            behavior: .accept,
//            typingAttributes: rtex.config.attributes(for: .body)
//        )
//    }
    
//public func process(input: Character, in textStorage: NSTextStorage, at range: NSRange) -> RTex.Editing? {
//    let isNewLine = input == "\n" || input == "\r"
//    
//    let string = textStorage.string as NSString
//    let lineRange = string.lineRange(for: range)
//    let paragraphRange = string.paragraphRange(for: range)
//
//    print("[RichEdit] process range: \(range), isNewLine: \(isNewLine), lineRange:\(lineRange), paragrapRange: \(paragraphRange), paragraphContent: '\(string.substring(with: paragraphRange))'")
//    
//    guard isNewLine else { return nil }
//    
////        return RTex.Editing(
////            behavior: .accept,
////            selectedRange: NSRange(location: range.location + 1, length: 0)
////        )
//    
//    rtex.textView.scrollRangeToVisible(range)
//    
//    return nil
//}
//
