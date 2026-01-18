import SwiftData

extension Models {
    @Model class Focus {
        var title: String
        var seconds: Int
        var status: Status
        
        init(title: String, seconds: Int, status: Status = .ongoing) {
            self.title = title
            self.seconds = seconds
            self.status = status
        }
        
        enum Status: Int, Codable {
            case paused
            case ongoing
            case complete
        }
    }
}
