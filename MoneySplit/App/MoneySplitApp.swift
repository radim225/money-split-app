import SwiftUI
import SwiftData

@main
struct MoneySplitApp: App {
    let container: ModelContainer = {
        let schema = Schema([
            SplitGroup.self,
            Member.self,
            Expense.self,
            ExpenseSplit.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            GroupListView()
                .modelContainer(container)
        }
    }
}
