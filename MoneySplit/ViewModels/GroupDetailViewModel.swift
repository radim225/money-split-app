import SwiftUI
import SwiftData

@MainActor
final class GroupDetailViewModel: ObservableObject {

    struct CategoryTotal: Identifiable {
        let id: String
        let category: ExpenseCategory
        let amountCents: Int
        var fraction: Double = 0
    }

    struct MemberSummary: Identifiable {
        let id: UUID
        let name: String
        let colorHex: String
        let paidCents: Int
        let shareCents: Int
        var netCents: Int { paidCents - shareCents }
    }

    @Published private(set) var totalSpentCents: Int = 0
    @Published private(set) var categoryTotals: [CategoryTotal] = []
    @Published private(set) var memberSummaries: [MemberSummary] = []
    @Published private(set) var recentExpenses: [Expense] = []

    let group: SplitGroup

    init(group: SplitGroup) {
        self.group = group
        reload()
    }

    func reload() {
        let expenses = group.expenses
        let members = group.members

        totalSpentCents = expenses.reduce(0) { $0 + $1.amountCents }

        // Category breakdown
        var catMap: [String: Int] = [:]
        for expense in expenses {
            catMap[expense.categoryId, default: 0] += expense.amountCents
        }
        let catList = catMap.map { key, cents -> CategoryTotal in
            CategoryTotal(id: key, category: ExpenseCategory.from(key), amountCents: cents)
        }.sorted { $0.amountCents > $1.amountCents }

        categoryTotals = catList.map { item in
            var t = item
            t.fraction = totalSpentCents > 0 ? Double(item.amountCents) / Double(totalSpentCents) : 0
            return t
        }

        // Member summaries using BalanceCalculator
        let balances = BalanceCalculator.balances(for: members, expenses: expenses)
        memberSummaries = balances.map { b in
            MemberSummary(
                id: b.memberId,
                name: b.name,
                colorHex: b.colorHex,
                paidCents: b.paidCents,
                shareCents: b.shareCents
            )
        }

        recentExpenses = expenses.sorted { $0.date > $1.date }.prefix(5).map { $0 }
    }
}
