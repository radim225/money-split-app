import SwiftUI

@MainActor
final class BalancesViewModel: ObservableObject {
    @Published private(set) var memberBalances: [BalanceCalculator.MemberBalance] = []
    @Published private(set) var settlements: [BalanceCalculator.Settlement] = []

    let group: SplitGroup

    init(group: SplitGroup) {
        self.group = group
        reload()
    }

    func reload() {
        memberBalances = BalanceCalculator.balances(
            for: group.members,
            expenses: group.expenses
        ).sorted { abs($0.netCents) > abs($1.netCents) }

        settlements = BalanceCalculator.settlements(from: memberBalances)
    }
}
