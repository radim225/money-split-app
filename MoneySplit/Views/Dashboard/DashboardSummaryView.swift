import SwiftUI
import Charts

struct DashboardSummaryView: View {
    let group: SplitGroup
    let vm: GroupDetailViewModel?
    @State private var showCategoryDetail = false

    var body: some View {
        List {
            if group.expenses.isEmpty {
                EmptyStateView(
                    systemImage: "chart.bar",
                    title: "No Data Yet",
                    message: "Add expenses to see your group's spending overview."
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .frame(minHeight: 300)
            } else {
                // Total spent card
                Section {
                    VStack(spacing: 4) {
                        Text("Total Spent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(
                            cents: vm?.totalSpentCents ?? group.totalSpentCents,
                            currencyCode: group.currencyCode
                        ))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.accentColor)

                        HStack(spacing: 16) {
                            Label("\(group.expenses.count) expenses", systemImage: "creditcard")
                            Label("\(group.members.count) members", systemImage: "person.2")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color(hex: group.colorHex).opacity(0.08))

                // Category chart
                if let vm, !vm.categoryTotals.isEmpty {
                    Section {
                        Button {
                            showCategoryDetail = true
                        } label: {
                            CategoryChartView(
                                categoryTotals: vm.categoryTotals,
                                currencyCode: group.currencyCode
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        HStack {
                            Text("By Category")
                            Spacer()
                            Text("See All")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(AppTheme.accentColor)
                                .textCase(nil)
                        }
                    }
                }

                // Member summaries
                if let vm, !vm.memberSummaries.isEmpty {
                    Section("Members") {
                        ForEach(vm.memberSummaries) { summary in
                            NavigationLink(destination: MemberDetailView(
                                member: group.members.first { $0.id == summary.id } ?? group.members[0],
                                group: group
                            )) {
                                HStack(spacing: 12) {
                                    AvatarView(name: summary.name, colorHex: summary.colorHex, size: 36)
                                    Text(summary.name)
                                        .font(.subheadline)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        let net = summary.netCents
                                        if net == 0 {
                                            Text("Even")
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(.secondary)
                                        } else if net > 0 {
                                            Text(CurrencyFormatter.format(cents: net, currencyCode: group.currencyCode))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.green)
                                            Text("gets back")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        } else {
                                            Text(CurrencyFormatter.format(cents: -net, currencyCode: group.currencyCode))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.red)
                                            Text("owes")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }

                // Recent expenses
                if let vm, !vm.recentExpenses.isEmpty {
                    Section {
                        ForEach(vm.recentExpenses) { expense in
                            ExpenseRowView(expense: expense, group: group)
                        }
                    } header: {
                        Text("Recent Expenses")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(isPresented: $showCategoryDetail) {
            CategorySummaryView(group: group, categoryTotals: vm?.categoryTotals ?? [])
        }
    }
}

#Preview {
    NavigationStack {
        DashboardSummaryView(
            group: PreviewData.sampleGroup,
            vm: GroupDetailViewModel(group: PreviewData.sampleGroup)
        )
        .navigationTitle("Barcelona Trip")
    }
    .modelContainer(PreviewData.container)
}
