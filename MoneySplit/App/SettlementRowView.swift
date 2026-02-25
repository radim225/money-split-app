import SwiftUI

struct SettlementRowView: View {
    let settlement: Settlement
    let group: SplitGroup
    
    private var fromMember: Member? {
        group.members.first { $0.id == settlement.fromMemberId }
    }
    
    private var toMember: Member? {
        group.members.first { $0.id == settlement.toMemberId }
    }

    var body: some View {
        HStack(spacing: 10) {
            if let from = fromMember {
                AvatarView(name: from.name, colorHex: from.avatarColorHex, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(from.name)
                        .font(.subheadline.weight(.medium))
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.accentColor)
                        if let to = toMember {
                            Text(to.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.format(cents: settlement.amountCents, currencyCode: group.currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.accentColor)
                    if let to = toMember {
                        AvatarView(name: to.name, colorHex: to.avatarColorHex, size: 20)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let group = PreviewData.sampleGroup
    let settlement = Settlement(
        fromMemberId: group.members[1].id,
        toMemberId: group.members[0].id,
        amountCents: 5000
    )
    return List {
        SettlementRowView(settlement: settlement, group: group)
    }
    .modelContainer(PreviewData.container)
}
