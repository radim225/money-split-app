import SwiftUI

struct CategoryBadge: View {
    let category: ExpenseCategory
    var style: Style = .pill

    enum Style {
        case pill    // colored background + icon + text
        case icon    // just colored circle with icon
        case compact // icon + text, no background
    }

    var body: some View {
        switch style {
        case .pill:
            HStack(spacing: 4) {
                Image(systemName: category.systemImage)
                    .font(.caption.weight(.medium))
                Text(category.displayName)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(category.accentColor.opacity(0.15), in: Capsule())
            .foregroundStyle(category.accentColor)

        case .icon:
            ZStack {
                Circle()
                    .fill(category.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: category.systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(category.accentColor)
            }

        case .compact:
            Label(category.displayName, systemImage: category.systemImage)
                .font(.subheadline)
                .foregroundStyle(category.accentColor)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(ExpenseCategory.allCases) { cat in
            HStack(spacing: 12) {
                CategoryBadge(category: cat, style: .icon)
                CategoryBadge(category: cat, style: .pill)
                CategoryBadge(category: cat, style: .compact)
            }
        }
    }
    .padding()
}
