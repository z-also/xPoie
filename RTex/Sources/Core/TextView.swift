import AppKit

class TextView: NSTextView {
    var holder: RTex!
    var hosting: RTex.Hosting!
    
    override func keyDown(with event: NSEvent) {
        defer {
            hosting.textView(self, afterKeyDown: event)
        }
        
        let instr = hosting.textView(self, interceptKeyDown: event)

        if instr.behavior == .accept {
            super.keyDown(with: event)
            return
        }
        
        if instr.behavior == .terminate && window?.firstResponder == self {
            self.window?.makeFirstResponder(nil)
            return
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            hosting.textView(self, becomeFirstResponder: self)
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            hosting.textView(self, resignFirstResponder: self)
        }
        return result
    }

    func receive(focus: Bool) {
        if focus {
            self.window?.makeFirstResponder(self)
        } else if self.window?.firstResponder == self {
            self.window?.makeFirstResponder(nil)
        }
    }
    
    override func paste(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        
        for plugin in holder.plugins {
            if plugin.handlePaste(pasteboard, in: self) {
                return
            }
        }
        
        super.paste(sender)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        for plugin in holder.plugins {
            if plugin.canAcceptDrag(sender) {
                return .copy
            }
        }
        return super.draggingEntered(sender)
    }
    
    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        for plugin in holder.plugins {
            if plugin.canAcceptDrag(sender) {
                return .copy
            }
        }
        return super.draggingUpdated(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        for plugin in holder.plugins {
            if plugin.handleDragOperation(sender, in: self) {
                return true
            }
        }
        
        return super.performDragOperation(sender)
    }
    //    override func flagsChanged(with event: NSEvent) {
    //        print("0--====================")
    //        super.flagsChanged(with: event)
    //        holder.delegate?.rtex(holder, flagsChangedWith: event)
    //    }
    //
}
