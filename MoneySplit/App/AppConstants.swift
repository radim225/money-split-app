import Foundation

enum AppConstants {
    static let appName = "Money Split"
    static let defaultCurrencyCode = "USD"
    static let defaultEmoji = "💰"
    static let defaultGroupColor = "#6C63FF"

    enum Limits {
        static let maxGroupNameLength = 50
        static let maxMemberNameLength = 40
        static let maxExpenseTitleLength = 100
        static let maxNotesLength = 500
    }

    /// Currencies supported by Frankfurter.app (ECB rates, ~32 currencies).
    static let supportedCurrencies: [String] = [
        "AUD", "BGN", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK",
        "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "ISK",
        "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PLN",
        "RON", "SEK", "SGD", "THB", "TRY", "USD", "ZAR"
    ]
}
