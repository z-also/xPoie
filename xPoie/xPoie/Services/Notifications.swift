import UserNotifications

class Notifications: NSObject {
    nonisolated(unsafe) static let shared = Notifications()
    
    // 请求通知权限
    static func requestAuthorization() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    // 全局权限检查和请求（复用现有，但添加返回 Bool 表示是否授权）
    static func ensureAuthorization() async -> Bool {
        let status = await checkAuthorizationStatus()
        if status == .authorized {
            return true
        }
        do {
            return try await requestAuthorization()
        } catch {
            print("Failed to request authorization: \(error)")
            return false
        }
    }
    
    // 创建 x 分钟后的通知
    static func scheduleNotification(afterMinutes minutes: Int,
                            title: String,
                            body: String, 
                            identifier: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    static func cancelNotification(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    static func cancel(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // 检查通知权限状态
    static func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    
    static func scheduleNotification(at date: Date,
                               title: String,
                               body: String, 
                               identifier: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    static func schedule(when: Date,
                         title: String,
                         body: String,
                         identifier: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: when)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await UNUserNotificationCenter.current().add(request)
    }

    static func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}

// 单独实现 UNUserNotificationCenterDelegate
extension Notifications: UNUserNotificationCenterDelegate {
    // 用户点击通知时的处理
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              didReceive response: UNNotificationResponse, 
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let identifier = response.notification.request.identifier
        
        // 在这里处理通知点击事件
        handleNotificationTap(identifier: identifier, userInfo: userInfo)
        
        completionHandler()
    }
    
    // 应用在前台时收到通知的处理
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                              willPresent notification: UNNotification, 
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 即使应用在前台也显示通知
        completionHandler([.banner, .sound])
    }
    
    // 处理通知点击的具体逻辑
    private func handleNotificationTap(identifier: String, userInfo: [AnyHashable: Any]) {
        // 在这里添加你的业务逻辑
        // 例如：导航到特定页面，执行特定操作等
    }
}

