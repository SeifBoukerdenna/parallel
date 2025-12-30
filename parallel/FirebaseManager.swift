import SwiftUI
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class FirebaseManager: NSObject, ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var fcmToken: String?
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    private var currentUserName: String?
    
    // Listeners for real-time updates
    private var momentsListener: ListenerRegistration?
    private var signalsListener: ListenerRegistration?
    private var pingsListener: ListenerRegistration?
    
    override private init() {
        super.init()
    }
    
    // MARK: - Setup (called after Firebase is already configured)
    func setup() {
        print("🔥 Setting up FirebaseManager")
        
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
        
        // Set up messaging delegate
        Messaging.messaging().delegate = self
        
        print("✅ FirebaseManager setup complete")
    }
    
    // MARK: - Authentication
    func authenticateUser(userName: String) async throws {
        self.currentUserName = userName
        
        do {
            // Sign in anonymously (we'll use display name for the username)
            let result = try await Auth.auth().signInAnonymously()
            print("✅ Authenticated as: \(result.user.uid)")
            
            // Update display name to use in security rules
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = userName
            try await changeRequest.commitChanges()
            
            retryTokenRegistration()
            
            isAuthenticated = true
            
            // Request notification permissions and get FCM token
            await requestNotificationPermission()
            
            print("✅ User authenticated: \(userName)")
        } catch {
            print("❌ Authentication error: \(error)")
            throw error
        }
    }
    
    // MARK: - Notification Permissions
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                print("✅ Notification permission granted")
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Notification permission denied")
            }
        } catch {
            print("❌ Error requesting notification permission: \(error)")
        }
    }
    
    // MARK: - FCM Token Management
    func registerFCMToken(_ token: String) {
        guard let userName = currentUserName else {
            print("⚠️ No user name set, skipping token registration")
            return
        }
        
        self.fcmToken = token
        print("📱 FCM Token: \(token)")
        
        // Save token to Firestore
        let tokenData: [String: Any] = [
            "userName": userName,
            "token": token,
            "updatedAt": FieldValue.serverTimestamp(),
            "platform": "ios"
        ]
        
        // Use userName as document ID for easy lookup
        db.collection("fcmTokens").document(userName).setData(tokenData, merge: true) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error)")
            } else {
                print("✅ FCM token saved to Firestore")
            }
        }
    }
    
    // MARK: - Sync Data to Firestore
    
    func syncMoment(_ moment: Moment) {
        let momentData: [String: Any] = [
            "id": moment.id.uuidString,
            "createdAt": Timestamp(date: moment.createdAt),
            "author": moment.author,
            "kind": moment.kind.rawValue,
            "title": moment.title ?? "",
            "text": moment.text ?? "",
            "audioPath": moment.audioPath ?? "",
            "photoPath": moment.photoPath ?? "",
            "isShared": moment.isShared
        ]
        
        db.collection("moments").document(moment.id.uuidString).setData(momentData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing moment: \(error)")
            } else {
                print("✅ Moment synced to Firestore")
            }
        }
    }
    
    func syncSignal(_ signal: Signal) {
        let signalData: [String: Any] = [
            "id": signal.id.uuidString,
            "createdAt": Timestamp(date: signal.createdAt),
            "author": signal.author,
            "energy": signal.energy,
            "mood": signal.mood,
            "closeness": signal.closeness,
            "isShared": signal.isShared
        ]
        
        db.collection("signals").document(signal.id.uuidString).setData(signalData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing signal: \(error)")
            } else {
                print("✅ Signal synced to Firestore")
            }
        }
    }
    
    func syncPing(_ ping: Ping) {
        let pingData: [String: Any] = [
            "id": ping.id.uuidString,
            "createdAt": Timestamp(date: ping.createdAt),
            "author": ping.author,
            "message": ping.message,
            "isRead": ping.isRead
        ]
        
        db.collection("pings").document(ping.id.uuidString).setData(pingData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing ping: \(error)")
            } else {
                print("✅ Ping synced to Firestore")
            }
        }
    }
    
    func syncBucketItem(_ item: BucketItem) {
        let itemData: [String: Any] = [
            "id": item.id.uuidString,
            "createdAt": Timestamp(date: item.createdAt),
            "title": item.title,
            "description": item.description_bucket ?? "",
            "isCompleted": item.isCompleted,
            "completedAt": item.completedAt.map { Timestamp(date: $0) } ?? NSNull(),
            "addedBy": item.addedBy,
            "category": item.category.rawValue,
            "priority": item.priority
        ]
        
        db.collection("bucketItems").document(item.id.uuidString).setData(itemData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing bucket item: \(error)")
            } else {
                print("✅ Bucket item synced to Firestore")
            }
        }
    }
    
    func syncUserSettings(_ settings: UserSettings) {
        let settingsData: [String: Any] = [
            "id": settings.id.uuidString,
            "userName": settings.userName,
            "nickname": settings.nickname ?? "",
            "currentPoseIndex": settings.currentPoseIndex,
            "updatedAt": Timestamp(date: settings.updatedAt)
        ]
        
        db.collection("userSettings").document(settings.userName).setData(settingsData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing user settings: \(error)")
            } else {
                print("✅ User settings synced to Firestore")
            }
        }
    }
    
    // MARK: - Real-time Listeners
    
    func startListening(onUpdate: @escaping () -> Void) {
        guard isAuthenticated else {
            print("⚠️ Not authenticated, skipping listeners")
            return
        }
        
        // Listen for new moments
        momentsListener = db.collection("moments")
            .whereField("isShared", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening to moments: \(error)")
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added || change.type == .modified {
                        print("📸 Moment updated in Firestore")
                        onUpdate()
                    }
                }
            }
        
        // Listen for new signals
        signalsListener = db.collection("signals")
            .whereField("isShared", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening to signals: \(error)")
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added || change.type == .modified {
                        print("📡 Signal updated in Firestore")
                        onUpdate()
                    }
                }
            }
        
        // Listen for new pings
        pingsListener = db.collection("pings")
            .whereField("isRead", isEqualTo: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error listening to pings: \(error)")
                    return
                }
                
                snapshot?.documentChanges.forEach { change in
                    if change.type == .added {
                        print("💬 New ping in Firestore")
                        onUpdate()
                    }
                }
            }
        
        print("✅ Real-time listeners started")
    }
    
    func stopListening() {
        momentsListener?.remove()
        signalsListener?.remove()
        pingsListener?.remove()
        print("🛑 Real-time listeners stopped")
    }
    
    private func retryTokenRegistration() {
        guard let token = fcmToken, let userName = currentUserName else { return }
        
        DispatchQueue.main.async {
            self.registerFCMToken(token)  // ✅ Change this line
        }
    }
}

// MARK: - MessagingDelegate
extension FirebaseManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("📱 FCM Token received: \(token)")
        registerFCMToken(token)
    }
}
