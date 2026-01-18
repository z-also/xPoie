import AppKit

extension NSFont {
    var defaultLineHeight: CGFloat {
        return capHeight - descender + leading
//        return self.ascender - self.descender + self.leading
    }
}
