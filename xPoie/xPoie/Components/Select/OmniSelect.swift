import SwiftUI

struct OmniSelect<T: Identifiable, Presenter: View, Option: View>: View {
    let value: [T]
    let options: [T]
    let presenter: ([T], Bool, @escaping () -> Void) -> Presenter
    let option: (T, Bool, @escaping () -> Void) -> Option

    @State private var selecting = false
    
    private let noopToggle: () -> Void = {}

    var body: some View {
//        presenter(value, selecting, toggle)
//        .popover(isPresented: $selecting) {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 4) {
//                    ForEach(options) { o in
//                        option(o, value.contains{ $0.id == o.id }, toggle)
//                    }
//                }
//                .padding(12, 6)
//            }
//            .frame(maxHeight: 300)
//        }
        Menu {
            ForEach(options) { o in
                let isActive = value.contains { $0.id == o.id }
                option(o, isActive, noopToggle)
            }
        } label: {
            presenter(value, false, noopToggle)
        }
        .buttonStyle(.omni.with(size: .xs))
        .menuStyle(.button)
        .menuIndicator(.hidden)
        
        //        Picker("", selection: $dummySelection) {
        //            // Keep using the provided `option` view so existing call sites stay unchanged.
        //            // We enumerate options to provide stable Int tags for Picker.
        //            ForEach(Array(options.enumerated()), id: \.offset) { idx, o in
        //                let isActive = value.contains { $0.id == o.id }
        //                option(o, isActive, noopToggle)
        //                    .tag(idx)
        //            }
        ////        } label: {
        ////            presenter(value, false, noopToggle)
        //        }
        //        .pickerStyle(.menu)
        //        .menuIndicator(.hidden)
    }

    func toggle() {
        selecting.toggle()
    }
}

struct OmniSelectPresenter<T: Identifiable, V: View>: View {
    var value: [T]
    var active: Bool
    var toggle: () -> Void
    var style: OmniButtonStyle = .omni
    var render: ([T], Bool) -> V
    
    var body: some View {
//        Button(action: toggle) {
            HStack(spacing: 4) {
                render(value, active)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(1, 2)
//        }
//        .buttonStyle(style.with(size: .md, active: active))
    }
}

struct OmniSelectOption<T: Identifiable, V: View>: View {
    var value: T
    var active: Bool
    var action: (T) -> Void
    var render: (T, Bool) -> V
    
    var body: some View {
        Button(action: { action(value) }) {
            HStack {
                render(value, active)
                Spacer()
                if active {
                    Image(systemName: "checkmark").font(.caption)
                }
            }
            .padding(.horizontal, 4)
        }
        .buttonStyle(.omni.with(padding: .md, active: active))
    }
}
