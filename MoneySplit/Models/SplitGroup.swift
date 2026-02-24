import SwiftData
import Foundation

@Model
final class SplitGroup {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    var currencyCode: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Member.group)
    var members: [Member]

    @Relationship(deleteRule: .cascade, inverse: \Expense.group)
    var expenses: [Expense]

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = AppConstants.defaultEmoji,
        colorHex: String = AppConstants.defaultGroupColor,
        currencyCode: String = AppConstants.defaultCurrencyCode,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.currencyCode = currencyCode
        self.createdAt = createdAt
        self.members = []
        self.expenses = []
    }

    var totalSpentCents: Int {
        expenses.reduce(0) { $0 + $1.amountCents }
    }

    var lastActivity: Date? {
        expenses.map(\.date).max()
    }
}
