import SwiftUI
import SwiftData

@MainActor
final class MembersViewModel: ObservableObject {
    @Published var newMemberName: String = ""
    @Published var newMemberColorHex: String = AppTheme.avatarColors[0]
    @Published var showAddSheet = false
    @Published var errorMessage: String? = nil

    let group: SplitGroup
    private let context: ModelContext

    var members: [Member] { group.members.sorted { $0.createdAt < $1.createdAt } }

    init(group: SplitGroup, context: ModelContext) {
        self.group = group
        self.context = context
        // Pick a fresh color for next member
        let usedColors = Set(group.members.map(\.avatarColorHex))
        newMemberColorHex = AppTheme.avatarColors.first { !usedColors.contains($0) } ?? AppTheme.avatarColors[0]
    }

    var isNewMemberValid: Bool {
        !newMemberName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let member = Member(name: trimmed, avatarColorHex: newMemberColorHex)
        member.group = group
        group.members.append(member)
        context.insert(member)
        save()

        newMemberName = ""
        // Auto-advance color
        let usedColors = Set(group.members.map(\.avatarColorHex))
        newMemberColorHex = AppTheme.avatarColors.first { !usedColors.contains($0) } ?? AppTheme.avatarColors[0]
        showAddSheet = false
    }

    func updateMember(_ member: Member, name: String, colorHex: String) {
        member.name = name.trimmingCharacters(in: .whitespaces)
        member.avatarColorHex = colorHex
        save()
    }

    func deleteMember(_ member: Member) {
        group.members.removeAll { $0.id == member.id }
        context.delete(member)
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
