import SwiftUI
import SwiftData
import CloudKit

class NotificationHelper {
    static let shared = NotificationHelper()
    
    private init() {}
    
    // MARK: - Register Device Token
    func registerDeviceToken(_ tokenString: String, forUser userName: String, modelContext: ModelContext) {
        Task {
            do {
                let container = CKContainer(identifier: "iCloud.com.elmelz.parallel")
                let database = container.privateCloudDatabase
                
                // Query for existing UserSettings record
                let predicate = NSPredicate(format: "userName == %@", userName)
                let query = CKQuery(recordType: "UserSettings", predicate: predicate)
                
                let (results, _) = try await database.records(matching: query)
                
                if let firstResult = results.first {
                    // Update existing record
                    var record = try firstResult.1.get()
                    record["deviceToken"] = tokenString as CKRecordValue
                    
                    try await database.save(record)
                    print("✅ Updated device token for \(userName): \(tokenString)")
                } else {
                    // Create new record (shouldn't happen, but just in case)
                    let recordID = CKRecord.ID(recordName: UUID().uuidString)
                    let record = CKRecord(recordType: "UserSettings", recordID: recordID)
                    record["userName"] = userName as CKRecordValue
                    record["deviceToken"] = tokenString as CKRecordValue
                    
                    try await database.save(record)
                    print("✅ Created new UserSettings with device token for \(userName)")
                }
            } catch {
                print("❌ Error saving device token: \(error)")
            }
        }
    }
    
    // MARK: - Shared Moment Notification
    func notifySharedMoment(fromUser: String, toUser: String, momentType: MomentKind, title: String?, modelContext: ModelContext) {
        Task {
            // Get recipient's device token from CloudKit
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("⚠️ No device token found for \(toUser)")
                return
            }
            
            // Create notification message based on moment type
            let notificationTitle: String
            let notificationBody: String
            
            switch momentType {
            case .text:
                notificationTitle = "💭 \(fromUser) shared a moment"
                notificationBody = title ?? "New text moment"
            case .photo:
                notificationTitle = "📸 \(fromUser) shared a photo"
                notificationBody = title ?? "Check out this moment"
            case .voice:
                notificationTitle = "🎤 \(fromUser) shared a voice note"
                notificationBody = title ?? "Listen to this moment"
            }
            
            // Send the notification
            await sendNotification(
                to: recipientToken,
                title: notificationTitle,
                body: notificationBody,
                soundName: "parallel_notification.caf"
            )
        }
    }
    
    // MARK: - Shared Signal Notification
    func notifySharedSignal(fromUser: String, toUser: String, energy: Double, mood: Double, closeness: Double, modelContext: ModelContext) {
        Task {
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("⚠️ No device token found for \(toUser)")
                return
            }
            
            // Create a friendly message based on their mood
            let moodEmoji: String
            if mood > 20 {
                moodEmoji = "😄"
            } else if mood > 0 {
                moodEmoji = "😊"
            } else if mood > -20 {
                moodEmoji = "😐"
            } else {
                moodEmoji = "💙"
            }
            
            await sendNotification(
                to: recipientToken,
                title: "\(moodEmoji) \(fromUser) shared their signal",
                body: "See how they're feeling right now",
                soundName: "parallel_notification.caf"
            )
        }
    }
    
    // MARK: - Ping Notification
    func notifyPing(fromUser: String, toUser: String, message: String, modelContext: ModelContext) {
        Task {
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("⚠️ No device token found for \(toUser)")
                return
            }
            
            await sendNotification(
                to: recipientToken,
                title: "💬 \(fromUser) sent a ping!",
                body: message,
                soundName: "parallel_notification.caf"
            )
        }
    }
    
    // MARK: - Get Device Token from CloudKit
    private func getDeviceToken(for userName: String, modelContext: ModelContext) async -> String? {
        do {
            let container = CKContainer(identifier: "iCloud.com.elmelz.parallel")
            let database = container.privateCloudDatabase
            
            // Query for UserSettings with matching userName
            let predicate = NSPredicate(format: "userName == %@", userName)
            let query = CKQuery(recordType: "UserSettings", predicate: predicate)
            
            let (results, _) = try await database.records(matching: query)
            
            // Get the first matching record
            if let firstResult = results.first {
                let record = try firstResult.1.get()
                
                // Get the deviceToken field
                if let token = record["deviceToken"] as? String {
                    print("✅ Found device token for \(userName): \(token)")
                    return token
                }
            }
            
            print("⚠️ No device token found for \(userName)")
            return nil
            
        } catch {
            print("❌ Error fetching device token: \(error)")
            return nil
        }
    }
    
    // MARK: - Send Push Notification via Server
    private func sendNotification(to deviceToken: String, title: String, body: String, soundName: String) async {
        // Your notification server endpoint
        guard let url = URL(string: "https://parallel-push.vercel.app/api/sendApns") else {
            print("❌ Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "deviceToken": deviceToken,
            "title": title,
            "body": body,
            "sound": soundName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("✅ Notification sent successfully to \(deviceToken)")
                } else {
                    print("⚠️ Notification failed with status: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                }
            }
        } catch {
            print("❌ Error sending notification: \(error)")
        }
    }
}
