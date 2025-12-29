import SwiftUI

struct DeviceTokenView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var notificationManager = NotificationManager.shared
    
    @State private var showCopiedAlert = false
    @State private var isSendingTest = false
    @State private var testResult: String?
    
    func sendTestNotification() {
        guard let token = notificationManager.deviceToken else { return }
        
        isSendingTest = true
        testResult = nil
        
        let url = URL(string: "https://parallel-push.vercel.app/api/sendApns")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "deviceToken": token,
            "title": "💕 Test from Parallel",
            "body": "Your notifications are working perfectly!"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSendingTest = false
                
                if let error = error {
                    testResult = "❌ Error: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        testResult = "✅ Notification sent successfully!"
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    } else {
                        testResult = "❌ Failed with status: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.96, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                    
                    Text("Notifications")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Permission status
                        VStack(spacing: 12) {
                            HStack {
                                Text("Permission Status")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                Image(systemName: notificationManager.notificationPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(notificationManager.notificationPermissionGranted ? .green : .red)
                                
                                Text(notificationManager.notificationPermissionGranted ? "Notifications Enabled" : "Notifications Disabled")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white.opacity(0.6))
                            )
                            
                            if !notificationManager.notificationPermissionGranted {
                                Button {
                                    NotificationManager.shared.requestPermission()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.badge")
                                        Text("Enable Notifications")
                                    }
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.3, green: 0.5, blue: 0.9),
                                                        Color(red: 0.2, green: 0.4, blue: 0.85)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                }
                            }
                        }
                        
                        // Device token
                        VStack(spacing: 12) {
                            HStack {
                                Text("Device Token")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            if let token = notificationManager.deviceToken {
                                VStack(spacing: 12) {
                                    Text(token)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.white.opacity(0.7))
                                        )
                                        .textSelection(.enabled)
                                    
                                    Button {
                                        UIPasteboard.general.string = token
                                        showCopiedAlert = true
                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                        impact.impactOccurred()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showCopiedAlert = false
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: showCopiedAlert ? "checkmark" : "doc.on.doc")
                                            Text(showCopiedAlert ? "Copied!" : "Copy Token")
                                        }
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                showCopiedAlert ?
                                                AnyShapeStyle(Color.green) :
                                                AnyShapeStyle(LinearGradient(
                                                    colors: [
                                                        Color(red: 0.9, green: 0.4, blue: 0.5),
                                                        Color(red: 0.9, green: 0.3, blue: 0.45)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ))
                                            )
                                    )
                                    }
                                }
                            } else {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                        Text("Waiting for device token...")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.black.opacity(0.5))
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.white.opacity(0.6))
                                    )
                                    
                                    Text("Make sure you're signed into iCloud and have internet connection")
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.black.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                        
                        // Test notification button
                        if notificationManager.deviceToken != nil {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Test Notification")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.5))
                                    Spacer()
                                }
                                
                                Button {
                                    sendTestNotification()
                                } label: {
                                    HStack(spacing: 8) {
                                        if isSendingTest {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("Sending...")
                                        } else {
                                            Image(systemName: "bell.badge.fill")
                                            Text("Send Test Notification")
                                        }
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.6, green: 0.4, blue: 0.9),
                                                        Color(red: 0.5, green: 0.3, blue: 0.85)
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .shadow(color: Color.purple.opacity(0.2), radius: 8, x: 0, y: 4)
                                }
                                .disabled(isSendingTest)
                                .opacity(isSendingTest ? 0.6 : 1.0)
                                
                                // Test result
                                if let result = testResult {
                                    HStack(spacing: 8) {
                                        Text(result)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(result.contains("✅") ? .green : .red)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill((result.contains("✅") ? Color.green : Color.red).opacity(0.1))
                                    )
                                }
                            }
                        }
                        
                        // Instructions
                        VStack(spacing: 12) {
                            HStack {
                                Text("How to Test")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                InstructionRow(number: "1", text: "Tap 'Send Test Notification' button above")
                                InstructionRow(number: "2", text: "Or copy token for Apple dashboard testing")
                                InstructionRow(number: "3", text: "Check your iPhone for notification")
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.white.opacity(0.6))
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color(red: 0.3, green: 0.5, blue: 0.9))
                )
            
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.black.opacity(0.7))
            
            Spacer()
        }
    }
}
