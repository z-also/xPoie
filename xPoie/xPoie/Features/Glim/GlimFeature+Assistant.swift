import Llmx
import SwiftUI

struct GlimFeature_Assistant: View {
    @Environment(\.glim) var glim
    
    @State var downloadProgess: Double = 0.0
    
    @State var models: [Llmx.ModelInfo] = [
        Llmx.ModelRegistry.gemma_7b_it,
        Llmx.ModelRegistry.llama3_8b_instruct,
        Llmx.ModelRegistry.phi_3_mini_4k_instruct
    ]
    
    @State var modelStates = Llmx.ModelManager.shared.states
    
    var body: some View {
        VStack {
            Header()
            
            ProgressView("download...", value: downloadProgess, total: 1)
            
            
            ForEach(models, id: \.id) { model in
                let state = modelStates.get(id: model.id)
                ModelView(model: model, state: state)
            }
            
            ScrollView {
                VStack {
                    GlimFeature_Sugs(sugs: glim.sugs)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            Button(action: download) {
                Text("download")
            }
            
            GlimFeature_Prompter()
        }
        .padding(4, 2)
        .frame(idealWidth: 320, maxWidth: 360, idealHeight: 240, maxHeight: 520, alignment: .leading)
    }
    
    private func download() {
        // 1. 获取 Application Support 目录（用户域）
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        // 2. 最好用 Bundle ID 做子目录，避免和其他 app 冲突
        let bundleID = Bundle.main.bundleIdentifier ?? "com.yourcompany.yourapp"
        let appDir = appSupportDir.appendingPathComponent(bundleID)

        // 3. 可再细分 Downloads 子目录（可选，但推荐）
        let downloadsDir = appDir.appendingPathComponent("Downloads")
        
        do {
            try FileManager.default.createDirectory(at: downloadsDir,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print("创建 Downloads 目录失败: \(error)")
            // 可 fallback 到 caches 或其他
        }
        
        let fileName = "model.safetensors"  // 或从 URL 中动态提取，例如 url.lastPathComponent
        
        let saveTo = downloadsDir.appendingPathComponent(fileName)
        
        print("save to", saveTo)
        
//        let url = URL(string: "https://huggingface.co/bert-base-uncased/resolve/main/model.safetensors")!
        let url = URL(string: "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/main/model.safetensors")!
        
//        let url = URL(string: "https://huggingface.co/meta-llama/Llama-3.2-1B/resolve/main/model.safetensors")!
        let downloader = Llmx.Downloader(destination: saveTo)
        
        downloader.start(url: url) { progress in
            downloadProgess = progress
            print("进度: \(Int(progress * 100))%")
        } completion: { result in
            switch result {
            case .success(let fileURL):
                print("保存成功: \(fileURL.path)")
            case .failure(let error):
                print("失败: \(error)")
            }
        }
    }
}

fileprivate struct Header: View {
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: close) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.omni)
        }
    }
    
    private func close() {
        Modules.glim.present(.none)
    }
}


fileprivate struct ModelView: View {
    let model: Llmx.ModelInfo
    let state: Llmx.ModelState?
    
    var body: some View {
        HStack {
            Text(model.name)
            
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
