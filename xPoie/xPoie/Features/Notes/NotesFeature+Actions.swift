import Foundation
import SwiftUI

typealias NotesAction = ShortAction

extension NotesAction {
    static let new = NotesAction(
        id: "new",
        icon: "plus",
        label: "Add new",
        keywords: ["create", "add", "new", "note"],
        shortcut: (modifiers: [.command], key: "n"),
        destructive: false
    )

    static let moveTo = NotesAction(
        id: "moveTo",
        icon: "arrow.right.page.on.clipboard",
        label: "Move to",
        keywords: ["move", "transfer", "project", "pad"],
        shortcut: (modifiers: [.command, .shift], key: "m"),
        destructive: false
    )

    static let delete = NotesAction(
        id: "delete",
        icon: "plus",
        label: "Delete",
        keywords: ["remove", "delete", "trash"],
        shortcut: (modifiers: [.command, .shift], key: "d"),
        destructive: true
    )

    static let focus = NotesAction(
        id: "focus",
        icon: "plus",
        label: "Focus",
        keywords: ["focus", "pin", "highlight"],
        shortcut: (modifiers: [.command], key: "f"),
        destructive: false
    )
    static let browse = NotesAction(
        id: "browse",
        icon: "plus",
        label: "Browse",
        keywords: ["browse"],
        shortcut: (modifiers: [.command], key: "b"),
        destructive: false
    )
}

struct NotesActionProvider {
    static func next(in items: [NotesAction], current: NotesAction, step: Int) -> NotesAction? {
        let index = items.firstIndex{ $0 == current } ?? 0
        let target = max(0, min(index + step, items.count - 1))
        return target < items.count ? items[target] : nil
    }
}
