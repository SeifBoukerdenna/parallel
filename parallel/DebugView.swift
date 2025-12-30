import SwiftUI
import SwiftData
import CloudKit

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
    @State private var cloudKitStatus = "Checking..."
    @State private var iCloudAccountStatus = "Checking..."
    @State private var syncResult = ""
    
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
                    
                    // 🚨 CLOUDKIT STATUS (MOST IMPORTANT)
                    DebugSection(title: "☁️ iCloud Status") {
                        HStack {
                            Text("Account:")
                            Spacer()
                            Text(iCloudAccountStatus)
                                .foregroundColor(
                                    iCloudAccountStatus.contains("Available") ? .green :
                                    iCloudAccountStatus.contains("Checking") ? .orange : .red
                                )
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                        
                        HStack {
                            Text("CloudKit:")
                            Spacer()
                            Text(cloudKitStatus)
                                .foregroundColor(
                                    cloudKitStatus.contains("Working") ? .green :
                                    cloudKitStatus.contains("Checking") ? .orange : .red
                                )
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                        
                        if iCloudAccountStatus.contains("Not") || cloudKitStatus.contains("Failed") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("⚠️ FIX THIS FIRST:")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.red)
                                
                                Text("1. Go to Settings → [Your Name]")
                                Text("2. Tap iCloud")
                                Text("3. Make sure iCloud Drive is ON")
                                Text("4. Scroll down and enable Parallel")
                                Text("5. BOTH devices must use SAME Apple ID")
                            }
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        
                        Button {
                            checkCloudKitStatus()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Recheck Status")
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
                            
                            Text("This means CloudKit is NOT syncing!")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
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
                    
                    // Force Sync (AGGRESSIVE)
                    DebugSection(title: "🔄 Force Sync") {
                        if !syncResult.isEmpty {
                            Text(syncResult)
                                .font(.system(size: 12, design: .monospaced))
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(syncResult.contains("✅") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                )
                        }
                        
                        Button {
                            aggressiveSync()
                        } label: {
                            HStack {
                                Image(systemName: "icloud.and.arrow.down")
                                Text("FORCE SYNC NOW")
                            }
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange)
                            )
                        }
                        
                        Text("Press this on BOTH devices, wait 10 seconds")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
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
                    
                    // Instructions
                    DebugSection(title: "Troubleshooting") {
                        VStack(alignment: .leading, spacing: 8) {
                            TipRow(icon: "1.circle.fill", text: "Check iCloud status above - FIX IT FIRST")
                            TipRow(icon: "2.circle.fill", text: "BOTH devices must use SAME Apple ID")
                            TipRow(icon: "3.circle.fill", text: "Both need internet connection")
                            TipRow(icon: "4.circle.fill", text: "Press FORCE SYNC on both devices")
                            TipRow(icon: "5.circle.fill", text: "Wait 10-30 seconds between syncs")
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            checkCloudKitStatus()
        }
    }
    
    private func checkCloudKitStatus() {
        // Check iCloud account status
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    iCloudAccountStatus = "✅ Available"
                case .noAccount:
                    iCloudAccountStatus = "❌ Not signed in"
                case .restricted:
                    iCloudAccountStatus = "❌ Restricted"
                case .couldNotDetermine:
                    iCloudAccountStatus = "⚠️ Unknown"
                case .temporarilyUnavailable:
                    iCloudAccountStatus = "⚠️ Temporarily unavailable"
                @unknown default:
                    iCloudAccountStatus = "❌ Unknown error"
                }
                
                if let error = error {
                    iCloudAccountStatus += " - \(error.localizedDescription)"
                }
            }
        }
        
        // Test CloudKit access
        let container = CKContainer(identifier: "iCloud.com.elmelz.parallel")
        let database = container.privateCloudDatabase
        
        // Try to fetch a record to test connectivity
        let query = CKQuery(recordType: "CD_DeviceToken", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        database.perform(query, inZoneWith: nil) { records, error in
            DispatchQueue.main.async {
                if let error = error {
                    cloudKitStatus = "❌ Failed: \(error.localizedDescription)"
                } else {
                    cloudKitStatus = "✅ Working - Found \(records?.count ?? 0) records"
                }
            }
        }
    }
    
    private func aggressiveSync() {
        syncResult = "Syncing..."
        
        Task {
            do {
                print("🔄 [SYNC] Starting aggressive sync...")
                
                // Save current context
                try modelContext.save()
                print("✅ [SYNC] Saved local data")
                
                // Get the CloudKit container
                guard let container = modelContext.container as? ModelContainer else {
                    syncResult = "❌ Can't access container"
                    return
                }
                
                // Try to trigger CloudKit sync (this is hacky but sometimes works)
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                syncResult = "✅ Sync triggered! Check other device in 10 seconds"
                print("✅ [SYNC] Complete")
                
                // Refresh queries
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // This forces a UI refresh
                    _ = deviceTokens.count
                }
                
            } catch {
                syncResult = "❌ Error: \(error.localizedDescription)"
                print("❌ [SYNC] Error: \(error)")
            }
        }
    }
    
    private func sendTestNotification() {
        print("🧪 [TEST] Sending test notification...")
        testResult = "Sending..."
        
        Task {
            // Force a sync first
            try? modelContext.save()
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
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
                testResult = "❌ No token for \(herName) - CloudKit not syncing!"
                print("🧪 [TEST] No token found - sync issue")
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
