import SwiftUI
import SwiftData

@MainActor
final class GroupFormViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var emoji: String = AppConstants.defaultEmoji
    @Published var colorHex: String = AppConstants.defaultGroupColor
    @Published var currencyCode: String = AppConstants.defaultCurrencyCode
    @Published var errorMessage: String? = nil

    let isEditing: Bool
    private let context: ModelContext
    private let existingGroup: SplitGroup?

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static let emojiPresets = AppTheme.groupEmojis

    static let colorPresets = AppTheme.groupColors

    static let currencyCodes = [
        "USD", "EUR", "GBP", "CZK", "CAD", "AUD", "JPY", "CHF",
        "PLN", "HUF", "NOK", "SEK", "DKK", "SGD", "HKD"
    ]

    init(context: ModelContext, group: SplitGroup? = nil) {
        self.context = context
        self.existingGroup = group
        self.isEditing = group != nil
        if let group {
            self.name = group.name
            self.emoji = group.emoji
            self.colorHex = group.colorHex
            self.currencyCode = group.currencyCode
        }
    }

    func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let group = existingGroup {
            group.name = trimmedName
            group.emoji = emoji
            group.colorHex = colorHex
            group.currencyCode = currencyCode
        } else {
            let group = SplitGroup(
                name: trimmedName,
                emoji: emoji,
                colorHex: colorHex,
                currencyCode: currencyCode
            )
            context.insert(group)
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save group: \(error.localizedDescription)"
        }
    }
}
