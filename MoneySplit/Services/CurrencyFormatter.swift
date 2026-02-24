import Foundation

final class CurrencyFormatter: @unchecked Sendable {
    static let shared = CurrencyFormatter()

    private var cache: [String: NumberFormatter] = [:]
    private let lock = NSLock()

    private init() {}

    private func formatter(for currencyCode: String) -> NumberFormatter {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[currencyCode] { return cached }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        cache[currencyCode] = f
        return f
    }

    static func format(cents: Int, currencyCode: String) -> String {
        let decimal = Decimal(cents) / 100
        return shared.formatter(for: currencyCode)
            .string(from: NSDecimalNumber(decimal: decimal)) ?? "\(currencyCode) 0.00"
    }

    static func formatAbs(cents: Int, currencyCode: String) -> String {
        format(cents: abs(cents), currencyCode: currencyCode)
    }

    /// Parses a user-entered string like "12.50" or "12,50" to Int cents (1250).
    static func parseCents(from string: String) -> Int {
        let normalized = string
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        guard let value = Decimal(string: normalized), value >= 0 else { return 0 }
        let cents = (value * 100) as NSDecimalNumber
        return cents.intValue
    }

    /// Formats cents as a plain decimal string for input fields (e.g. "12.50")
    static func centsToInputString(_ cents: Int) -> String {
        let decimal = Decimal(cents) / 100
        let ns = NSDecimalNumber(decimal: decimal)
        return String(format: "%.2f", ns.doubleValue)
    }
}
