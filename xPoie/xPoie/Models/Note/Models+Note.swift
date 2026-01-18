import RTex
import SwiftUI
import SwiftData

extension Models {
    @Model class Note {
        var id: UUID
        var icon: String
        var parent: UUID?
        var rank: String
        var title: String
        var color: String
        var visual: String
        var presenter: String
        var createdAt: Date
        var stickyOpacity: CGFloat
        var pinned: String
        var _sticky: String
        var _content: Data
        
        @Transient
        lazy var content: AttributedString = initializeContent() {
            didSet {
                do {
                    _content = try JSONEncoder().encode(
                        content,
                        configuration: RTex.Attributes.encodingConfiguration
                    )
                } catch {
                    fatalError("save on edit failedd")
                }
            }
        }

        var sticky: CGRect {
            get {
                return Utilities.rect(from: _sticky)
            }
            set {
                _sticky = Utilities.string(from: newValue)
            }
        }

        struct Metas {
            var id: UUID?
            var title = ""
            var parent: UUID?
            var content = AttributedString("")
        }

        init(parent: UUID? = nil, title: String = "", rank: String = "", content: AttributedString? = nil) {
            self.id = UUID()
            self.icon = ""
            self.parent = parent
            self.rank = rank
            self.title = title
            self.visual = ""
            self.presenter = ""
            self._sticky = ""
            self.createdAt = .now
            self.stickyOpacity = 1.0
            self.pinned = ""
            self.color = ""
            self._content = Data()
        }
        
        private func initializeContent() -> AttributedString {
            do {
                let content = try JSONDecoder().decode(
                    AttributedString.self,
                    from: _content,
                    configuration: RTex.Attributes.decodingConfiguration
                )
                return content
            } catch {
                print("Error loading attributed string for content: \(error)")
                return ""
            }
        }
    }
}
