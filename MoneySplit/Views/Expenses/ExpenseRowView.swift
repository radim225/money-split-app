import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    let group: SplitGroup

    var payer: Member? {
        group.members.first { $0.id == expense.payerId }
    }

    var body: some View {
        HStack(spacing: 12) {
            CategoryBadge(category: expense.category, style: .icon)

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let payer {
                        AvatarView(name: payer.name, colorHex: payer.avatarColorHex, size: 16)
                        Text(payer.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(cents: expense.amountCents, currencyCode: group.currencyCode))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("\(expense.splits.count) people")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
