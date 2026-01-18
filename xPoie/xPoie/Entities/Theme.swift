import SwiftUI

struct Theme {
    var name: String
    var text: Text
    var fill: Fill
    var semantic: Semantic

    struct Semantic {
        // 品牌色
        var brand: Color
        // 特殊
        var plain: Color
        // 状态色
        var primary: Color
        var success: Color
        var warning: Color
        var error: Color
        var info: Color
    }

    struct Text {
        // 主要文本
        var primary: Color      // 标题文本，85% 黑
        var secondary: Color    // 主要段落，65% 黑
        var tertiary: Color     // 次要段落，45% 黑
        var quaternary: Color   // 辅助说明，25% 黑
        var quinary: Color      // 第五
        
        // 特殊状态
        var disabled: Color     // 禁用状态，25% 黑
        var reversed: Color     // 反色文本，纯白
        var placeholder: Color  // 占位符，25% 黑
        
        // 链接文本
        var link: Color         // 链接颜色，品牌色
        var linkHover: Color    // 链接悬停，品牌色 hover
        var linkActive: Color   // 链接激活，品牌色 active
        
        // 特殊文本
        var code: Color         // 代码文本，85% 黑
        var success: Color      // 成功状态文本
        var warning: Color      // 警告状态文本
        var error: Color        // 错误状态文本
        var destructive: Color  // 删除类的
    }

    struct Fill {
        // 基础填充
        var primary: Color      // 主要填充色
        var secondary: Color    // 次要填充色
        var tertiary: Color     // 第三级填充色
        var quaternary: Color   // 第四级填充色
        var quinary: Color      // 第五

        // 状态填充
        var hover: Color        // 悬停状态
        var active: Color       // 激活状态
        var selected: Color     // 选中状态
        var disabled: Color     // 禁用状态
        
        // 特殊用途
        var light: Color        // 浅色填充
        var lighter: Color      // 更浅色填充
        var dark: Color         // 深色填充
        var darker: Color       // 更深色填充
        
        var vivid0: Color       // 彩色
        
        // 容器
        var glass: Color        // 背景
        var window: Color       // 窗口
        var popover: Color      // 弹窗
        var widget: Color       // widget
        var track: Color        // 轨道
    }
}

extension Theme {
    static func of(_ name: String) -> Self {
        return .init(
            name: name,
            text: .init(
                primary: Color("theme.\(name)/text.primary"),
                secondary: Color("theme.\(name)/text.secondary"),
                tertiary: Color("theme.\(name)/text.tertiary"),
                quaternary: Color("theme.\(name)/text.quaternary"),
                quinary: Color("theme.\(name)/text.quinary"),
                disabled: Color("theme.\(name)/text.disabled"),
                reversed: Color("theme.\(name)/text.reversed"),
                placeholder: Color("theme.\(name)/text.placeholder"),
                link: Color("theme.\(name)/text.link"),
                linkHover: Color("theme.\(name)/text.linkHover"),
                linkActive: Color("theme.\(name)/text.linkActive"),
                code: Color("theme.\(name)/text.code"),
                success: Color("theme.\(name)/text.success"),
                warning: Color("theme.\(name)/text.warning"),
                error: Color("theme.\(name)/text.error"),
                destructive: Color("theme.\(name)/text.destructive")
            ),
            fill: .init(
                primary: Color("theme.\(name)/fill.primary"),
                secondary: Color("theme.\(name)/fill.secondary"),
                tertiary: Color("theme.\(name)/fill.tertiary"),
                quaternary: Color("theme.\(name)/fill.quaternary"),
                quinary: Color("theme.\(name)/fill.quinary"),
                hover: Color("theme.\(name)/fill.hover"),
                active: Color("theme.\(name)/fill.active"),
                selected: Color("theme.\(name)/fill.selected"),
                disabled: Color("theme.\(name)/fill.disabled"),
                light: Color("theme.\(name)/fill.light"),
                lighter: Color("theme.\(name)/fill.lighter"),
                dark: Color("theme.\(name)/fill.dark"),
                darker: Color("theme.\(name)/fill.darker"),
                vivid0: Color("theme.\(name)/fill.vivid.0"),
                glass: Color("theme.\(name)/fill.glass"),
                window: Color("theme.\(name)/fill.window"),
                popover: Color("theme.\(name)/fill.popover"),
                widget: Color("theme.\(name)/fill.widget"),
                track: Color("theme.\(name)/fill.track")
            ),
            semantic: .init(
                brand: Color("theme.\(name)/semantic.brand"),
                plain: Color("theme.\(name)/semantic.plain"),
                primary: Color("theme.\(name)/semantic.primary"),
                success: Color("theme.\(name)/semantic.success"),
                warning: Color("theme.\(name)/semantic.warning"),
                error: Color("theme.\(name)/semantic.error"),
                info: Color("theme.\(name)/semantic.info")
            )
        )
    }
    
    static let dark: Self = .of("dark")

    static let plastic: Self = .of("plastic")
    
    static let flat: Self = .of("flat")

    static let liquid: Self = .of("liquid")

    static func named(_ name: String) -> Self? {
        let preset: [Theme] = [
            .plastic, .flat, .dark, .liquid
        ]
        
        return preset.first { $0.name == name }
    }
}
