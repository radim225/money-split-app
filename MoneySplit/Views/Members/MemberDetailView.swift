import SwiftUI
import Charts

struct MemberDetailView: View {
    let member: Member
    let group: SplitGroup
    @StateObject private var vm: MemberDetailViewModel

    init(member: Member, group: SplitGroup) {
        self.member = member
        self.group = group
        _vm = StateObject(wrappedValue: MemberDetailViewModel(member: member, group: group))
    }

    var body: some View {
        MemberDetailContent(vm: vm, group: group)
            .navigationTitle(member.name)
            .navigationBarTitleDisplayMode(.large)
    }
}

private struct MemberDetailContent: View {
    @ObservedObject var vm: MemberDetailViewModel
    let group: SplitGroup

    var body: some View {
        List {
            // Balance header
            Section {
                HStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 4) {
                        AvatarView(name: vm.member.name, colorHex: vm.member.avatarColorHex, size: 64)
                        Text(vm.member.name)
                            .font(.title3.weight(.semibold))
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)

                HStack(spacing: 0) {
                    statCard(title: "Paid", cents: vm.totalPaidCents, color: .blue)
                    Divider()
                    statCard(title: "Share", cents: vm.totalShareCents, color: .orange)
                    Divider()
                    statCard(title: "Net", cents: vm.netCents, color: vm.netCents >= 0 ? .green : .red)
                }
                .frame(height: 72)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            }

            // Category breakdown
            if !vm.categoryBreakdown.isEmpty {
                Section("Spending by Category") {
                    Chart(vm.categoryBreakdown) { item in
                        SectorMark(
                            angle: .value("Amount", item.amountCents),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .foregroundStyle(item.category.accentColor)
                        .cornerRadius(4)
                    }
                    .frame(height: 160)
                    .padding(.vertical, 8)

                    ForEach(vm.categoryBreakdown) { item in
                        HStack {
                            CategoryBadge(category: item.category, style: .icon)
                            Text(item.category.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text(CurrencyFormatter.format(cents: item.amountCents, currencyCode: group.currencyCode))
                                .font(.subheadline.weight(.medium))
                        }
                    }
                }
            }

            // Expenses paid by this member
            if !vm.paidExpenses.isEmpty {
                Section("Paid By \(vm.member.name)") {
                    ForEach(vm.paidExpenses) { expense in
                        expenseRow(expense)
                    }
                }
            }

            // Expenses this member is involved in (but didn't pay)
            let involvedNotPaid = vm.involvedExpenses.filter { $0.payerId != vm.member.id }
            if !involvedNotPaid.isEmpty {
                Section("Involved In") {
                    ForEach(involvedNotPaid) { expense in
                        expenseRow(expense)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func statCard(title: String, cents: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.format(cents: abs(cents), currencyCode: group.currencyCode))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func expenseRow(_ expense: Expense) -> some View {
        let share = expense.splits.first { $0.memberId == vm.member.id }?.amountCents
        HStack(spacing: 12) {
            CategoryBadge(category: expense.category, style: .icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.subheadline)
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let share {
                    Text(CurrencyFormatter.format(cents: share, currencyCode: group.currencyCode))
                        .font(.subheadline.weight(.medium))
                }
                Text(CurrencyFormatter.format(cents: expense.amountCents, currencyCode: group.currencyCode))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MemberDetailView(
            member: PreviewData.sampleMembers[0],
            group: PreviewData.sampleGroup
        )
    }
    .modelContainer(PreviewData.container)
}
