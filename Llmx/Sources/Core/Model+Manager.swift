import Foundation
import Combine
import Hub

extension Llmx {
    public class ModelManager {
        public let states = ModelStates()
        nonisolated(unsafe) public static let shared = ModelManager()
        
        private init() {}
        
        public func download(for model: ModelInfo) async throws {
            guard case .huggingFace(let repoId) = model.source else { return }
            
            let id = model.id
            states.update(id: id, status: .downloading(0, nil))
            
            let repo = Hub.Repo(id: repoId)

            let patterns = [
                "config.json",
                "generation_config.json",
                "tokenizer.json",
                "tokenizer_config.json",
                "special_tokens_map.json",
                "*.safetensors",
                "model.safetensors.index.json"
            ]

            do {
                let destination = try await Hub.snapshot(
                    from: repo,
                    matching: patterns,
                    progressHandler: { [weak self] progress, speed in
                        guard let self else { return }
                        print(progress)
                        let fraction = progress.fractionCompleted
                        states.update(id: id, status: .downloading(fraction, speed))
                    }
                )
                states.update(id: id, status: .downloaded(destination))
            } catch {
                states.update(id: id, status: .failed(error.localizedDescription))
                throw error
            }
        }
        
        public func cancelDownload(for modelId: String) {
            
        }

        private func checkModelLocalExistence(model: ModelInfo) -> URL? {
            guard case .huggingFace(let repoId) = model.source else { return nil }
            
            let repo = Hub.Repo(id: repoId)
            let location = HubApi.shared.localRepoLocation(repo)
            
            let fm = FileManager.default
            guard fm.fileExists(atPath: location.path) else { return nil }
            
            let requiredFiles = [
                "config.json",
                "tokenizer.json",
                "tokenizer_config.json"
            ]
            
            for file in requiredFiles {
                let fileURL = location.appendingPathComponent(file)
                if !fm.fileExists(atPath: fileURL.path) {
                    return nil
                }
            }
            
            return location
        }
        
        public func initStates(models: [ModelInfo]) {
            models.forEach { model in
                let loc = checkModelLocalExistence(model: model)
                states.update(id: model.id, status: loc == nil ? .none : .downloaded(loc!))
            }
        }
    }
}
