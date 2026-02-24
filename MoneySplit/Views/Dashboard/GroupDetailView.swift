import SwiftUI

struct GroupDetailView: View {
    let group: SplitGroup
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @StateObject private var vm: GroupDetailViewModel

    init(group: SplitGroup) {
        self.group = group
        _vm = StateObject(wrappedValue: GroupDetailViewModel(group: group))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Overview", systemImage: "house.fill", value: 0) {
                DashboardSummaryView(group: group, vm: vm)
            }
            Tab("Expenses", systemImage: "list.bullet", value: 1) {
                ExpenseListView(group: group)
            }
            Tab("Balances", systemImage: "arrow.left.arrow.right", value: 2) {
                BalancesView(group: group)
            }
            Tab("Members", systemImage: "person.2.fill", value: 3) {
                MembersView(group: group)
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if selectedTab != 3 {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            ExpenseFormView(group: group)
        }
        .onChange(of: selectedTab) {
            vm.reload()
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: PreviewData.sampleGroup)
    }
    .modelContainer(PreviewData.container)
}
