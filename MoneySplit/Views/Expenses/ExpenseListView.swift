import SwiftUI
import SwiftData

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    let group: SplitGroup

    var body: some View {
        ExpenseListContent(context: modelContext, group: group)
    }
}

private struct ExpenseListContent: View {
    @StateObject private var vm: ExpenseListViewModel
    let group: SplitGroup
    @State private var showAdd = false
    @State private var expenseToEdit: Expense? = nil

    init(context: ModelContext, group: SplitGroup) {
        self.group = group
        _vm = StateObject(wrappedValue: ExpenseListViewModel(group: group, context: context))
    }

    var body: some View {
        List {
            // Category filter chips
            if !group.expenses.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(nil, label: "All")
                        ForEach(ExpenseCategory.allCases) { cat in
                            if group.expenses.contains(where: { $0.categoryId == cat.rawValue }) {
                                filterChip(cat, label: cat.displayName)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if vm.filteredExpenses.isEmpty {
                EmptyStateView(
                    systemImage: "creditcard",
                    title: vm.selectedCategory == nil ? "No Expenses" : "No \(vm.selectedCategory!.displayName) Expenses",
                    message: vm.selectedCategory == nil
                        ? "Add your first expense to start tracking."
                        : "No expenses in this category yet.",
                    actionTitle: vm.selectedCategory == nil ? "Add Expense" : nil,
                    action: { showAdd = true }
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .frame(minHeight: 300)
            } else {
                ForEach(vm.filteredExpenses) { expense in
                    ExpenseRowView(expense: expense, group: group)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.deleteExpense(expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                expenseToEdit = expense
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        vm.sortNewest.toggle()
                    } label: {
                        Image(systemName: vm.sortNewest ? "arrow.down.circle" : "arrow.up.circle")
                    }
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            ExpenseFormView(group: group)
        }
        .sheet(item: $expenseToEdit) { expense in
            ExpenseFormView(group: group, expense: expense)
        }
    }

    @ViewBuilder
    private func filterChip(_ cat: ExpenseCategory?, label: String) -> some View {
        let isSelected = vm.selectedCategory == cat
        Button {
            vm.selectedCategory = cat
        } label: {
            HStack(spacing: 4) {
                if let cat {
                    Image(systemName: cat.systemImage)
                        .font(.caption.weight(.medium))
                }
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? AppTheme.accentColor : Color(.systemGray5),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseListView(group: PreviewData.sampleGroup)
            .navigationTitle("Expenses")
    }
    .modelContainer(PreviewData.container)
}
