import SwiftUI

enum Status: Int {
    case normal = 1
    case pending = 2
    case nomore = 4
    case success = 8
    case fail = 16
}

enum Visibility {
    case hidden
    case visible
}

struct Option<T: Hashable & Sendable, V: Sendable>: Identifiable, Sendable {
    var id: T
    var icon: String = ""
    var color: String = ""
    var title: String = ""
    var value: V
}

struct Collection<T> {
    var data: [T]
    var status: Status = .normal
    var cursor: Int = 0
}

enum Field: Hashable {
    case none
    case row(id: UUID)
    case desc(id: UUID)
    case title(id: UUID)
    case notes(id: UUID)
    case content(id: UUID)
    case prompt
    case search
    case misc(tag: String)
    case title0
    case notes0
}

enum Size {
    case small
    case large
}

struct Explorer<T> {
    var data: [T]
    var cursor: Int = 0
    var status: Status = .normal
}

struct Guide {
    var image: String
    var title: String
    var desc: String
}

enum Index {
    case first
    case last
}

enum Position {
    case before
    case after
    case inside
}

enum At {
    case before
}

protocol Span {
    var startAt: Date? { get }
    var endAt: Date? { get }
}

typealias PadLayoutOption = Option<Models.Pad.Layout, Models.Pad.Layout>

enum Scenary {
    case app
    case widget
    case panel
}


struct ShortAction: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String
    let keywords: [String]
    let shortcut: (modifiers: EventModifiers, key: Character)?
    let destructive: Bool
}

extension ShortAction {
    static func ==(lhs: ShortAction, rhs: ShortAction) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
