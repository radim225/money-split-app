import SwiftData
import Foundation

@Model
final class ExpenseSplit {
    var id: UUID
    var memberId: UUID
    var amountCents: Int

    var expense: Expense?

    init(
        id: UUID = UUID(),
        memberId: UUID,
        amountCents: Int
    ) {
        self.id = id
        self.memberId = memberId
        self.amountCents = amountCents
    }
}
