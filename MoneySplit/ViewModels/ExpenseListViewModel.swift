import SwiftUI
import SwiftData

@MainActor
final class ExpenseListViewModel: ObservableObject {
    @Published var selectedCategory: ExpenseCategory? = nil
    @Published var sortNewest = true
    @Published var errorMessage: String? = nil

    let group: SplitGroup
    private let context: ModelContext

    init(group: SplitGroup, context: ModelContext) {
        self.group = group
        self.context = context
    }

    var allExpenses: [Expense] {
        group.expenses.sorted { a, b in
            sortNewest ? a.date > b.date : a.date < b.date
        }
    }

    var filteredExpenses: [Expense] {
        guard let cat = selectedCategory else { return allExpenses }
        return allExpenses.filter { $0.categoryId == cat.rawValue }
    }

    func deleteExpense(_ expense: Expense) {
        group.expenses.removeAll { $0.id == expense.id }
        context.delete(expense)
        save()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }
}
