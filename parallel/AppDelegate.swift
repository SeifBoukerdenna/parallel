import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("🚀 AppDelegate: didFinishLaunchingWithOptions")
        
        // ✅ Setup Firebase Manager
        print("🔥 Setting up FirebaseManager")
        FirebaseManager.shared.setup()
        print("✅ FirebaseManager setup complete")
        
        // ✅ Setup notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            } else {
                print("❌ Notification permission denied")
            }
            
            if let error = error {
                print("❌ Notification permission error: \(error)")
            }
        }
        
        print("✅ AppDelegate configured")
        
        return true
    }
    
    // ✅ Called when APNs successfully registers the device
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ APNs device token received")
        
        // Convert to hex string for logging
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("📱 APNs Token (hex): \(tokenString)")
        
        // ✅ CRITICAL: Give token to Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs token set in Firebase Messaging")
    }
    
    // ❌ Called when registration fails
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // 🔔 Handle remote notification when app is running
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("🔔 Received remote notification")
        print("📦 Notification data: \(userInfo)")
        
        // Let Firebase Messaging handle it
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler(.newData)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Handle notification when app is in FOREGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("🔔 Notification received while app is in FOREGROUND")
        print("📦 Notification: \(notification.request.content.userInfo)")
        
        // ✅ SHOW BANNER EVEN WHEN APP IS OPEN
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("👆 User tapped notification")
        print("📦 Notification data: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
}
