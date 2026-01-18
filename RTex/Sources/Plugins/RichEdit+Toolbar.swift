import SwiftUI
import AppKit

public struct YoRichEditToolbar: View {
    public var onBold: (() -> Void)?
    public var onItalic: (() -> Void)?
    public var onLink: (() -> Void)?
    public var onCode: (() -> Void)?
    public var onImage: (() -> Void)?
    
    // 状态参数
    public var isBold: Bool = false
    public var isItalic: Bool = false
    
    public init(
        onBold: (() -> Void)? = nil,
        onItalic: (() -> Void)? = nil,
        onLink: (() -> Void)? = nil,
        onCode: (() -> Void)? = nil,
        onImage: (() -> Void)? = nil,
        isBold: Bool = false,
        isItalic: Bool = false
    ) {
        self.onBold = onBold
        self.onItalic = onItalic
        self.onLink = onLink
        self.onCode = onCode
        self.onImage = onImage
        self.isBold = isBold
        self.isItalic = isItalic
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            ToolbarButton(
                icon: "bold",
                isActive: isBold,
                shortcut: "b",
                action: onBold
            )
            
            ToolbarButton(
                icon: "italic",
                isActive: isItalic,
                shortcut: "i",
                action: onItalic
            )
            
            Divider()
                .frame(height: 16)
            
            ToolbarButton(
                icon: "link",
                isActive: false,
                shortcut: "l",
                action: onLink
            )
            
            ToolbarButton(
                icon: "chevron.left.forwardslash.chevron.right",
                isActive: false,
                shortcut: "n",
                action: onCode
            )
            
            Divider()
                .frame(height: 16)
            
            ToolbarButton(
                icon: "photo",
                isActive: false,
                shortcut: "m",
                action: onImage
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
    }
}

private struct ToolbarButton: View {
    let icon: String
    let isActive: Bool
    let shortcut: KeyEquivalent
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive ? Color(NSColor.controlAccentColor) : Color(NSColor.labelColor))
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isActive ? Color(NSColor.controlAccentColor).opacity(0.1) : Color.clear)
        )
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        .keyboardShortcut(shortcut)
    }
}

