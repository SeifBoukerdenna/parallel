import SwiftUI
import SwiftData

@main
struct parallelApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Moment.self,
            Signal.self,
            BucketItem.self,  // FIXED: Added BucketItem to schema!
            UserSettings.self,  // For syncing nicknames and poses
        ])
        
        // Enable CloudKit syncing for real-time updates between devices
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic  // Enable iCloud sync
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
