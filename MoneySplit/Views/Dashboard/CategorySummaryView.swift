import SwiftUI
import Charts

struct CategorySummaryView: View {
    let group: SplitGroup
    let categoryTotals: [GroupDetailViewModel.CategoryTotal]

    var body: some View {
        List {
            if categoryTotals.isEmpty {
                EmptyStateView(
                    systemImage: "chart.pie",
                    title: "No Data",
                    message: "Add expenses to see category breakdown."
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .frame(minHeight: 300)
            } else {
                Section {
                    Chart(categoryTotals) { item in
                        BarMark(
                            x: .value("Amount", item.amountCents),
                            y: .value("Category", item.category.displayName)
                        )
                        .foregroundStyle(item.category.accentColor)
                        .cornerRadius(6)
                        .annotation(position: .trailing) {
                            Text(CurrencyFormatter.format(cents: item.amountCents, currencyCode: group.currencyCode))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: CGFloat(categoryTotals.count) * 44 + 40)
                    .chartXAxis(.hidden)
                    .padding(.vertical, 8)
                }

                Section("Details") {
                    ForEach(categoryTotals) { item in
                        HStack(spacing: 12) {
                            CategoryBadge(category: item.category, style: .icon)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.category.displayName)
                                    .font(.subheadline.weight(.medium))
                                Text(String(format: "%.1f%% of total", item.fraction * 100))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(CurrencyFormatter.format(cents: item.amountCents, currencyCode: group.currencyCode))
                                .font(.subheadline.weight(.semibold))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CategorySummaryView(
            group: PreviewData.sampleGroup,
            categoryTotals: GroupDetailViewModel(group: PreviewData.sampleGroup).categoryTotals
        )
    }
    .modelContainer(PreviewData.container)
}
