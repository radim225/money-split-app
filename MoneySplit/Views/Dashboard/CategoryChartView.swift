import SwiftUI
import Charts

struct CategoryChartView: View {
    let categoryTotals: [GroupDetailViewModel.CategoryTotal]
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Chart(categoryTotals) { item in
                SectorMark(
                    angle: .value("Amount", item.amountCents),
                    innerRadius: .ratio(0.55),
                    angularInset: 2.0
                )
                .foregroundStyle(item.category.accentColor)
                .cornerRadius(4)
                .annotation(position: .overlay) {
                    if item.fraction > 0.08 {
                        Text(String(format: "%.0f%%", item.fraction * 100))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 180)
            .chartLegend(.hidden)

            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(categoryTotals) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.category.accentColor)
                            .frame(width: 10, height: 10)
                        Text(item.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(CurrencyFormatter.format(cents: item.amountCents, currencyCode: currencyCode))
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let vm = GroupDetailViewModel(group: PreviewData.sampleGroup)
    return CategoryChartView(categoryTotals: vm.categoryTotals, currencyCode: "EUR")
        .padding()
        .modelContainer(PreviewData.container)
}
