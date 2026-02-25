import SwiftUI
import SwiftData

struct BalancesView: View {
    let group: SplitGroup
    
    private var balances: [UUID: Int] {
        BalanceCalculator.calculateBalances(for: group)
    }
    
    private var settlements: [Settlement] {
        BalanceCalculator.calculateSettlements(from: balances)
    }
    
    var body: some View {
        List {
            // Member balances section
            Section("Member Balances") {
                if balances.isEmpty {
                    Text("No expenses yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(sortedBalances, id: \.memberId) { item in
                        if let member = group.members.first(where: { $0.id == item.memberId }) {
                            HStack {
                                AvatarView(name: member.name, colorHex: member.avatarColorHex, size: 32)
                                
                                Text(member.name)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text(CurrencyFormatter.format(cents: item.balance, currencyCode: group.currencyCode))
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(item.balance >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }
            
            // Settlements section
            if !settlements.isEmpty {
                Section("Suggested Settlements") {
                    ForEach(settlements) { settlement in
                        SettlementRowView(settlement: settlement, group: group)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var sortedBalances: [(memberId: UUID, balance: Int)] {
        balances.map { (memberId: $0.key, balance: $0.value) }
            .sorted { abs($0.balance) > abs($1.balance) }
    }
}

// MARK: - Balance Calculator

enum BalanceCalculator {
    /// Calculates net balance for each member (positive = owed, negative = owes)
    static func calculateBalances(for group: SplitGroup) -> [UUID: Int] {
        var balances: [UUID: Int] = [:]
        
        // Initialize all members to 0
        for member in group.members {
            balances[member.id] = 0
        }
        
        // Process each expense
        for expense in group.expenses {
            // Payer gets credited
            balances[expense.payerId, default: 0] += expense.amountCents
            
            // Each split participant gets debited
            for split in expense.splits {
                balances[split.memberId, default: 0] -= split.amountCents
            }
        }
        
        return balances
    }
    
    /// Calculates optimal settlements to balance all debts
    static func calculateSettlements(from balances: [UUID: Int]) -> [Settlement] {
        var creditors: [(id: UUID, amount: Int)] = []
        var debtors: [(id: UUID, amount: Int)] = []
        
        // Separate creditors (owed money) and debtors (owe money)
        for (id, balance) in balances {
            if balance > 0 {
                creditors.append((id, balance))
            } else if balance < 0 {
                debtors.append((id, -balance))
            }
        }
        
        // Sort by amount (largest first for efficiency)
        creditors.sort { $0.amount > $1.amount }
        debtors.sort { $0.amount > $1.amount }
        
        var settlements: [Settlement] = []
        var creditorIndex = 0
        var debtorIndex = 0
        var creditorRemaining = creditors.first?.amount ?? 0
        var debtorRemaining = debtors.first?.amount ?? 0
        
        // Greedy algorithm to minimize number of transactions
        while creditorIndex < creditors.count && debtorIndex < debtors.count {
            let creditor = creditors[creditorIndex]
            let debtor = debtors[debtorIndex]
            
            let settleAmount = min(creditorRemaining, debtorRemaining)
            
            if settleAmount > 0 {
                settlements.append(Settlement(
                    fromMemberId: debtor.id,
                    toMemberId: creditor.id,
                    amountCents: settleAmount
                ))
            }
            
            creditorRemaining -= settleAmount
            debtorRemaining -= settleAmount
            
            if creditorRemaining == 0 {
                creditorIndex += 1
                creditorRemaining = creditorIndex < creditors.count ? creditors[creditorIndex].amount : 0
            }
            
            if debtorRemaining == 0 {
                debtorIndex += 1
                debtorRemaining = debtorIndex < debtors.count ? debtors[debtorIndex].amount : 0
            }
        }
        
        return settlements
    }
}

// MARK: - Settlement Model

struct Settlement: Identifiable {
    let id = UUID()
    let fromMemberId: UUID
    let toMemberId: UUID
    let amountCents: Int
}

#Preview {
    NavigationStack {
        BalancesView(group: PreviewData.sampleGroup)
            .modelContainer(PreviewData.container)
    }
}
