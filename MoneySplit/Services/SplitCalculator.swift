import Foundation

enum SplitCalculator {

    struct SplitResult {
        /// Maps memberId -> amountCents. Sum always equals totalCents.
        let splits: [UUID: Int]
        /// Remainder cents absorbed by the first member (for transparency).
        let remainderCents: Int
    }

    /// Equal split of totalCents among memberIds.
    /// Remainder goes to the first member in the array to ensure sum == totalCents.
    static func equalSplit(totalCents: Int, memberIds: [UUID]) -> SplitResult {
        guard !memberIds.isEmpty else { return SplitResult(splits: [:], remainderCents: 0) }

        let count = memberIds.count
        let base = totalCents / count
        let remainder = totalCents % count

        var splits: [UUID: Int] = [:]
        for (index, id) in memberIds.enumerated() {
            splits[id] = base + (index == 0 ? remainder : 0)
        }
        return SplitResult(splits: splits, remainderCents: remainder)
    }

    /// Validates manual splits. Returns nil if valid, error string if not.
    static func validateManualSplit(splits: [UUID: Int], totalCents: Int) -> String? {
        let sum = splits.values.reduce(0, +)
        let diff = totalCents - sum
        if diff == 0 { return nil }
        if diff > 0 {
            return "\(CurrencyFormatter.centsToInputString(diff)) still unassigned"
        } else {
            return "\(CurrencyFormatter.centsToInputString(-diff)) over the total"
        }
    }
}
