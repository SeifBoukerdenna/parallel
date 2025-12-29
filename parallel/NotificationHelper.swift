import SwiftUI
import SwiftData

class NotificationHelper {
    static let shared = NotificationHelper()
    
    private init() {}
    
    // MARK: - Register Device Token
    func registerDeviceToken(_ tokenString: String, forUser userName: String, modelContext: ModelContext) {
        print("🔵 [REGISTER] Starting token registration for: \(userName)")
        print("🔵 [REGISTER] Token: \(tokenString)")
        
        let descriptor = FetchDescriptor<DeviceToken>(
            predicate: #Predicate { $0.userName == userName }
        )
        
        do {
            let existing = try modelContext.fetch(descriptor)
            
            if let deviceToken = existing.first {
                deviceToken.updateToken(tokenString)
                print("✅ [REGISTER] Updated existing token for \(userName)")
            } else {
                let newToken = DeviceToken(userName: userName, token: tokenString)
                modelContext.insert(newToken)
                print("✅ [REGISTER] Created new token for \(userName)")
            }
            
            try modelContext.save()
            print("✅ [REGISTER] Saved to SwiftData/CloudKit")
            
            // Verify it was saved
            let verify = try modelContext.fetch(descriptor)
            print("✅ [REGISTER] Verified - Found \(verify.count) token(s) for \(userName)")
            
        } catch {
            print("❌ [REGISTER] Error: \(error)")
        }
    }
    
    // MARK: - Shared Moment Notification
    func notifySharedMoment(fromUser: String, toUser: String, momentType: MomentKind, title: String?, modelContext: ModelContext) {
        print("🔵 [MOMENT] Starting notification")
        print("🔵 [MOMENT] From: \(fromUser) → To: \(toUser)")
        
        Task {
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("❌ [MOMENT] No device token found for \(toUser)")
                return
            }
            
            print("✅ [MOMENT] Found recipient token: \(recipientToken.prefix(20))...")
            
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
            
            print("🔵 [MOMENT] Sending: '\(notificationTitle)'")
            await sendNotification(
                to: recipientToken,
                title: notificationTitle,
                body: notificationBody,
                soundName: "default"
            )
        }
    }
    
    // MARK: - Shared Signal Notification
    func notifySharedSignal(fromUser: String, toUser: String, energy: Double, mood: Double, closeness: Double, modelContext: ModelContext) {
        print("🔵 [SIGNAL] Starting notification")
        print("🔵 [SIGNAL] From: \(fromUser) → To: \(toUser)")
        
        Task {
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("❌ [SIGNAL] No device token found for \(toUser)")
                return
            }
            
            print("✅ [SIGNAL] Found recipient token: \(recipientToken.prefix(20))...")
            
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
            
            print("🔵 [SIGNAL] Sending: '\(moodEmoji) \(fromUser) shared their signal'")
            await sendNotification(
                to: recipientToken,
                title: "\(moodEmoji) \(fromUser) shared their signal",
                body: "See how they're feeling right now",
                soundName: "default"
            )
        }
    }
    
    // MARK: - Ping Notification
    func notifyPing(fromUser: String, toUser: String, message: String, modelContext: ModelContext) {
        print("🔵 [PING] Starting notification")
        print("🔵 [PING] From: \(fromUser) → To: \(toUser)")
        print("🔵 [PING] Message: '\(message)'")
        
        Task {
            guard let recipientToken = await getDeviceToken(for: toUser, modelContext: modelContext) else {
                print("❌ [PING] No device token found for \(toUser)")
                return
            }
            
            print("✅ [PING] Found recipient token: \(recipientToken.prefix(20))...")
            
            await sendNotification(
                to: recipientToken,
                title: "💬 \(fromUser) sent a ping!",
                body: message,
                soundName: "default"
            )
        }
    }
    
    // MARK: - Get Device Token
    private func getDeviceToken(for userName: String, modelContext: ModelContext) async -> String? {
        print("🔵 [FETCH] Fetching device token for: \(userName)")
        
        // Give CloudKit a moment to sync if needed
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let descriptor = FetchDescriptor<DeviceToken>(
            predicate: #Predicate { $0.userName == userName }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            
            print("🔵 [FETCH] Found \(results.count) token(s)")
            
            if let deviceToken = results.first {
                print("✅ [FETCH] Token for \(userName): \(deviceToken.token.prefix(20))...")
                return deviceToken.token
            }
            
            print("⚠️ [FETCH] No token found for \(userName)")
            
            // Try fetching ALL tokens for debugging
            let allDescriptor = FetchDescriptor<DeviceToken>()
            let allTokens = try modelContext.fetch(allDescriptor)
            print("🔵 [FETCH] Total tokens in database: \(allTokens.count)")
            for token in allTokens {
                print("   - \(token.userName): \(token.token.prefix(20))...")
            }
            
            return nil
            
        } catch {
            print("❌ [FETCH] Error: \(error)")
            return nil
        }
    }
    
    // MARK: - Send Push Notification
    private func sendNotification(to deviceToken: String, title: String, body: String, soundName: String) async {
        print("🔵 [SEND] Preparing to send notification")
        print("🔵 [SEND] To token: \(deviceToken.prefix(20))...")
        print("🔵 [SEND] Title: '\(title)'")
        print("🔵 [SEND] Body: '\(body)'")
        
        guard let url = URL(string: "https://parallel-push.vercel.app/api/sendApns") else {
            print("❌ [SEND] Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // 30 second timeout
        
        let payload: [String: Any] = [
            "deviceToken": deviceToken,
            "title": title,
            "body": body,
            "sound": soundName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            print("🔵 [SEND] Request body created")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📬 [SEND] HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("✅ [SEND] Notification sent successfully!")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 [SEND] Response: \(responseString)")
                    }
                } else {
                    print("⚠️ [SEND] Failed with status: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("📄 [SEND] Response: \(responseString)")
                    }
                }
            }
        } catch {
            print("❌ [SEND] Network error: \(error)")
            print("❌ [SEND] Error details: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Debug Helper
    func debugPrintAllTokens(modelContext: ModelContext) {
        print("🔍 [DEBUG] Fetching all device tokens...")
        
        let descriptor = FetchDescriptor<DeviceToken>()
        
        do {
            let allTokens = try modelContext.fetch(descriptor)
            print("🔍 [DEBUG] Total tokens: \(allTokens.count)")
            
            for token in allTokens {
                print("   📱 \(token.userName): \(token.token)")
                print("      Updated: \(token.updatedAt)")
            }
            
            if allTokens.isEmpty {
                print("⚠️ [DEBUG] No tokens found - make sure both devices have registered!")
            }
        } catch {
            print("❌ [DEBUG] Error: \(error)")
        }
    }
}
