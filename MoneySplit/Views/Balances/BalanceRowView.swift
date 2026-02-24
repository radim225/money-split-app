import SwiftUI

struct BalanceRowView: View {
    let balance: BalanceCalculator.MemberBalance
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: balance.name, colorHex: balance.colorHex, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(balance.name)
                    .font(.subheadline.weight(.medium))
                Text("Paid \(CurrencyFormatter.format(cents: balance.paidCents, currencyCode: currencyCode))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                let net = balance.netCents
                if net == 0 {
                    Text("Even")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                } else if net > 0 {
                    Text("gets back")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(cents: net, currencyCode: currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.green)
                } else {
                    Text("owes")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(cents: -net, currencyCode: currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
