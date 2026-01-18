import SwiftUI

struct Presenter {
    var name: String
}


extension Presenter {
    static let thumbtack: Self = .init(
        name: "thumbtack"
    )
    
    static let dotty: Self = .init(
        name: "dotty"
    )
    
    static let presets: [Presenter] = [
        .thumbtack,
        .dotty
    ]
}
