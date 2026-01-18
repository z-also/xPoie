import SwiftUI

struct DropMoveCursor: View {
    var color: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .frame(width: 6, height: 8)
                .foregroundStyle(color)
            
            Rectangle().fill(color).frame(height: 2)
        }
    }
}

struct DropMoveDelegate<T>: DropDelegate {
    var value: T?
    @Binding var binding: T?

    var onDrop: (DropInfo) -> Void
    var onUpdated: (DropInfo) -> Void
    var onDropEntered: (DropInfo) -> Void

    func dropUpdated(info: DropInfo) -> DropProposal? {
        onUpdated(info)
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        withAnimation {
            onDrop(info)
            binding = nil
        }
        return true
    }
    
    func dropEntered(info: DropInfo) {
        binding = value
        onDropEntered(info)
    }
    
    func dropExited(info: DropInfo) {
        binding = nil
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
}
