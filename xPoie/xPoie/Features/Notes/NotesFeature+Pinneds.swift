import SwiftUI
//import WaterfallGrid

struct NotesFeaturePinneds: View {
    let notes: [Models.Note]
    let layout: Models.Pad.Layout

    var body: some View {
//        if layout == .grid {
//            WaterfallGrid(notes, id: \.id) { note in
//                return NotesFeaturePresenter(note: note, active: false)
//            }
//            .gridStyle(
//                columns: 2,
////                                    animation: .easeInOut(duration: 0.3)
//                animation: nil
//            )
//            .padding(0, 16)
//        } else {
            ForEach(notes, id: \.id) { note in
                NotesFeaturePresenter(note: note, active: false)
            }
//        }
        
        Image(systemName: "ellipsis")
            .resizable()
            .frame(width: 15, height: 3)
            .padding(8, 6)
    }
}
