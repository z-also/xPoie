import SwiftUI

struct CalendarSpaceWidget: View {
    let spaces: [Modules.Events.Space]
    let selecteds: Set<UUID>
    
    @State var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Ctrlbar(isExpanded: $isExpanded)
            if isExpanded {
                CalendarSpaceList(
                    spaces: spaces,
                    selecteds: selecteds,
                    onSelect: onSelect
                )
                .padding(0, 0, 0, 6)
            }
        }
    }
    
    func onSelect(space: Modules.Events.Space) {
        Modules.calendar.toggle(space: space)
    }
}

struct CalendarSpaceList: View {
    let spaces: [Modules.Events.Space]
    let selecteds: Set<UUID>
    let onSelect: (Modules.Events.Space) -> Void
    
    var body: some View {
        List {
            ForEach(spaces) { space in
                CalendarSpaceItem(
                    data: space,
                    selected: selecteds.contains(space.id),
                    onSelect: onSelect
                )
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct CalendarSpaceItem: View {
    var data: Modules.Events.Space
    var selected: Bool
    var onSelect: (Modules.Events.Space) -> Void
    
    @State var hovered = false
    @State var isMenuVisible = false
    
    @Environment(\.theme) var theme

    var body: some View {
        Button(action: { onSelect(data) }) {
            HStack {
                OmniToggle(yes: selected, color: Color(data.color), onToggle: { _ in })
                
                Text(data.name).foregroundStyle(theme.text.primary)
                
                Spacer()
                
                if (hovered || isMenuVisible) {
                    Button(action: toggleMenu) {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .frame(width: 14, height: 3)
                    }
                    .buttonStyle(.omni.with(size: .xs))
                    .popover(isPresented: $isMenuVisible) {
                        ItemMenu(color: data.color, onSelectColor: onSelectColor)
                            .background(theme.fill.primary.padding(-80))
                    }
                }
            }
            .padding(.horizontal, 2)
        }
        .buttonStyle(.omni)
        .onHover { active in hovered = active }
    }
    
    func toggleMenu() {
        isMenuVisible.toggle()
    }
    
    func onSelectColor(value: Option<String, String>) {
        data.color = value.value
    }
}

fileprivate struct Ctrlbar: View {
    @Binding var isExpanded: Bool
    @State private var isCreating = false
    
    var body: some View {
        HStack {
            Button(action: toggleExpand) {
                Spacer().frame(width: 4)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 5, height: 8)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                
                Text("Calendar spaces").typography(.h6)
                
                Spacer()
            }
            .buttonStyle(.omni)
            
            Button(action: toggleCreation) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(3, 2)
            }
            .buttonStyle(.icon)
        }
        .sheet(isPresented: $isCreating) {
            CreationSheet(toggle: toggleCreation)
                .presentationBackground(Color.clear)
        }
    }
    
    func toggleExpand() {
        withAnimation {
            isExpanded.toggle()
        }
    }
    
    func toggleCreation() {
        isCreating.toggle()
    }
}

fileprivate struct ItemMenu: View {
    // color
    var color: String
    
    // select color
    var onSelectColor: (Option<String, String>) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Color").typography(.h4)
            ColorSelect(value: color, options: Consts.colors, onSelect: onSelectColor)
        }
        .padding(10)
    }
}

fileprivate struct CreationSheet: View {
    @State private var textInput: String = ""
    
    @State private var color: Option<String, String> = Consts.colors.first!
    
    var toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Image("banner")
                    .resizable()
                    .frame(width: 360, height: 160)
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.blue))
                
                Text("Create a calendar space")
                    .typography(.h4)
                    .frame(alignment: .center)
                
                Text("A calendar space is a place where you can organize your events and schedule efficiently")
                    .typography(.tip)
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
            }

            Spacer().frame(height: 32)
            
            Text("Name").typography(.h4)
            TextField("Enter some text", text: $textInput)

            Spacer().frame(height: 32)

            Text("Color").typography(.h4)
            Text("A calendar space is a place where you can organize your").typography(.tip)
            
            ColorSelect(value: color.value, options: Consts.colors, onSelect: onSelectColor)
            
            Spacer().frame(height: 32)

            HStack(spacing: 20) {
                Spacer()
                
                Button(action: cancel) {
                    Text("Cancel")
                }
//                .buttonStyle(.omni.with(config: .link))
                
                Button(action: onCreate) {
                    Text("Confirm")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
//                .buttonStyle(.omni.with(config: .primary))
            }
        }
        .padding()
        .frame(width: 460, alignment: .top)
    }
    
    func onSelectColor(value: Option<String, String>) {
        color = value
    }
    
    func cancel() {
        toggle()
    }
    
    func onCreate() {
        Modules.events.createSpace(name: textInput, role: .calendar, color: color.value)
        toggle()
    }
}
