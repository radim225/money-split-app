import SwiftUI

struct GroupRowView: View {
    let group: SplitGroup

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: group.colorHex).opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(group.emoji)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(group.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Label("\(group.members.count)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if group.expenses.count > 0 {
                        Text("·")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Label("\(group.expenses.count) expenses", systemImage: "list.bullet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(CurrencyFormatter.format(cents: group.totalSpentCents, currencyCode: group.currencyCode))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                if let last = group.lastActivity {
                    Text(last, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        GroupRowView(group: PreviewData.sampleGroup)
    }
    .modelContainer(PreviewData.container)
}
