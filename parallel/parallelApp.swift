import SwiftUI
import SwiftData

@main
struct parallelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Moment.self,
            Signal.self,
            BucketItem.self,
            UserSettings.self,
            Ping.self,
            DeviceToken.self,  // ✅ ADDED - Critical for push notifications!
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic  // ✅ This syncs everything via CloudKit
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
