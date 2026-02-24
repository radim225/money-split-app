import SwiftUI

enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case food           = "food"
    case drinks         = "drinks"
    case transport      = "transport"
    case accommodation  = "accommodation"
    case groceries      = "groceries"
    case entertainment  = "entertainment"
    case shopping       = "shopping"
    case other          = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .food:          return "Food"
        case .drinks:        return "Drinks"
        case .transport:     return "Transport"
        case .accommodation: return "Accommodation"
        case .groceries:     return "Groceries"
        case .entertainment: return "Entertainment"
        case .shopping:      return "Shopping"
        case .other:         return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .food:          return "fork.knife"
        case .drinks:        return "cup.and.saucer.fill"
        case .transport:     return "car.fill"
        case .accommodation: return "house.fill"
        case .groceries:     return "cart.fill"
        case .entertainment: return "ticket.fill"
        case .shopping:      return "bag.fill"
        case .other:         return "square.grid.2x2.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .food:          return Color(hex: "#FF6B6B")
        case .drinks:        return Color(hex: "#4ECDC4")
        case .transport:     return Color(hex: "#45B7D1")
        case .accommodation: return Color(hex: "#96CEB4")
        case .groceries:     return Color(hex: "#88D8B0")
        case .entertainment: return Color(hex: "#FFCC5C")
        case .shopping:      return Color(hex: "#FF6F69")
        case .other:         return Color(hex: "#A8A8A8")
        }
    }

    static func from(_ rawValue: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: rawValue) ?? .other
    }
}
