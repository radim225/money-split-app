import SwiftUI

struct GroupRowView: View {
    let group: SplitGroup
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji icon
            Text(group.emoji)
                .font(.system(size: 40))
                .frame(width: 56, height: 56)
                .background(Color(hex: group.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    // Members count
                    Label("\(group.members.count) member\(group.members.count == 1 ? "" : "s")", 
                          systemImage: "person.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Expenses count
                    Label("\(group.expenses.count) expense\(group.expenses.count == 1 ? "" : "s")", 
                          systemImage: "receipt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Total spent
            if group.totalSpentCents > 0 {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.format(cents: group.totalSpentCents, currencyCode: group.currencyCode))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: group.colorHex))
                    
                    if let lastActivity = group.lastActivity {
                        Text(lastActivity, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        GroupRowView(group: PreviewData.sampleGroup)
        GroupRowView(group: PreviewData.sampleGroup)
    }
    .listStyle(.insetGrouped)
}
