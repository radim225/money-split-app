import SwiftUI

struct SplitInputRow: View {
    let member: Member
    let currencyCode: String
    @Binding var amountString: String
    var isReadOnly: Bool = false
    var displayAmount: Int? = nil

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: member.name, colorHex: member.avatarColorHex, size: 32)

            Text(member.name)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            if isReadOnly, let amount = displayAmount {
                Text(CurrencyFormatter.format(cents: amount, currencyCode: currencyCode))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                HStack(spacing: 4) {
                    TextField("0.00", text: $amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .font(.subheadline.weight(.medium))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
