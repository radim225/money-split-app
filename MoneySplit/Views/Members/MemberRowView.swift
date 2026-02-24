import SwiftUI

struct MemberRowView: View {
    let member: Member
    let currencyCode: String
    let netCents: Int?

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(name: member.name, colorHex: member.avatarColorHex, size: 40)

            Text(member.name)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            if let net = netCents {
                VStack(alignment: .trailing, spacing: 2) {
                    if net == 0 {
                        Text("Even")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    } else if net > 0 {
                        Text("gets back")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(cents: net, currencyCode: currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                    } else {
                        Text("owes")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(cents: -net, currencyCode: currencyCode))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
