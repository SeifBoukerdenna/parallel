import SwiftUI
import SwiftData

// Add this extension to make Firebase syncing automatic
extension View {
    func syncToFirebase() -> some View {
        self.modifier(FirebaseSyncModifier())
    }
}

struct FirebaseSyncModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onChange(of: FirebaseManager.shared.isAuthenticated) { _, isAuth in
                if isAuth {
                    print("✅ Firebase authenticated, syncing enabled")
                }
            }
    }
}

// Helper functions to sync after SwiftData insert
extension ModelContext {
    func insertAndSync<T>(_ object: T, syncHandler: (T) -> Void) where T: PersistentModel {
        self.insert(object)
        
        // ✅ FIX: Wrap async calls in Task
        // Sync to Firebase based on type
        if let moment = object as? Moment {
            Task {
                await FirebaseManager.shared.syncMoment(moment)
            }
        } else if let signal = object as? Signal {
            FirebaseManager.shared.syncSignal(signal)
        } else if let ping = object as? Ping {
            FirebaseManager.shared.syncPing(ping)
        } else if let item = object as? BucketItem {
            FirebaseManager.shared.syncBucketItem(item)
        } else if let settings = object as? UserSettings {
            FirebaseManager.shared.syncUserSettings(settings)
        }
    }
}
