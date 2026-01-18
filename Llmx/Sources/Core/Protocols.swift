import SwiftUI
import Foundation

extension Llmx {
    public protocol Provider {
        var id: String { get }
        var isLocal: Bool { get }

        associatedtype Config
        init(config: Config) throws

        /// 列出该提供者可用的模型
        func listModels() async throws -> [String]
        
        /// 发送聊天消息，返回 **流式** token 序列
        func sendChat(
            messages: [Message],
            model: String,
            parameters: GenerationParameters?
        ) async throws -> AsyncThrowingStream<String, Swift.Error>
    }
    
    public struct Message {
        public enum Role: String { case system, user, assistant }
        public let role: Role
        public let content: String

        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
    }
    
    /// 通用生成参数（各 Provider 会自行映射）
    public struct GenerationParameters {
        public let temperature: Double?
        public let maxTokens: Int?
        public let topP: Double?

        public init(temperature: Double? = nil,
                    maxTokens: Int? = nil,
                    topP: Double? = nil) {
            self.temperature = temperature
            self.maxTokens = maxTokens
            self.topP = topP
        }
    }
        
    public enum Error: Swift.Error, LocalizedError {
        case invalidConfig(String)
        case network(Swift.Error)
        case provider(String)
        case unsupported(String)

        public var errorDescription: String? {
            switch self {
            case .invalidConfig(let msg): return "配置错误: \(msg)"
            case .network(let e): return "网络错误: \(e.localizedDescription)"
            case .provider(let msg): return "Provider 错误: \(msg)"
            case .unsupported(let msg): return "不支持: \(msg)"
            }
        }
    }
    
    public struct Style {
            // 基础文字
            public var baseFontSize: CGFloat = 15.0
            public var baseFont: Font? = nil
            
            // 颜色
            public var textColor: Color? = nil
            public var secondaryColor: Color? = nil
            public var linkColor: Color = .blue
            
            // 标题级别字体大小（可覆盖）
            public var headingSizes: [Int: CGFloat] = [
                1: 28,
                2: 24,
                3: 20,
                4: 18,
                5: 16,
                6: 15
            ]
            
            // 代码相关
            public var codeFont: Font? = nil
            public var codeColor: Color = .secondary
            
            // 列表缩进
            public var listBaseIndent: CGFloat = 15.0
            public var listIndentPerLevel: CGFloat = 20.0
            
            // 引用
            public var quoteBarColor: Color = .secondary
        
            public var lineHeightMultiple: CGFloat = 1.3
        
            public init(
                baseFontSize: CGFloat? = nil,
                baseFont: Font? = nil,
                textColor: Color? = nil,
                secondaryColor: Color? = nil,
                linkColor: Color? = nil,
                headingSizes: [Int: CGFloat]? = nil,
                codeFont: Font? = nil,
                codeColor: Color? = nil,
                listBaseIndent: CGFloat? = nil,
                listIndentPerLevel: CGFloat? = nil,
                quoteBarColor: Color? = nil,
                lineHeightMultiple: CGFloat? = nil
            ) {
                if let baseFontSize { self.baseFontSize = baseFontSize }
                if let baseFont { self.baseFont = baseFont }
                if let textColor { self.textColor = textColor }
                if let secondaryColor { self.secondaryColor = secondaryColor }
                if let linkColor { self.linkColor = linkColor }
                if let headingSizes { self.headingSizes = headingSizes }
                if let codeFont { self.codeFont = codeFont }
                if let codeColor { self.codeColor = codeColor }
                if let listBaseIndent { self.listBaseIndent = listBaseIndent }
                if let listIndentPerLevel { self.listIndentPerLevel = listIndentPerLevel }
                if let quoteBarColor { self.quoteBarColor = quoteBarColor }
                if let lineHeightMultiple { self.lineHeightMultiple = lineHeightMultiple }
            }
            
            // 默认样式（保持原有行为）
            public static var `default`: Style { Style() }
        }
}
