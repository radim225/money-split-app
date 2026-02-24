import SwiftUI

struct AvatarView: View {
    let name: String
    let colorHex: String
    var size: CGFloat = 36

    private var initials: String {
        name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    var body: some View {
        Circle()
            .fill(Color(hex: colorHex))
            .frame(width: size, height: size)
            .overlay {
                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
    }
}

#Preview {
    HStack(spacing: 12) {
        AvatarView(name: "Alice Smith", colorHex: "#FF6B6B", size: 44)
        AvatarView(name: "Bob", colorHex: "#4ECDC4", size: 44)
        AvatarView(name: "Carol D", colorHex: "#FFCC5C", size: 44)
    }
    .padding()
}
