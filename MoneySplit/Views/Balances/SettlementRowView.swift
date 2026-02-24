import SwiftUI

struct SettlementRowView: View {
    let settlement: BalanceCalculator.Settlement
    let currencyCode: String

    var body: some View {
        HStack(spacing: 10) {
            AvatarView(name: settlement.fromName, colorHex: settlement.fromColorHex, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(settlement.fromName)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accentColor)
                    Text(settlement.toName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(cents: settlement.amountCents, currencyCode: currencyCode))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.accentColor)
                AvatarView(name: settlement.toName, colorHex: settlement.toColorHex, size: 20)
            }
        }
        .padding(.vertical, 4)
    }
}
