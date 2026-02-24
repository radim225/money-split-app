import SwiftUI
import SwiftData

@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let schema = Schema([SplitGroup.self, Member.self, Expense.self, ExpenseSplit.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: schema, configurations: [config])
        populate(into: c.mainContext)
        return c
    }()

    static var sampleGroup: SplitGroup {
        let descriptor = FetchDescriptor<SplitGroup>()
        let groups = try? container.mainContext.fetch(descriptor)
        return groups?.first ?? SplitGroup(name: "Preview Group", emoji: "✈️", colorHex: "#6C63FF", currencyCode: "USD")
    }

    static var sampleMembers: [Member] {
        sampleGroup.members
    }

    static var sampleExpenses: [Expense] {
        sampleGroup.expenses
    }

    private static func populate(into ctx: ModelContext) {
        // Group: Barcelona Trip
        let group = SplitGroup(name: "Barcelona Trip", emoji: "✈️", colorHex: "#6C63FF", currencyCode: "EUR")
        ctx.insert(group)

        let alice = Member(name: "Alice", avatarColorHex: "#FF6B6B")
        let bob   = Member(name: "Bob",   avatarColorHex: "#4ECDC4")
        let carol = Member(name: "Carol", avatarColorHex: "#FFCC5C")

        alice.group = group
        bob.group = group
        carol.group = group
        group.members = [alice, bob, carol]
        ctx.insert(alice); ctx.insert(bob); ctx.insert(carol)

        // Expense 1: Hotel — paid by Alice, equal split
        let hotel = Expense(
            title: "Hotel",
            amountCents: 30000,
            categoryId: ExpenseCategory.accommodation.rawValue,
            date: Date().addingTimeInterval(-86400 * 3),
            notes: "4 nights",
            payerId: alice.id
        )
        hotel.group = group
        ctx.insert(hotel)

        let hs1 = ExpenseSplit(memberId: alice.id, amountCents: 10000)
        let hs2 = ExpenseSplit(memberId: bob.id,   amountCents: 10000)
        let hs3 = ExpenseSplit(memberId: carol.id, amountCents: 10000)
        hs1.expense = hotel; hs2.expense = hotel; hs3.expense = hotel
        hotel.splits = [hs1, hs2, hs3]
        ctx.insert(hs1); ctx.insert(hs2); ctx.insert(hs3)

        // Expense 2: Dinner — paid by Bob, equal split
        let dinner = Expense(
            title: "Dinner at La Boqueria",
            amountCents: 9000,
            categoryId: ExpenseCategory.food.rawValue,
            date: Date().addingTimeInterval(-86400 * 2),
            notes: "Great tapas",
            payerId: bob.id
        )
        dinner.group = group
        ctx.insert(dinner)

        let ds1 = ExpenseSplit(memberId: alice.id, amountCents: 3000)
        let ds2 = ExpenseSplit(memberId: bob.id,   amountCents: 3000)
        let ds3 = ExpenseSplit(memberId: carol.id, amountCents: 3000)
        ds1.expense = dinner; ds2.expense = dinner; ds3.expense = dinner
        dinner.splits = [ds1, ds2, ds3]
        ctx.insert(ds1); ctx.insert(ds2); ctx.insert(ds3)

        // Expense 3: Transport — paid by Carol, only Alice and Carol involved
        let taxi = Expense(
            title: "Airport Taxi",
            amountCents: 4000,
            categoryId: ExpenseCategory.transport.rawValue,
            date: Date().addingTimeInterval(-86400),
            notes: "",
            payerId: carol.id
        )
        taxi.group = group
        ctx.insert(taxi)

        let ts1 = ExpenseSplit(memberId: alice.id, amountCents: 2000)
        let ts2 = ExpenseSplit(memberId: carol.id, amountCents: 2000)
        ts1.expense = taxi; ts2.expense = taxi
        taxi.splits = [ts1, ts2]
        ctx.insert(ts1); ctx.insert(ts2)

        group.expenses = [hotel, dinner, taxi]

        // Group 2: Flatmates
        let flat = SplitGroup(name: "Flatmates", emoji: "🏠", colorHex: "#4ECDC4", currencyCode: "USD")
        ctx.insert(flat)
        let dave = Member(name: "Dave", avatarColorHex: "#C3A6FF")
        let eve  = Member(name: "Eve",  avatarColorHex: "#FFA07A")
        dave.group = flat; eve.group = flat
        flat.members = [dave, eve]
        ctx.insert(dave); ctx.insert(eve)

        let groceries = Expense(
            title: "Weekly Groceries",
            amountCents: 8500,
            categoryId: ExpenseCategory.groceries.rawValue,
            date: Date(),
            notes: "",
            payerId: dave.id
        )
        groceries.group = flat
        ctx.insert(groceries)

        let gs1 = ExpenseSplit(memberId: dave.id, amountCents: 4250)
        let gs2 = ExpenseSplit(memberId: eve.id,  amountCents: 4250)
        gs1.expense = groceries; gs2.expense = groceries
        groceries.splits = [gs1, gs2]
        flat.expenses = [groceries]
        ctx.insert(gs1); ctx.insert(gs2)

        try? ctx.save()
    }
}
