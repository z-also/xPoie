import Combine
import Foundation

extension Llmx {
    public enum ModelSource: Codable {
        case huggingFace(String)
    }
    
    public enum ModelStatus {
        case none
        case notDownloaded
        case downloading(Double, Double?)
        case downloaded(URL)
        case failed(String)
    }
    
    public struct ModelInfo: Codable, Identifiable {
        public let id: String
        public let name: String
        public let source: ModelSource
        public let fileSizeGB: Double?
        
        public init(id: String, name: String, source: ModelSource, fileSizeGB: Double? = nil) {
            self.id = id
            self.name = name
            self.source = source
            self.fileSizeGB = fileSizeGB
        }
    }
    
    public struct ModelState {
        public var id: String
        public var status: ModelStatus

        public init(id: String, status: ModelStatus = .none) {
            self.id = id
            self.status = status
        }
    }
    
    @Observable public final class ModelStates {
        public var states: [String: ModelState] = [:]
        
        public func get(id: String) -> ModelState? { states[id] }
        
        public func update(id: String, status: ModelStatus) {
            states[id] = .init(id: id, status: status)
        }
    }
}
