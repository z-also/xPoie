import Foundation
import Hub
import AnyLanguageModel

extension Llmx {
    
    public final class LocalMLXProvider: Provider {
        public let id: String = "local-mlx"
        public let isLocal: Bool = true
        
        public struct Config {
            public let maxTokensDefault: Int = 1024
            public let temperatureDefault: Double = 0.7
            public let topPDefault: Double = 0.95
            public init() {}
        }
        
        private let config: Config
        
        public required init(config: Config = Config()) {
            self.config = config
        }
        
        public func listModels() async throws -> [String] {
            return ModelRegistry.textLlms.map { $0.id }
        }
        
        public func sendChat(
            messages: [Message],
            model modelId: String,
            parameters: GenerationParameters?
        ) async throws -> AsyncThrowingStream<String, Swift.Error> {
            guard let modelInfo = ModelRegistry.textLlms.first(where: { $0.id == modelId }) else {
                throw Error.unsupported("Model \(modelId) not found")
            }
            
            let state = ModelManager.shared.states.get(id: modelId)
            guard case .downloaded = state?.status else {
                throw Error.provider("Model \(modelId) not downloaded")
            }
            
            guard case .huggingFace(let repoId) = modelInfo.source else {
                throw Error.unsupported("Only HF sources")
            }
            
            let hub = HubApi.shared
            let repo = Hub.Repo(id: repoId)
            let localPath = hub.localRepoLocation(repo).path
            
            let model = MLXLanguageModel(modelId: repoId)
            let session = LanguageModelSession(model: model)
            
            guard let lastUser = messages.last(where: { $0.role == .user }) else {
                throw Error.unsupported("No user message found")
            }
            let prompt = lastUser.content  // 或 Prompt(lastUser.content) 如果需要 Prompt 类型
            
            // 4. 创建 GenerationOptions（最安全写法：默认 + 逐个设置）
            var options = GenerationOptions()  // 先空 init
            
            // 应用参数（如果你的 GenerationParameters 有对应字段）
            if let params = parameters {
                options.temperature = params.temperature ?? config.temperatureDefault
                // 如果有其他如 topK, repetitionPenalty，根据你的后端加
            } else {
                options.temperature = config.temperatureDefault
            }
            
            let stream = try await session.streamResponse(to: prompt, options: options)
            
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await partialResponse in stream {
                            continuation.yield(partialResponse.content)  // 每次 yield 一段生成的文本
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
}
