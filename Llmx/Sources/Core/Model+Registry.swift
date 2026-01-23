import Foundation

extension Llmx {
    public class ModelRegistry {
        nonisolated(unsafe) public static let llama3_8b_instruct = ModelInfo(
            id: "llama3-8b-instruct",
            name: "Llama 3 8B Instruct",
            source: .huggingFace("meta-llama/Meta-Llama-3-8B-Instruct")
        )
        
        nonisolated(unsafe) public static let qwen2_7b_instruct = ModelInfo(
            id: "qwen2-7b-instruct",
            name: "Qwen2 7B Instruct",
            source: .huggingFace("Qwen/Qwen2-7B-Instruct"),
        )
        
        nonisolated(unsafe) public static let mistral_7b_instruct = ModelInfo(
            id: "mistral-7b-instruct",
            name: "Mistral 7B Instruct",
            source: .huggingFace("mistralai/Mistral-7B-Instruct-v0.2"),
        )
        
        nonisolated(unsafe) public static let gemma_7b_it = ModelInfo(
            id: "gemma-7b-it",
            name: "Gemma 7B IT",
            source: .huggingFace("google/gemma-7b-it"),
        )
        
        nonisolated(unsafe) public static let phi_3_mini_4k_instruct = ModelInfo(
            id: "phi-3-mini-4k-instruct",
            name: "Phi-3 Mini 4K Instruct",
            source: .huggingFace("microsoft/Phi-3-mini-4k-instruct"),
        )
    }
}
