import AppKit

public extension RTex {
    func set(placeholder: NSView) {
        self.placeholder = placeholder
        revalidatePlaceholderViewVisibility()
    }
    
    func revalidatePlaceholderViewVisibility() {
        if textView.hasMarkedText() {
            toggle(placeholder: false)
        } else {
            toggle(placeholder: contentStorage.attributedString?.length == 0)
        }
    }
    
    func toggle(placeholder visible: Bool) {
        guard let placeholder = placeholder else {
            return
        }
        
        if placeholder.superview != nil {
            if !visible {
                placeholder.removeFromSuperview()
            }
        } else if visible {
            addSubview(placeholder, positioned: .below, relativeTo: textView)
            Utilities.constraint(placeholder, to: self)
        }
    }
}
