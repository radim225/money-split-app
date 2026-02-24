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

    var amountCents: Int {
        CurrencyFormatter.parseCents(from: amountString)
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && amountCents > 0
            && selectedPayerId != nil
            && !involvedMemberIds.isEmpty
            && validationError == nil
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

        if let expense {
            title = expense.title
            amountString = CurrencyFormatter.centsToInputString(expense.amountCents)
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
            // Default: select all members as involved
            involvedMemberIds = Set(group.members.map(\.id))
            // Default payer = first member
            selectedPayerId = group.members.sorted { $0.createdAt < $1.createdAt }.first?.id
        }
        recalculateSplits()
    }

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

    func recalculateSplits() {
        let total = amountCents
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

    func save() {
        guard isValid else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let ids = involvedMembers.map(\.id)

        if let expense = existingExpense {
            // Update existing
            expense.title = trimmedTitle
            expense.amountCents = amountCents
            expense.categoryId = selectedCategory.rawValue
            expense.date = date
            expense.notes = notes
            expense.payerId = selectedPayerId!

            // Replace all splits
            for split in expense.splits {
                context.delete(split)
            }
            expense.splits = buildSplits(ids: ids, expense: expense)
        } else {
            // Create new
            let expense = Expense(
                title: trimmedTitle,
                amountCents: amountCents,
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
