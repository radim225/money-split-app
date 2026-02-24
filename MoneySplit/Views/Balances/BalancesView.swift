import SwiftUI

struct BalancesView: View {
    let group: SplitGroup
    @StateObject private var vm: BalancesViewModel

    init(group: SplitGroup) {
        self.group = group
        _vm = StateObject(wrappedValue: BalancesViewModel(group: group))
    }

    var body: some View {
        BalancesContent(vm: vm, group: group)
    }
}

private struct BalancesContent: View {
    @ObservedObject var vm: BalancesViewModel
    let group: SplitGroup

    var body: some View {
        List {
            if vm.memberBalances.isEmpty {
                EmptyStateView(
                    systemImage: "arrow.left.arrow.right.circle",
                    title: "No Balances",
                    message: "Add expenses to see who owes whom."
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .frame(minHeight: 300)
            } else {
                // Per-member balances
                Section("Balances") {
                    ForEach(vm.memberBalances, id: \.memberId) { balance in
                        BalanceRowView(balance: balance, currencyCode: group.currencyCode)
                    }
                }

                // Simplified settlements
                if !vm.settlements.isEmpty {
                    Section {
                        ForEach(vm.settlements) { settlement in
                            SettlementRowView(settlement: settlement, currencyCode: group.currencyCode)
                        }
                    } header: {
                        Text("Suggested Settlements")
                    } footer: {
                        Text("Minimum transactions needed to settle all debts.")
                            .font(.caption)
                    }
                }

                // Total spent summary
                Section("Summary") {
                    HStack {
                        Label("Total Spent", systemImage: "creditcard.fill")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(CurrencyFormatter.format(cents: group.totalSpentCents, currencyCode: group.currencyCode))
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Label("Expenses", systemImage: "list.bullet")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(group.expenses.count)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Label("Members", systemImage: "person.2.fill")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(group.members.count)")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    NavigationStack {
        BalancesView(group: PreviewData.sampleGroup)
            .navigationTitle("Balances")
    }
    .modelContainer(PreviewData.container)
}
