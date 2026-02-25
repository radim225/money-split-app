import SwiftUI
import SwiftData

struct GroupDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let group: SplitGroup
    
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @State private var showGroupSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("View", selection: $selectedTab) {
                Text("Expenses").tag(0)
                Text("Members").tag(1)
                Text("Balances").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content based on selected tab
            TabView(selection: $selectedTab) {
                ExpenseListView(group: group)
                    .tag(0)
                
                MembersView(group: group)
                    .tag(1)
                
                BalancesView(group: group)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showAddExpense = true
                    } label: {
                        Label("Add Expense", systemImage: "plus.circle")
                    }
                    
                    Button {
                        showGroupSettings = true
                    } label: {
                        Label("Group Settings", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            ExpenseFormView(group: group)
        }
        .sheet(isPresented: $showGroupSettings) {
            GroupFormView(group: group)
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(group: PreviewData.sampleGroup)
            .modelContainer(PreviewData.container)
    }
}
