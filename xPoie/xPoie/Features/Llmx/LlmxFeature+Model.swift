import Llmx
import SwiftUI
import TipKit

fileprivate let icons: [String: String] = [
    "qwen2.5-3b-instruct": "llm-models/qwen",
    "llama3-8b-instruct": "llm-models/meta"
]

struct LlmxFeature_ModelIcon: View {
    let model: Llmx.ModelInfo
    
    var body: some View {
        if let icon = icons[model.id] {
            Image(icon)
                .resizable()
                .frame(width: 16, height: 16)
        } else {
            Image(systemName: "sparkle")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundStyle(.blue)
        }
    }
}

struct LlmxFeature_ModelView: View {
    let model: Llmx.ModelInfo
    let state: Llmx.ModelState?
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            LlmxFeature_ModelIcon(model: model)
            
            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    Text(model.name)
                    
                    if let size = model.fileSizeGB {
                        Text(String(format: "%.1f GB", size))
                            .typography(.desc)
                    }
                }
                
                Text("sdfefkmm").typography(.desc)
            }
            
            Spacer()
            
            LlmxFeature_ModelStatus(model: model, state: state)
        }
        .padding(12)
    }
}

struct LlmxFeature_ModelViewFlat: View {
    let model: Llmx.ModelInfo
    let state: Llmx.ModelState?
    
    let action: (Llmx.ModelInfo) -> Void
    
    var body: some View {
        Button { action(model) } label: {
            Label(model.name, systemImage: "sparkle")
            if let state = state {
                switch state.status {
                case .downloaded(_):
                    Text("haha")
                case .none:
                    Text("none")
                case .notDownloaded:
                    Text("not downloaded")
                case .downloading(let progress, let speed):
                    ProgressView("download...", value: progress, total: 1)
                case .failed(let msg):
                    Text("failed \(msg)")
                }
            }
            Button(action: download) {
                Text("Download")
            }
        }
    }
    
    private func download() {
        let model = model
        Task {
            try await Llmx.ModelManager.shared.download(for: model)
        }
    }
}

struct LlmxFeature_ModelStatus: View {
    let model: Llmx.ModelInfo
    let state: Llmx.ModelState?
    
    var body: some View {
        VStack {
            if case .downloaded(_) = state?.status {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(6)
                    .foregroundStyle(.blue)
            } else if case .downloading(let progress, _) = state?.status {
                SimpleCircularProgress(progress: progress)
                    .frame(width: 16, height: 16)
                    .padding(6)
            } else if case .none? = state?.status {
                Button(action: download) {
                    Image(systemName: "arrow.down.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.blue)
                        .padding(6)
                }
                .buttonStyle(.omni.with(padding: .zero))
            } else if case .failed(let msg) = state?.status {
                Button(action: download) {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .padding(6)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.omni.with(padding: .zero))
                .tooltip(msg)
            }
        }
    }
    
    private func download() {
        let model = model
        Task {
            try await Llmx.ModelManager.shared.download(for: model)
        }
    }
}

struct SimpleCircularProgress: View {
    let progress: Double
    var lineWidth: CGFloat = 3
    var progressColor: Color = .blue
    var trackColor: Color = .gray.opacity(0.3)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

fileprivate struct ErrorTip: Tip {
    let content: String
    
    var title: Text {
        Text(content)
    }
    
    var message: Text? {
        Text(content)
    }
}
//    .task {
//        try? Tips.configure([
//            .displayFrequency(.immediate),
//            .datastoreLocation(.applicationDefault)
//        ])
//    }
