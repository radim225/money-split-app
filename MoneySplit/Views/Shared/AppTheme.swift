import SwiftUI

enum AppTheme {
    static let accentColor = Color("AccentColor")

    static let avatarColors: [String] = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFCC5C", "#FF6F69", "#88D8B0", "#C3A6FF",
        "#FFA07A", "#7EC8E3"
    ]

    static let groupColors: [String] = [
        "#6C63FF", "#FF6B6B", "#4ECDC4", "#FFCC5C",
        "#FF6F69", "#45B7D1", "#96CEB4", "#A8A8A8"
    ]

    static let groupEmojis: [String] = [
        "✈️", "🏠", "🍕", "🎉", "🏕️", "🛒", "💰", "🎓",
        "🏖️", "🚗", "🎭", "🏋️", "🎮", "🍻", "💼", "🏥"
    ]

    static let cardCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let sectionSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let horizontalPadding: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
