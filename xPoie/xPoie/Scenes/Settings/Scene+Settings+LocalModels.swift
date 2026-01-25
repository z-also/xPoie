import Llmx
import SwiftUI

struct SettingsSceneLocalModels: View {
    var body: some View {
        VStack {
            ScrollView {
                LlmxFeature_ModelManage(title: "Text LLMs", models: Llmx.ModelRegistry.textLlms)
                    .padding(0, 8)
                
                Spacer().frame(height: 24)
                
                LlmxFeature_ModelManage(title: "Vision LLMs", models: Llmx.ModelRegistry.visionLlms)
                    .padding(0, 8)
            }
            .padding(0, 0, 8, 16)
        }
    }
}
