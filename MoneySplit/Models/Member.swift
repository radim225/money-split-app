import SwiftData
import Foundation

@Model
final class Member {
    var id: UUID
    var name: String
    var avatarColorHex: String
    var createdAt: Date

    var group: SplitGroup?

    init(
        id: UUID = UUID(),
        name: String,
        avatarColorHex: String = AppTheme.avatarColors[0],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.avatarColorHex = avatarColorHex
        self.createdAt = createdAt
    }

    var initials: String {
        name.components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }
}
