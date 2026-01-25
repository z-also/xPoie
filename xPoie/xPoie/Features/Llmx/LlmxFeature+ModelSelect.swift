import Llmx
import SwiftUI

struct LlmxFeature_ModelList: View {
    let models: [Llmx.ModelInfo]
    
    @Environment(\.theme) private var theme
    @Environment(\.glim.modelStates) private var states
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(models, id: \.id) { model in
                let state = states.get(id: model.id)
                let isLast = model.id == models.last?.id
                LlmxFeature_ModelView(model: model, state: state)
                    .overlay(alignment: .bottom) {
                        theme.fill.secondary.frame(height: 0.5).padding(.leading, 32).opacity(isLast ? 0 : 1)
                    }
            }
        }
    }
}

struct LlmxFeature_ModelManage: View {
    let title: String
    let models: [Llmx.ModelInfo]
    
    @Environment(\.theme) private var theme
    
    var body: some View {
        Section {
            LlmxFeature_ModelList(models: models)
                .padding(0, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.fill.tertiary, in: .rect(cornerRadius: 18))
        } header: {
            Text(title)
                .typography(.h6, size: .p)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LlmxFeature_ModelSelect: View {
    let models: [Llmx.ModelInfo]
    @Binding var selected: Llmx.ModelInfo
    
    @Environment(\.theme) var theme
    @Environment(\.glim.modelStates) private var states

    var body: some View {
        Menu {
            ForEach(models, id: \.id) { model in
                let state = states.get(id: model.id)
                LlmxFeature_ModelViewFlat(model: model, state: state, action: onSelect)
            }
        } label: {
            HStack {
                Text(selected.name)
                    .font(size: .xs)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 8, height: 5)
            }
            .padding(4, 6)
        }
        .menuStyle(.button)
        .buttonStyle(.omni.with(padding: .zero))
        .foregroundColor(theme.text.secondary)
    }
    
    private func onSelect(model: Llmx.ModelInfo) {
        selected = model
    }
}
