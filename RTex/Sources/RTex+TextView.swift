import AppKit

extension RTex: NSTextViewDelegate {
    public func undoManager(for view: NSTextView) -> UndoManager? {
        undoManager
    }
    
    public func textViewDidChangeSelection(_ notification: Notification) {
        let range = textView.selectedRange()
        let rect = textView.firstRect(forCharacterRange: range, actualRange: nil)
        let cgRect = textView.window?.contentView?.convert(rect, to: nil)
        plugins.forEach { $0.selectionDidChange(range: range) }
        delegate?.rtex(self, didChangeSelection: range)
    }
    
    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        // This will be called for every text change, including IME composition
        revalidatePlaceholderViewVisibility()
        return true // Allow the change
    }

    public func textDidChange(_ notification: Notification) {
        print("[1010] textDidChange")
        if let editing = self.editing {
            process(result: editing)
            self.editing = nil
        }
        let text = contentStorage.textStorage?.attributedSubstring(from: NSRange(location: 0, length: contentStorage.textStorage?.length ?? 0)) ?? NSAttributedString(string: "")
        delegate?.rtex(self, didChange: text)
        revalidatePlaceholderViewVisibility()
    }
    
    public func scrollRangeToVisible(range: NSRange) {
        let contentManager = layoutManager.textContentManager
        let selectedRange = textView.selectedRanges.first?.rangeValue
        
        let documentStart = contentStorage.documentRange.location
        
        guard let selectedRange = selectedRange,
              let startLocation = contentStorage.location(documentStart, offsetBy: selectedRange.location),
              let endLocation = contentStorage.location(startLocation, offsetBy: selectedRange.length),
              let textRange = NSTextRange(location: startLocation, end: endLocation)
        else { return }
        
        layoutManager.ensureLayout(for: textRange)
        
        var boundingRect = CGRect.zero
            
        print("ooooooooo ddd", textView.enclosingScrollView)
        textView.scrollRangeToVisible(range)
    }
    
    
//    func textView(_ textView: NSTextView, didChangeTextIn range: NSRange, replacementString text: String) {
//        print("00000000000000000 ")
//        // 检测是否输入了换行符
//        guard text == "\n" else { return }
//        
//        // 获取当前文本存储
//        guard let textStorage = textView.textStorage else { return }
//        
//        // 计算新行的位置（换行符后的位置）
//        let newLineRange = NSRange(location: range.location + 1, length: 0)
//    
//        // 定义默认段落样式（根据需求调整属性）
//        let defaultParagraphStyle: NSParagraphStyle = {
//            let style = NSMutableParagraphStyle()
//            style.lineHeightMultiple = 1.0
//            style.paragraphSpacing = 0
//            style.firstLineHeadIndent = 0
//            // 其他默认属性...
//            return style.copy() as! NSParagraphStyle
//        }()
//        
//        // 创建默认属性（继承当前字体等，但替换段落样式）
//        var defaultAttributes = textStorage.attributes(at: newLineRange.location, effectiveRange: nil)
//        defaultAttributes[.paragraphStyle] = defaultParagraphStyle
//        
//        // 为新行应用默认样式
//        textStorage.setAttributes(defaultAttributes, range: newLineRange)
//    }
}
