import SwiftUI
import SwiftData

struct DebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var deviceTokens: [DeviceToken]
    @Query private var moments: [Moment]
    @Query private var signals: [Signal]
    @Query private var pings: [Ping]
    
    @AppStorage("currentUserName") private var currentUserName: String?
    
    @State private var testTitle = "Test Notification"
    @State private var testBody = "This is a test!"
    @State private var testResult = ""
    
    var myName: String {
        currentUserName ?? "Unknown"
    }
    
    var herName: String {
        if myName == "Malik" {
            return "Maya"
        } else {
            return "Malik"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.96, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        Text("Debug Panel")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Spacer()
                        
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
                    
                    // Current User
                    DebugSection(title: "Current User") {
                        Text("I am: \(myName)")
                            .font(.system(size: 14, design: .monospaced))
                        Text("Other: \(herName)")
                            .font(.system(size: 14, design: .monospaced))
                    }
                    
                    // Device Tokens
                    DebugSection(title: "Device Tokens (\(deviceTokens.count))") {
                        if deviceTokens.isEmpty {
                            Text("❌ No tokens registered!")
                                .foregroundColor(.red)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        } else {
                            ForEach(deviceTokens) { token in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("User: \(token.userName)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    Text("Token: \(token.token)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .textSelection(.enabled)
                                    Text("Updated: \(token.updatedAt.formatted())")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.black.opacity(0.5))
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.1))
                                )
                            }
                        }
                        
                        Button {
                            NotificationHelper.shared.debugPrintAllTokens(modelContext: modelContext)
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Print to Console")
                            }
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue)
                            )
                        }
                    }
                    
                    // Data Sync Status
                    DebugSection(title: "Data Sync Status") {
                        HStack {
                            Text("Moments:")
                            Spacer()
                            Text("\(moments.count)")
                                .foregroundColor(moments.count > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Signals:")
                            Spacer()
                            Text("\(signals.count)")
                                .foregroundColor(signals.count > 0 ? .green : .red)
                        }
                        
                        HStack {
                            Text("Pings:")
                            Spacer()
                            Text("\(pings.count)")
                                .foregroundColor(pings.count > 0 ? .green : .red)
                        }
                        
                        Divider()
                        
                        Text("My moments: \(moments.filter { $0.author == myName }.count)")
                            .font(.system(size: 12, design: .monospaced))
                        Text("\(herName)'s moments: \(moments.filter { $0.author == herName }.count)")
                            .font(.system(size: 12, design: .monospaced))
                    }
                    
                    // Test Notification
                    DebugSection(title: "Test Notification") {
                        TextField("Title", text: $testTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Body", text: $testBody)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            sendTestNotification()
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send to \(herName)")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.purple)
                            )
                        }
                        
                        if !testResult.isEmpty {
                            Text(testResult)
                                .font(.system(size: 12, design: .monospaced))
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(testResult.contains("✅") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                        }
                    }
                    
                    // Force Sync
                    DebugSection(title: "CloudKit Sync") {
                        Button {
                            forceSync()
                        } label: {
                            HStack {
                                Image(systemName: "icloud.and.arrow.down")
                                Text("Force CloudKit Sync")
                            }
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange)
                            )
                        }
                        
                        Text("Use this if data isn't syncing between devices")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    
                    // Instructions
                    DebugSection(title: "Troubleshooting") {
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "1.circle.fill", text: "Make sure both devices are signed into the SAME iCloud account")
                            TipRow(icon: "2.circle.fill", text: "Both devices need internet connection")
                            TipRow(icon: "3.circle.fill", text: "Open app on both devices to register tokens")
                            TipRow(icon: "4.circle.fill", text: "Wait 10-30 seconds for CloudKit to sync")
                            TipRow(icon: "5.circle.fill", text: "Check Xcode Console for detailed logs")
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func sendTestNotification() {
        print("🧪 [TEST] Sending test notification...")
        testResult = "Sending..."
        
        Task {
            // Try to get the other user's token
            if let token = await getDeviceToken(for: herName) {
                print("🧪 [TEST] Found token for \(herName): \(token.prefix(20))...")
                
                guard let url = URL(string: "https://parallel-push.vercel.app/api/sendApns") else {
                    testResult = "❌ Invalid URL"
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let payload: [String: Any] = [
                    "deviceToken": token,
                    "title": testTitle,
                    "body": testBody,
                    "sound": "default"
                ]
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: payload)
                    
                    let (data, response) = try await URLSession.shared.data(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            testResult = "✅ Sent! Check \(herName)'s device"
                            print("🧪 [TEST] Success!")
                        } else {
                            if let responseString = String(data: data, encoding: .utf8) {
                                testResult = "❌ Failed: \(responseString)"
                                print("🧪 [TEST] Failed: \(responseString)")
                            } else {
                                testResult = "❌ Failed: Status \(httpResponse.statusCode)"
                            }
                        }
                    }
                } catch {
                    testResult = "❌ Error: \(error.localizedDescription)"
                    print("🧪 [TEST] Error: \(error)")
                }
            } else {
                testResult = "❌ No token found for \(herName)"
                print("🧪 [TEST] No token found")
            }
        }
    }
    
    private func getDeviceToken(for userName: String) async -> String? {
        let descriptor = FetchDescriptor<DeviceToken>(
            predicate: #Predicate { $0.userName == userName }
        )
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first?.token
        } catch {
            print("❌ Error fetching token: \(error)")
            return nil
        }
    }
    
    private func forceSync() {
        print("🔄 [SYNC] Forcing CloudKit sync...")
        
        Task {
            do {
                try modelContext.save()
                print("✅ [SYNC] SwiftData saved")
                
                // Wait a moment for CloudKit to process
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                print("✅ [SYNC] Complete! Check other device")
            } catch {
                print("❌ [SYNC] Error: \(error)")
            }
        }
    }
}

struct DebugSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.5))
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 10) {
                content
            }
            .font(.system(size: 14, design: .rounded))
            .foregroundColor(.black.opacity(0.7))
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.7))
            )
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
            
            Text(text)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.black.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
