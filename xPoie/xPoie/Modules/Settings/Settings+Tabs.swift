extension Modules.Settings {
    struct Tabs {
        struct Item: Identifiable {
            var id: Id
            var icon: String
            var name: String
        }
    
        enum Id: Equatable, Hashable {
            case general
            case behavior
            case appearance
            case shortcuts
        }
    }
}
