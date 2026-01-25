import Llmx
import SwiftUI

struct SpotlightAi: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Bot()
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct Bot: View {
    @State private var resp = ""
    @State private var content = ""
    @Environment(\.input) private var input
    @Environment(\.theme) private var theme
    @Environment(\.spotlight) private var spotlight
    
    @State private var bufferingSegment = AttributedString()
    @State private var committedSegments: [AttributedString] = []

    let field: Field = .misc(tag: "research")
    
    var body: some View {
        VStack {
            if spotlight.isAiExpanded {
                ScrollView {
//                    Text(resp)
//                        .selectionDisabled(false)
                    
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(committedSegments.indices, id: \.self) { index in
                            Text(committedSegments[index])
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Text(bufferingSegment)
                            .foregroundStyle(.yellow)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    
                }
                .padding(8, 0)
                .frame(height: 560, alignment: .leading)
            }

            OmniField(content, placeholder: "Topic")
                .behavior(.always)
                .field(field, focus: input.focus == field)
                .style(typography: .medium)
                .on(focus: onFocus, edit: onEdit, submit: onSubmit, tab: onTab)
                .padding(12, 16, 6, 16)

            HStack(alignment: .bottom) {
                Button(action: {}) {
                    Label("Note", systemImage: "plus")
                        .labelStyle(.iconOnly)
                        .padding(.vertical, 2)
                }
                .buttonStyle(.omni)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6, 6)
                }
                .keyboardShortcut(.return)
                .buttonStyle(.omni.with(visual: .primaryBtn.circled))
                .disabled(content.isEmpty)
            }
            .padding(6, 16)
        }
    }
    
    private func onFocus() {
        withAnimation { input.focus = field }
    }
    
    private func onEdit(value: String) {
        content = value
    }
    
    private func onSubmit() -> Bool {
        tryLlmx()
        if !Modules.spotlight.isAiExpanded {
            withAnimation {
                
                Modules.spotlight.isAiExpanded = !Modules.spotlight.isAiExpanded
            }
        }
        return true
    }
    
    private func onTab() -> Bool {
        return true
    }
    
    private func tryLlmx() {
        Task {
            try? await mlxDemo()
        }
    }
    
    private func mlxDemo() async throws {
        let mlx = Llmx.LocalMLXProvider()
        let streaming = Llmx.Streaming(
            style: .init(
                textColor: Modules.vars.theme.text.primary
            ),
            committed: $committedSegments,
            buffering: $bufferingSegment
        )
        let messages = [Llmx.Message(role: .user, content: content)]
        
        var temp: [String] = []
        
        let model = "phi3-mini-4k-instruct"
        
        for try await token in try await mlx.sendChat(messages: messages,
                                                      model: model,
                                                      parameters: .init(temperature: 0.7)) {
            resp += token
            streaming.receive(string: token)
            temp.append(token)
        }
    }
    
    private func llmxDemo() async throws {
        let ollama = try! Llmx.OllamaProvider(config: .init(baseURL: URL(string: "http://localhost:11434")!))
        let ollamaModels = try await ollama.listModels()
        print("[Llmx]", ollamaModels)
        
        guard let model = ollamaModels.first else {
            return
        }
        
        var temp: [String] = []
        
//        let streaming = Llmx.
        
        committedSegments = []
        bufferingSegment = AttributedString()
        
        let streaming = Llmx.Streaming(
            style: .init(
                textColor: Modules.vars.theme.text.primary
            ),
            committed: $committedSegments,
            buffering: $bufferingSegment
        )
        
        let messages = [Llmx.Message(role: .user, content: content)]
        for try await token in try await ollama.sendChat(messages: messages,
                                                         model: model,
                                                         parameters: .init(temperature: 0.7)) {
            resp += token
            streaming.receive(string: token)
            temp.append(token)
        }
        
//        let inputs: [String] = [
//            "好的，",
//            "这里简略一点的任务管理方法：",
//            "\n\n",
//            "1.", " **", "创建任务", ":**", " 将需要完成的事情写下来。", "\n",
//            "2.", " **", "分类", ":**", " 按照重要性、截止日期等分类。", "\n",
//            "3", ".", " **", "设置截止日期", ":**", " 设定时间表，", "提醒你。", "\n\n",
//            
//            "**", "常用的工具", ":**", "\n\n",
//            "*", "   ", "**", "纸和笔", ":**", "  简单快捷。", "\n",
//            "*", "   ", "**", "待办事项清单", ":**", "  App 或软件。", "\n",
//            "*", "   ", "**", "Trello, Asana, Todoist", ":**", "  专业工具，", "更高级。", "\n\n",
//            "希望这些", "信息对你有", "帮助", "！", ""
//        ]
        
//        for token in inputs {
//            streaming.receive(string: token)
//        }
        
        print(temp)
    }
}
