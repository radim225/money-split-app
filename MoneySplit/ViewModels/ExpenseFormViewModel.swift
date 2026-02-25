import SwiftUI
import SwiftData

enum SplitMode: String, CaseIterable {
    case equal  = "Equal"
    case manual = "Manual"
}

@MainActor
final class ExpenseFormViewModel: ObservableObject {

    // MARK: – Form fields
    @Published var title: String = ""
    @Published var amountString: String = ""
    @Published var selectedCategory: ExpenseCategory = .other
    @Published var date: Date = Date()
    @Published var notes: String = ""
    @Published var selectedPayerId: UUID? = nil
    @Published var involvedMemberIds: Set<UUID> = []
    @Published var splitMode: SplitMode = .equal
    @Published var manualSplits: [UUID: String] = [:]

    // MARK: – Currency
    @Published var selectedCurrencyCode: String
    @Published private(set) var isLoadingRate = false
    @Published var rateError: String? = nil
    @Published private(set) var convertedPreviewCents: Int? = nil

    // MARK: – Derived / validation
    @Published private(set) var splitPreview: [UUID: Int] = [:]
    @Published private(set) var manualSplitTotalCents: Int = 0
    @Published private(set) var remainderCents: Int = 0
    @Published private(set) var validationError: String? = nil
    @Published var saveError: String? = nil

    // MARK: – State
    let isEditing: Bool
    let group: SplitGroup
    private let context: ModelContext
    private let existingExpense: Expense?

    /// Raw cents of the typed amount, in the selected (possibly foreign) currency.
    var amountCents: Int {
        CurrencyFormatter.parseCents(from: amountString)
    }

    /// Cents that will actually be stored — in the group's base currency.
    var effectiveAmountCents: Int {
        if selectedCurrencyCode != group.currencyCode {
            return convertedPreviewCents ?? 0
        }
        return amountCents
    }

    var isValid: Bool {
        let currencyReady = selectedCurrencyCode == group.currencyCode || convertedPreviewCents != nil
        return !title.trimmingCharacters(in: .whitespaces).isEmpty
            && amountCents > 0
            && selectedPayerId != nil
            && !involvedMemberIds.isEmpty
            && validationError == nil
            && currencyReady
            && !isLoadingRate
    }

    var involvedMembers: [Member] {
        group.members
            .filter { involvedMemberIds.contains($0.id) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    init(context: ModelContext, group: SplitGroup, expense: Expense? = nil) {
        self.context = context
        self.group = group
        self.existingExpense = expense
        self.isEditing = expense != nil
        self.selectedCurrencyCode = group.currencyCode

        if let expense {
            title = expense.title
            // Show original amount + currency when editing a converted expense
            let origCode = expense.originalCurrencyCode.isEmpty ? group.currencyCode : expense.originalCurrencyCode
            selectedCurrencyCode = origCode
            let origCents = expense.originalAmountCents == 0 ? expense.amountCents : expense.originalAmountCents
            amountString = CurrencyFormatter.centsToInputString(origCents)
            if origCode != group.currencyCode {
                convertedPreviewCents = expense.amountCents
            }
            selectedCategory = expense.category
            date = expense.date
            notes = expense.notes
            selectedPayerId = expense.payerId
            involvedMemberIds = Set(expense.splits.map(\.memberId))
            // Determine split mode
            let equalResult = SplitCalculator.equalSplit(
                totalCents: expense.amountCents,
                memberIds: expense.splits.map(\.memberId)
            )
            let isEqual = expense.splits.allSatisfy { split in
                equalResult.splits[split.memberId] == split.amountCents
            }
            splitMode = isEqual ? .equal : .manual
            if !isEqual {
                for split in expense.splits {
                    manualSplits[split.memberId] = CurrencyFormatter.centsToInputString(split.amountCents)
                }
            }
        } else {
            involvedMemberIds = Set(group.members.map(\.id))
            selectedPayerId = group.members.sorted { $0.createdAt < $1.createdAt }.first?.id
        }
        recalculateSplits()
    }

    // MARK: – Currency conversion

    func fetchConvertedAmount() async {
        let raw = amountCents
        guard raw > 0, selectedCurrencyCode != group.currencyCode else {
            convertedPreviewCents = nil
            rateError = nil
            recalculateSplits()
            return
        }
        isLoadingRate = true
        rateError = nil
        defer { isLoadingRate = false }
        do {
            let rate = try await ExchangeRateService.shared.rate(from: selectedCurrencyCode, to: group.currencyCode)
            convertedPreviewCents = Int((Double(raw) * rate).rounded())
            rateError = nil
        } catch {
            convertedPreviewCents = nil
            rateError = error.localizedDescription
        }
        recalculateSplits()
    }

    // MARK: – Member toggling

    func toggleMember(_ id: UUID) {
        if involvedMemberIds.contains(id) {
            involvedMemberIds.remove(id)
        } else {
            involvedMemberIds.insert(id)
        }
        recalculateSplits()
    }

    func selectAllMembers() {
        involvedMemberIds = Set(group.members.map(\.id))
        recalculateSplits()
    }

    func deselectAllMembers() {
        involvedMemberIds = []
        recalculateSplits()
    }

    // MARK: – Split calculation

    func recalculateSplits() {
        let total = effectiveAmountCents
        let ids = involvedMembers.map(\.id)

        switch splitMode {
        case .equal:
            let result = SplitCalculator.equalSplit(totalCents: total, memberIds: ids)
            splitPreview = result.splits
            remainderCents = result.remainderCents
            validationError = ids.isEmpty ? "Select at least one member" : nil

        case .manual:
            var parsed: [UUID: Int] = [:]
            for id in involvedMemberIds {
                let str = manualSplits[id] ?? ""
                parsed[id] = CurrencyFormatter.parseCents(from: str)
            }
            splitPreview = parsed
            manualSplitTotalCents = parsed.values.reduce(0, +)
            remainderCents = total - manualSplitTotalCents
            validationError = SplitCalculator.validateManualSplit(splits: parsed, totalCents: total)
        }
    }

    // MARK: – Save

    func save() {
        guard isValid else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let ids = involvedMembers.map(\.id)
        let storedCents = effectiveAmountCents
        let origCode = selectedCurrencyCode
        let origCents = amountCents

        if let expense = existingExpense {
            expense.title = trimmedTitle
            expense.amountCents = storedCents
            expense.originalCurrencyCode = origCode
            expense.originalAmountCents = origCents
            expense.categoryId = selectedCategory.rawValue
            expense.date = date
            expense.notes = notes
            expense.payerId = selectedPayerId!

            for split in expense.splits { context.delete(split) }
            expense.splits = buildSplits(ids: ids, expense: expense)
        } else {
            let expense = Expense(
                title: trimmedTitle,
                amountCents: storedCents,
                originalCurrencyCode: origCode,
                originalAmountCents: origCents,
                categoryId: selectedCategory.rawValue,
                date: date,
                notes: notes,
                payerId: selectedPayerId!
            )
            expense.group = group
            context.insert(expense)
            expense.splits = buildSplits(ids: ids, expense: expense)
            group.expenses.append(expense)
        }

        do {
            try context.save()
        } catch {
            saveError = "Failed to save expense: \(error.localizedDescription)"
        }
    }

    private func buildSplits(ids: [UUID], expense: Expense) -> [ExpenseSplit] {
        ids.compactMap { id in
            guard let cents = splitPreview[id] else { return nil }
            let split = ExpenseSplit(memberId: id, amountCents: cents)
            split.expense = expense
            context.insert(split)
            return split
        }
    }
}
