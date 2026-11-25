import SwiftUI

/// One persisted preference for every layout, presentation and web view.
enum DDAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    static let key = "douyin_appearance_v1"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "跟随系统"
        case .light: "亮色"
        case .dark: "暗色"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

extension DDAppearance {
    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    /// 外观只设在窗口上：窗口下的所有界面（包括已经弹出的设置页）一起变。
    /// 以前用 SwiftUI 的 preferredColorScheme：从「暗色」改回「跟随系统」（传 nil）时，
    /// 已弹出的设置页会停在暗色，不跟系统实时变化；.unspecified 才会把外观真正交还给系统。
    @MainActor static func applyToWindows(_ raw: String) {
        let style = (DDAppearance(rawValue: raw) ?? .dark).interfaceStyle
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            for window in scene.windows where window.overrideUserInterfaceStyle != style {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

extension Color {
    static let ddBackground = Color("AppBackground")
    static let ddSecondaryBackground = Color("AppSecondaryBackground")
    static let ddMessageListBackground = Color("MessageListBackground")
    static let ddMessageChatBackground = Color("MessageChatBackground")
    static let ddMessagePinnedRow = Color("MessagePinnedRow")
    static let ddSeparator = Color("AppSeparator")
    /// 信息页左右分栏（联系人 | 聊天）之间的分割线，比普通分隔线更显眼
    static let ddMessageSplitDivider = Color("MessageSplitDivider")
}

/// 全局文字大小档位：同时作用于评论区、首页文案、设置、消息与弹幕。
enum DDTextSize: String, CaseIterable, Identifiable {
    case small, standard, large, system

    static let key = "douyin_text_size_v1"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .small: "偏小"
        case .standard: "标准"
        case .large: "偏大"
        case .system: "系统"
        }
    }

    var dynamicTypeSize: DynamicTypeSize? {
        switch self {
        case .small: .small
        case .standard: .medium
        case .large: .large
        case .system: nil
        }
    }

    static var current: DDTextSize {
        DDTextSize(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .standard
    }
}

struct DDTextSizeModifier: ViewModifier {
    @AppStorage(DDTextSize.key) private var raw = DDTextSize.standard.rawValue

    @ViewBuilder
    func body(content: Content) -> some View {
        if let size = (DDTextSize(rawValue: raw) ?? .standard).dynamicTypeSize {
            content.dynamicTypeSize(size)
        } else {
            content
        }
    }
}
