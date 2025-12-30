import SwiftUI
import SwiftData
import FirebaseCore

@main
struct parallelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    // ✅ CRITICAL: Initialize Firebase in App init
    init() {
        FirebaseApp.configure()
        print("✅ Firebase configured in App init")
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Moment.self,
            Signal.self,
            BucketItem.self,
            UserSettings.self,
            Ping.self,
            // ❌ REMOVED DeviceToken - not needed with Firebase!
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
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
                .environmentObject(firebaseManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
