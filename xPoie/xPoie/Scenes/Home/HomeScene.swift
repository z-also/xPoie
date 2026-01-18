import SwiftUI

struct HomeSceneMain: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Reminders
            // Tasks Due {Today, this week, this month}
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(0..<4) { _ in
                    HomeSceneAgenda()
                }
            }
//            RandomSelectListView()
        }
        .padding(16, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


struct Item: Identifiable {
    let id: String
    let title: String
}

private struct SelectedIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var selectedId: String? {
        get { self[SelectedIdKey.self] }
        set { self[SelectedIdKey.self] = newValue }
    }
}

struct RandomSelectListItem: View {
    let item: Item
    @Environment(\.selectedId) private var selectedId
    
    var body: some View {
        VStack(spacing: 16) {
            Text(item.title)
            if item.id == selectedId {
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .opacity(selectedId == item.id ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: selectedId)
            }
        }
    }
}

struct RandomSelectListView: View {
    @State private var items = [
        Item(id: "1", title: "项目 1"),
        Item(id: "2", title: "项目 2"),
        Item(id: "3", title: "项目 3"),
    ]
    
    @State private var selectedId: String?
    
    var body: some View {
        VStack {
            Button("随机选择") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if let randomItem = items.randomElement() {
                        selectedId = randomItem.id
                    }
                }
            }
            .padding()
            
            List(items) { item in
                RandomSelectListItem(item: item)
            }
            .environment(\.selectedId, selectedId)
        }
    }
}
