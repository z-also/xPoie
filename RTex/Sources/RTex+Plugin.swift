import AppKit

extension RTex {
    public func register(plugin: RTex.Plugin) {
        plugins.append(plugin)
        plugin.setup(rtex: self, textView: textView, layoutManager: layoutManager)
    }
    
    func process(result: RTex.Editing) {
        if let selectedRange = result.selectedRange {
            self.textView.selectedRange = selectedRange
            print("[Debug] plugin set selectedRange", selectedRange)
        }
        
        if result.typingAttributes != nil || result.paragraphStyle != nil {
            var attributes = result.typingAttributes ?? [:]

            if let paragraphStyle = result.paragraphStyle {
//                attributes[.paragraphStyle] = paragraphStyle
            }
            
            self.textView.typingAttributes = attributes
        }
        
        print("[Plugin] process result \(result);;; typingAttributes: \(self.textView.typingAttributes)")
    }
}
