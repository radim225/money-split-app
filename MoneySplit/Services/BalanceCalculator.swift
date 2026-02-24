import Foundation

enum BalanceCalculator {

    struct MemberBalance {
        let memberId: UUID
        let name: String
        let colorHex: String
        var paidCents: Int
        var shareCents: Int
        var netCents: Int { paidCents - shareCents }
    }

    struct Settlement: Identifiable {
        let id = UUID()
        let fromId: UUID
        let fromName: String
        let fromColorHex: String
        let toId: UUID
        let toName: String
        let toColorHex: String
        let amountCents: Int
    }

    /// Calculates net balance for every member in a group.
    /// positive netCents = others owe this member
    /// negative netCents = this member owes others
    static func balances(for members: [Member], expenses: [Expense]) -> [MemberBalance] {
        var result: [MemberBalance] = []
        for member in members {
            var paid = 0
            var share = 0
            for expense in expenses {
                if expense.payerId == member.id {
                    paid += expense.amountCents
                }
                if let split = expense.splits.first(where: { $0.memberId == member.id }) {
                    share += split.amountCents
                }
            }
            result.append(MemberBalance(
                memberId: member.id,
                name: member.name,
                colorHex: member.avatarColorHex,
                paidCents: paid,
                shareCents: share
            ))
        }
        return result
    }

    /// Greedy settlement minimization algorithm.
    /// Produces the minimum number of transactions to settle all debts.
    static func settlements(from balances: [MemberBalance]) -> [Settlement] {
        var creditors = balances.filter { $0.netCents > 0 }.sorted { $0.netCents > $1.netCents }
        var debtors   = balances.filter { $0.netCents < 0 }.sorted { $0.netCents < $1.netCents }

        var result: [Settlement] = []

        while !creditors.isEmpty && !debtors.isEmpty {
            var creditor = creditors.removeFirst()
            var debtor   = debtors.removeFirst()

            let amount = min(creditor.netCents, -debtor.netCents)

            result.append(Settlement(
                fromId: debtor.memberId,
                fromName: debtor.name,
                fromColorHex: debtor.colorHex,
                toId: creditor.memberId,
                toName: creditor.name,
                toColorHex: creditor.colorHex,
                amountCents: amount
            ))

            var remainCredit = creditor
            remainCredit.paidCents -= amount
            var remainDebt = debtor
            remainDebt.paidCents += amount

            if remainCredit.netCents > 0 {
                let insertAt = creditors.firstIndex(where: { $0.netCents < remainCredit.netCents }) ?? creditors.endIndex
                creditors.insert(remainCredit, at: insertAt)
            }
            if remainDebt.netCents < 0 {
                let insertAt = debtors.firstIndex(where: { $0.netCents > remainDebt.netCents }) ?? debtors.endIndex
                debtors.insert(remainDebt, at: insertAt)
            }
        }

        return result
    }
}
