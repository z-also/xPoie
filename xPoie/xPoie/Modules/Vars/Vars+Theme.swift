extension Modules.Vars {
    func set(theme: Theme) {
        self.theme = theme
        Preferences[.theme] = theme.name
        Modules.spotlight.set(theme: theme)
    }
}
