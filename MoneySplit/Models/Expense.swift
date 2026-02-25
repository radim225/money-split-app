import SwiftData
import Foundation

@Model
final class Expense {
    var id: UUID
    var title: String
    /// Amount in the group's base currency — always used for balance calculations.
    var amountCents: Int
    /// The currency the user originally typed the amount in (e.g. "USD").
    /// Equals the group's currencyCode when no conversion was done.
    var originalCurrencyCode: String
    /// The amount in the original currency before conversion (in cents).
    /// Equals amountCents when originalCurrencyCode == group.currencyCode.
    var originalAmountCents: Int
    var categoryId: String
    var date: Date
    var notes: String
    var payerId: UUID
    var createdAt: Date

    var group: SplitGroup?

    @Relationship(deleteRule: .cascade, inverse: \ExpenseSplit.expense)
    var splits: [ExpenseSplit]

    init(
        id: UUID = UUID(),
        title: String,
        amountCents: Int,
        originalCurrencyCode: String = "",
        originalAmountCents: Int = 0,
        categoryId: String,
        date: Date = Date(),
        notes: String = "",
        payerId: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amountCents = amountCents
        self.originalCurrencyCode = originalCurrencyCode
        self.originalAmountCents = originalAmountCents
        self.categoryId = categoryId
        self.date = date
        self.notes = notes
        self.payerId = payerId
        self.createdAt = createdAt
        self.splits = []
    }

    var category: ExpenseCategory {
        ExpenseCategory.from(categoryId)
    }

    func payer(in members: [Member]) -> Member? {
        members.first { $0.id == payerId }
    }
}
