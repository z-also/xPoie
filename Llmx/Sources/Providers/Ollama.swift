import AppKit
import Markdown
import Foundation

extension Llmx {
    public struct OllamaProvider: Provider {
        public let id = "ollama"
        public let isLocal = true

        public struct Config {
            public let baseURL: URL   // 例如 URL(string: "http://localhost:11434")!
            public init(baseURL: URL) { self.baseURL = baseURL }
        }

        private let config: Config
        private let session = URLSession.shared

        public init(config: Config) throws { self.config = config }

        public func listModels() async throws -> [String] {
            let url = config.baseURL.appendingPathComponent("api/tags")
            let (data, _) = try await session.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let models = json["models"] as? [[String: Any]] else {
                throw Error.provider("解析 Ollama 模型列表失败")
            }
            return models.compactMap { $0["name"] as? String }
        }

        public func sendChat(
            messages: [Message],
            model: String,
            parameters: GenerationParameters?
        ) async throws -> AsyncThrowingStream<String, Swift.Error> {
            let url = config.baseURL.appendingPathComponent("api/chat")
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var body: [String: Any] = [
                "model": model,
                "messages": messages.map { ["role": $0.role.rawValue, "content": $0.content] },
                "stream": true
            ]
            if let p = parameters {
                if let t = p.temperature { body["temperature"] = t }
                if let m = p.maxTokens { body["options"] = ["num_predict": m] }
                if let tp = p.topP { body["options"] = (body["options"] as? [String: Any] ?? [:]).merging(["top_p": tp]) { $1 } }
            }
            req.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (stream, response) = try await session.bytes(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw Error.network(URLError(.badServerResponse))
            }
            
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for try await line in stream.lines {
                            guard let data = line.data(using: .utf8),
                                  let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                  let message = obj["message"] as? [String: Any],
                                  let content = message["content"] as? String else { continue }
                            
                            continuation.yield(content)
                            
                            if obj["done"] as? Bool == true { break }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: Error.network(error))
                    }
                }
            }
        }
    }
}
