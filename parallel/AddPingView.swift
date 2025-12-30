import SwiftUI
import SwiftData

struct AddPingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let myName: String
    
    @State private var message = ""
    @FocusState private var isInputFocused: Bool
    
    let maxChars = 50
    
    let quickEmojis = ["💕", "😊", "🥰", "😘", "🤗", "✨", "💖", "🌟", "😍", "🎉", "👋", "💭", "☀️", "🌙"]
    
    var canSend: Bool {
        !message.isEmpty && message.count <= maxChars
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
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.9, green: 0.4, blue: 0.5).opacity(0.15))
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Ping!")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.black.opacity(0.7))
                            
                            Text("Send a cute message")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Message")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Spacer()
                            
                            Text("\(message.count)/\(maxChars)")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(message.count > maxChars ? .red : .black.opacity(0.3))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(Color(red: 0.9, green: 0.4, blue: 0.5), lineWidth: 2)
                                )
                                .shadow(color: Color(red: 0.9, green: 0.4, blue: 0.5).opacity(0.15), radius: 8, x: 0, y: 4)
                            
                            TextField("Hey! Miss you! 💕", text: $message)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .focused($isInputFocused)
                        }
                        .frame(height: 56)
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 11))
                                .foregroundColor(.black.opacity(0.35))
                            
                            Text("Quick Emojis")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Spacer()
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(quickEmojis, id: \.self) { emoji in
                                Button {
                                    message += emoji
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                } label: {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(.white.opacity(0.7))
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        sendPing()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18))
                            
                            Text("Send Ping!")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.95, green: 0.45, blue: 0.5),
                                                Color(red: 0.9, green: 0.35, blue: 0.45)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(.white.opacity(0.3), lineWidth: 2)
                                    .padding(2)
                            }
                            .shadow(color: Color.pink.opacity(canSend ? 0.35 : 0.15), radius: 16, x: 0, y: 8)
                        )
                    }
                    .disabled(!canSend)
                    .opacity(canSend ? 1.0 : 0.5)
                    .scaleEffect(canSend ? 1.0 : 0.98)
                    .animation(.spring(response: 0.3), value: canSend)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isInputFocused = true
            }
        }
    }
    
    private func sendPing() {
        let ping = Ping(author: myName, message: message)
        modelContext.insert(ping)
        
        // ✅ SYNC TO FIREBASE
        firebaseManager.syncPing(ping)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}
