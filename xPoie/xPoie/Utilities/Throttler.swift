import Foundation

@MainActor class Throttler<T> {
    private var params: T!
    private var action: ((T) -> Void)?
    private var interval: TimeInterval = .zero

    private var scheduled = false
    private var remaining: TimeInterval = .zero
    private var lastExecutedAt: Date? = nil

    func set(interval: TimeInterval, action: @escaping (T) -> Void) {
        self.action = action
        self.interval = interval
        self.remaining = interval
    }
    
    func exec(params: T) {
        self.params = params
        
        guard let action = action else { return }
        
        let now = Date()
        let ellapsed = now.timeIntervalSince(lastExecutedAt ?? now)

        if ellapsed >= remaining {
            action(self.params)
            scheduled = false
            remaining = interval
            lastExecutedAt = nil
            return
        }
        
        if !scheduled {
            remaining = interval - ellapsed
            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                self.scheduled = false
                self.exec(params: self.params)
            }
            scheduled = true
        }

        lastExecutedAt = now
    }
}

