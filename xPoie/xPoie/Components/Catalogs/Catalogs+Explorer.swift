import SwiftUI

struct CatalogsExplorer<Item: View, C: View>: View {
    // root catalog id
    var rootId: UUID
    // current selected item
    var currentId: UUID?
    // total catalogs source
    var catalogs: [UUID: Collection<UUID>]
    
    // expand status mapping for groups
    var expandeds: [UUID: Bool]
    // drag move cursor
    var movingIndicator: () -> C
    // render a item by its uuid
    var render: (UUID, UUID?, UUID?, Bool, Bool?, @escaping (UUID, Bool) -> Void) -> Item

    // move
    var onMove: ((UUID, UUID, Edge) -> Void)?
    // toggle expand/collapse for a group item
    var onToggle: (UUID, Bool) -> Void

    // catalog item being drag
    @State var moving: UUID?
    // catalog item as where to drop
    @State var movingTo: UUID?
    // where to insert the moving item relatived to movingTo
    @State var movingEdge: Edge?

    init(
        catalogs: [UUID: Collection<UUID>],
        rootId: UUID,
        currentId: UUID?,
        expandeds: [UUID: Bool],
        onToggle: @escaping (UUID, Bool) -> Void,
        onMove: ((UUID, UUID, Edge) -> Void)?,
        @ViewBuilder movingIndicator: @escaping () -> C,
        @ViewBuilder render: @escaping (UUID, UUID?, UUID?, Bool, Bool?, @escaping (UUID, Bool) -> Void) -> Item
    ) {
        self.catalogs = catalogs
        self.rootId = rootId
        self.currentId = currentId
        self.render = render
        self.expandeds = expandeds
        self.onMove = onMove
        self.onToggle = onToggle
        self.movingIndicator = movingIndicator
    }
    
    var body: some View {
        LazyVStack(spacing: 0) {
            if let rootData = catalogs[rootId]?.data {
                ForEach(rootData, id: \.uuidString) { id in render(id: id) }
            }
        }
    }
    
    @ViewBuilder func render(id: UUID) -> some View {
        if catalogs[id] == nil {
            row(for: id)
        } else {
            Section(header: row(for: id)) {
                if (expandeds[id] ?? false) {
                    LazyVStack(spacing: 0) {
                        ForEach(catalogs[id]!.data, id: \.uuidString) { child in AnyView(render(id: child)) }
                    }
                    .padding(.leading, 24.5)
                }
            }
        }
    }

    @ViewBuilder func row(for id: UUID) -> some View {
        render(id, currentId, movingTo, !(catalogs[id] == nil), expandeds[id], onToggle)
        .if(onMove != nil) {
            $0.onDrag {
                moving = id
                return NSItemProvider(object: "" as NSString)
            } preview: {
                render(id, currentId, movingTo, !(catalogs[id] == nil), expandeds[id], onToggle)
            }
            .opacity(movingTo != nil && id == moving ? 0.4 : 1)
            .if(movingTo == id && moving != id && !(movingEdge != .top && expandeds[movingTo!] ?? false)) {
                $0.overlay(alignment: movingEdge == .top ? .top : .bottom) {
                    movingIndicator().padding(.leading, 23).offset(x: 0, y: movingEdge == .top ? -4 : 4)
                }
            }
            .onDrop(of: [.text], delegate: DropMoveDelegate(value: id, binding: $movingTo, onDrop: onDrop, onUpdated: onDropMove, onDropEntered: onDropEntered))
        }
    }
    
    func onDropMove(info: DropInfo) {
        guard let movingTo = movingTo else {
            return
        }
        
        if let catalog = catalogs[movingTo],
           let expanded = expandeds[movingTo], expanded && !catalog.data.isEmpty {
            movingEdge = .top
        } else {
            movingEdge = info.location.y <= 38 / 2 ? .top : .bottom
        }
    }
    
    func onDrop(info: DropInfo) {
        onMove?(moving!, movingTo!, movingEdge!)
    }
    
    func onDropEntered(info: DropInfo) {
        if catalogs[movingTo!] != nil && !(expandeds[movingTo!] ?? false) {
            onToggle(movingTo!, true)
        }
    }
}

struct CatalogsExplorerRowCtrl: View {
    var id: UUID
    var group: Bool
    var expanded: Bool?
    var onToggle: (UUID, Bool) -> Void

    var body: some View {
        Group {
            if !group {
                Spacer().frame(width: 19, height: 19)
            } else {
                let e = expanded ?? false
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 5, height: 8)
                    .padding(5, 7)
                    .contentShape(Rectangle())
                    .rotationEffect(.degrees(e ? 90 : 0))
                    .onTapGesture { onToggle(id, !e) }
            }
        }
    }
}
