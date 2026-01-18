import SwiftUI

class DelayedTask {
    private var workItem: DispatchWorkItem?
    
    func schedule(delay: Double, closure: @escaping () -> Void) {
        // Cancel any existing work item
        cancel()
        
        // Create new work item
        let item = DispatchWorkItem(block: closure)
        workItem = item
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

// Updated delay function that returns a DelayedTask
func delay(seconds: Double, closure: @escaping () -> Void) -> DelayedTask {
    let task = DelayedTask()
    task.schedule(delay: seconds, closure: closure)
    return task
}
