import SwiftUI

@MainActor
final class MemberDetailViewModel: ObservableObject {
    @Published private(set) var paidExpenses: [Expense] = []
    @Published private(set) var involvedExpenses: [Expense] = []
    @Published private(set) var totalPaidCents: Int = 0
    @Published private(set) var totalShareCents: Int = 0
    @Published private(set) var categoryBreakdown: [GroupDetailViewModel.CategoryTotal] = []

    var netCents: Int { totalPaidCents - totalShareCents }

    let member: Member
    let group: SplitGroup

    init(member: Member, group: SplitGroup) {
        self.member = member
        self.group = group
        reload()
    }

    func reload() {
        let expenses = group.expenses

        paidExpenses = expenses.filter { $0.payerId == member.id }.sorted { $0.date > $1.date }
        involvedExpenses = expenses.filter { expense in
            expense.splits.contains { $0.memberId == member.id }
        }.sorted { $0.date > $1.date }

        totalPaidCents = paidExpenses.reduce(0) { $0 + $1.amountCents }
        totalShareCents = involvedExpenses.reduce(0) { total, expense in
            let share = expense.splits.first { $0.memberId == member.id }?.amountCents ?? 0
            return total + share
        }

        // Category breakdown of what they participated in
        var catMap: [String: Int] = [:]
        for expense in involvedExpenses {
            let share = expense.splits.first { $0.memberId == member.id }?.amountCents ?? 0
            catMap[expense.categoryId, default: 0] += share
        }
        categoryBreakdown = catMap.map { key, cents in
            GroupDetailViewModel.CategoryTotal(
                id: key,
                category: ExpenseCategory.from(key),
                amountCents: cents,
                fraction: totalShareCents > 0 ? Double(cents) / Double(totalShareCents) : 0
            )
        }.sorted { $0.amountCents > $1.amountCents }
    }
}
