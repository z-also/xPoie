import Foundation
import HotKey
import AppKit

struct Preferences {
    struct Item<Value, U> {
        var key: String
        var defaultValue: Value
        var encode: ((Value) -> U)?
        var decode: ((U) -> Value)?
    }

    static subscript<T, U>(item: Item<T, U>) -> T {
        set {
            guard let v = item.encode?(newValue) else {
                UserDefaults.standard.setValue(newValue, forKey: item.key)
                return
            }
            
            UserDefaults.standard.setValue(v, forKey: item.key)
        }
        get {
            guard let v = UserDefaults.standard.value(forKey: item.key) as? U else {
                return item.defaultValue
            }
            
            return item.decode?(v) as? T ?? v as? T ?? item.defaultValue
        }
    }
}

extension Preferences.Item {
    static var theme: Preferences.Item<String, String> {
        return .init(key: #function, defaultValue: Theme.plastic.name)
    }
    
    static var scene: Preferences.Item<Modules.Main.Scene, String> {
        return .init(
            key: #function,
            defaultValue: .projects,
            encode: { s in s.rawValue },
            decode: { s in Modules.Main.Scene(rawValue: s)! }
        )
    }
    
    static var spotlightTheme: Preferences.Item<String, String> {
        return .init(key: #function, defaultValue: Theme.plastic.name)
    }

    static var selectedCalendarSpace: Preferences.Item<Set<UUID>, [String]> {
        return .init(
            key: #function,
            defaultValue: [],
            encode: { s in Array(s).map{ $0.uuidString } },
            decode: { s in Set<UUID>(s.compactMap{ UUID(uuidString: $0) }) }
        )
    }

    static var spotlightHotkey: Preferences.Item<Hotkey.Shortcut, [String: Any]> {
        .init(
            key: #function,
            defaultValue: Hotkey.Shortcut(key: .p, modifiers: [.option]),
            encode: { shortcut in
                var dict: [String: Any] = [:]
                dict["key"] = shortcut.key?.carbonKeyCode
                dict["modifiers"] = shortcut.modifiers.rawValue
                return dict
            },
            decode: { dict in
                guard let keyRaw = dict["key"] as? UInt16,
                    let modRaw = dict["modifiers"] as? UInt else {
                    return Hotkey.Shortcut(key: nil, modifiers: [])
                }
                let key = Key(carbonKeyCode: UInt32(keyRaw))
                return Hotkey.Shortcut(key: key, modifiers: NSEvent.ModifierFlags(rawValue: modRaw))
            }
        )
    }
    
    static var signedIn: Preferences.Item<Bool, Bool> {
        return .init(key: #function, defaultValue: false)
    }
}
