import Foundation

// Llmx 模型注册表 - 兼容 MLX Swift（mlx-community 4-bit 量化版为主）
// 使用方式：Llmx.ModelRegistry.phi3_mini_4k_instruct
// 或 Llmx.ModelRegistry.textLlms / .visionLlms

extension Llmx {
    public struct ModelRegistry {
        // 小型高效文本模型
        nonisolated(unsafe) public static let phi3_mini_4k_instruct = ModelInfo(
            id: "phi3-mini-4k-instruct",
            name: "Phi-3 Mini 4K Instruct (4-bit)",
            source: .huggingFace("microsoft/Phi-3-mini-4k-instruct"),
            fileSizeGB: 2.2,
            // 速度 ≈ 50-80 t/s；推荐：入门/日常聊天/低内存首选
        )
        
        nonisolated(unsafe) public static let qwen2_5_3b_instruct = ModelInfo(
            id: "qwen2.5-3b-instruct",
            name: "Qwen2.5 3B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen2.5-3B-Instruct"),
            fileSizeGB: 2.0,
            // 速度 ≈ 60-90+ t/s；推荐：超小型中文任务
        )
        
        nonisolated(unsafe) public static let qwen3_4b_instruct = ModelInfo(
            id: "qwen3-4b-instruct",
            name: "Qwen3 4B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen3-4B-Instruct"),
            fileSizeGB: 2.4,
            // 速度 ≈ 50-75 t/s；推荐：Qwen3 入门中文/代码
        )
        
        // 中型主力文本模型
        nonisolated(unsafe) public static let qwen2_5_7b_instruct = ModelInfo(
            id: "qwen2.5-7b-instruct",
            name: "Qwen2.5 7B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen2.5-7B-Instruct"),
            fileSizeGB: 4.2,
            // 速度 ≈ 35-55 t/s；推荐：中文/多语言性价比最高
        )
        
        nonisolated(unsafe) public static let qwen2_5_coder_7b_instruct = ModelInfo(
            id: "qwen2.5-coder-7b-instruct",
            name: "Qwen2.5 Coder 7B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen2.5-Coder-7B-Instruct"),
            fileSizeGB: 4.3,
            // 速度 ≈ 30-50 t/s；推荐：代码生成顶级
        )
        
        nonisolated(unsafe) public static let mistral_7b_instruct_v03 = ModelInfo(
            id: "mistral-7b-instruct-v0.3",
            name: "Mistral 7B Instruct v0.3 (4-bit)",
            source: .huggingFace("mistralai/Mistral-7B-Instruct-v0.3"),
            fileSizeGB: 4.1,
            // 速度 ≈ 40-60 t/s；推荐：英文指令经典
        )
        
        nonisolated(unsafe) public static let llama3_8b_instruct = ModelInfo(
            id: "llama3-8b-instruct",
            name: "Llama 3 8B Instruct (4-bit)",
            source: .huggingFace("meta-llama/Meta-Llama-3-8B-Instruct"),
            fileSizeGB: 4.7,
            // 速度 ≈ 30-50 t/s；推荐：英文高质量聊天
        )
        
        nonisolated(unsafe) public static let qwen3_8b_instruct = ModelInfo(
            id: "qwen3-8b-instruct",
            name: "Qwen3 8B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen3-8B-Instruct"),
            fileSizeGB: 4.9,
            // 速度 ≈ 30-50 t/s；推荐：Qwen3 升级中文/代码
        )
        
        nonisolated(unsafe) public static let gemma2_9b_it = ModelInfo(
            id: "gemma2-9b-it",
            name: "Gemma 2 9B It (4-bit)",
            source: .huggingFace("google/gemma-2-9b-it"),
            fileSizeGB: 5.2,
            // 速度 ≈ 25-45 t/s；推荐：数学/推理高效
        )
        
        nonisolated(unsafe) public static let qwen2_5_14b_instruct = ModelInfo(
            id: "qwen2.5-14b-instruct",
            name: "Qwen2.5 14B Instruct (4-bit)",
            source: .huggingFace("Qwen/Qwen2.5-14B-Instruct"),
            fileSizeGB: 8.0,
            // 速度 ≈ 20-35 t/s；推荐：中大型跃升
        )
        
        nonisolated(unsafe) public static let llama31_8b_instruct = ModelInfo(
            id: "llama3.1-8b-instruct",
            name: "Llama 3.1 8B Instruct (4-bit)",
            source: .huggingFace("meta-llama/Meta-Llama-3.1-8B-Instruct"),
            fileSizeGB: 4.9,
            // 速度 ≈ 30-50 t/s；推荐：长上下文改进版
        )
        
        // 视觉/多模态模型
        nonisolated(unsafe) public static let phi3_vision_128k_instruct = ModelInfo(
            id: "phi3-vision-128k-instruct",
            name: "Phi-3 Vision 128K Instruct (4-bit)",
            source: .huggingFace("microsoft/Phi-3-vision-128k-instruct"),
            fileSizeGB: 2.5,
            // 速度 ≈ 5-15 s/inference；推荐：轻量视觉入门
        )
        
        nonisolated(unsafe) public static let qwen2_vl_7b_instruct = ModelInfo(
            id: "qwen2-vl-7b-instruct",
            name: "Qwen2-VL 7B Instruct (4-bit / bf16)",
            source: .huggingFace("Qwen/Qwen2-VL-7B-Instruct"),
            fileSizeGB: 5.0,
            // 速度 ≈ 10-25 s/inference；推荐：Mac 上最佳中文/英文视觉理解
        )
        
        // 分组数组
        nonisolated(unsafe) public static let textLlms: [ModelInfo] = [
            phi3_mini_4k_instruct,
            qwen2_5_3b_instruct,
            qwen3_4b_instruct,
            qwen2_5_7b_instruct,
            qwen2_5_coder_7b_instruct,
            mistral_7b_instruct_v03,
            llama3_8b_instruct,
            qwen3_8b_instruct,
            gemma2_9b_it,
            qwen2_5_14b_instruct,
            llama31_8b_instruct
        ]
        
        nonisolated(unsafe) public static let visionLlms: [ModelInfo] = [
            phi3_vision_128k_instruct,
            qwen2_vl_7b_instruct
        ]
    }
}
