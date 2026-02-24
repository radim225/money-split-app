import SwiftUI
import SwiftData

struct GroupListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SplitGroup.createdAt, order: .reverse) private var groups: [SplitGroup]
    @State private var showCreateGroup = false
    @State private var groupToEdit: SplitGroup? = nil

    var body: some View {
        NavigationStack {
            Group {
                if groups.isEmpty {
                    EmptyStateView(
                        systemImage: "person.3",
                        title: "No Groups Yet",
                        message: "Create a group to start splitting expenses with friends.",
                        actionTitle: "Create Group",
                        action: { showCreateGroup = true }
                    )
                } else {
                    List {
                        ForEach(groups) { group in
                            NavigationLink(destination: GroupDetailView(group: group)) {
                                GroupRowView(group: group)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    modelContext.delete(group)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    groupToEdit = group
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Money Split")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                GroupFormView()
            }
            .sheet(item: $groupToEdit) { group in
                GroupFormView(group: group)
            }
        }
    }
}

#Preview {
    GroupListView()
        .modelContainer(PreviewData.container)
}
