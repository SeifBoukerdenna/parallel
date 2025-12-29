import SwiftUI
import UserNotifications
import SwiftData

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var deviceToken: String?
    @Published var notificationPermissionGranted = false
    
    // Store modelContext reference for token registration
    var modelContext: ModelContext?
    var currentUserName: String?
    
    override private init() {
        super.init()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
                if granted {
                    print("✅ Notification permission granted")
                    // Register for remote notifications on the main thread
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("❌ Notification permission denied")
                }
                
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                }
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        // Check current authorization status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // Request permission
                    self.requestPermission()
                case .authorized, .provisional:
                    // Already authorized, register for remote notifications
                    print("✅ Already authorized for notifications")
                    self.notificationPermissionGranted = true
                    UIApplication.shared.registerForRemoteNotifications()
                case .denied:
                    print("❌ Notifications are denied - user needs to enable in Settings")
                    self.notificationPermissionGranted = false
                @unknown default:
                    break
                }
            }
        }
    }
    
    func setDeviceToken(_ token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = tokenString
        print("📱 Device Token: \(tokenString)")
        print("✅ Copy this token to test notifications from Apple Push Notifications dashboard!")
        
        // Register with NotificationHelper using CloudKit
        if let userName = currentUserName, let modelContext = modelContext {
            NotificationHelper.shared.registerDeviceToken(
                tokenString,
                forUser: userName,
                modelContext: modelContext
            )
        }
    }
    
    func configure(userName: String, modelContext: ModelContext) {
        self.currentUserName = userName
        self.modelContext = modelContext
        print("✅ NotificationManager configured for user: \(userName)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Notification received while app is open")
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("👆 User tapped notification")
        completionHandler()
    }
}
