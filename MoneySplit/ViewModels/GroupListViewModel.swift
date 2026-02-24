import SwiftUI
import SwiftData

@MainActor
final class GroupListViewModel: ObservableObject {
    @Published var showCreateGroup = false
    @Published var groupToEdit: SplitGroup? = nil
    @Published var errorMessage: String? = nil

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func deleteGroups(_ groups: [SplitGroup]) {
        for group in groups {
            context.delete(group)
        }
        save()
    }

    private func save() {
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}
