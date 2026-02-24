import SwiftData
import Foundation

@Model
final class Expense {
    var id: UUID
    var title: String
    var amountCents: Int
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
        categoryId: String,
        date: Date = Date(),
        notes: String = "",
        payerId: UUID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.amountCents = amountCents
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
