import SwiftUI
import SwiftData

struct SignalPanelView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query(sort: \Signal.createdAt, order: .reverse) private var allSignals: [Signal]
    
    let myName: String
    
    @State private var mood: Double = 0
    
    var myLatestSignal: Signal? {
        allSignals.first(where: { $0.author == myName })
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                Text("How are you feeling?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                
                Spacer()
                
                // Large mood emoji display
                VStack(spacing: 20) {
                    Text(moodEmoji)
                        .font(.system(size: 120))
                        .scaleEffect(1.0 + abs(mood) / 200)
                        .animation(.spring(response: 0.3), value: mood)
                    
                    Text(moodLabel)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(moodColor)
                }
                
                Spacer()
                
                // Mood slider
                VStack(spacing: 16) {
                    HStack {
                        Text("😔")
                            .font(.system(size: 24))
                            .opacity(0.3)
                        
                        Spacer()
                        
                        Text("😊")
                            .font(.system(size: 24))
                            .opacity(0.3)
                        
                        Spacer()
                        
                        Text("🤩")
                            .font(.system(size: 24))
                            .opacity(0.3)
                    }
                    .padding(.horizontal, 24)
                    
                    CustomMoodSlider(value: $mood, range: -50...50, color: moodColor)
                        .padding(.horizontal, 24)
                    
                    Text("\(Int(mood))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(moodColor)
                        .monospacedDigit()
                }
                .padding(.bottom, 20)
                
                Button {
                    saveSignal()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text("Share with us")
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        moodColor,
                                        moodColor.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: moodColor.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            if let latest = myLatestSignal {
                mood = latest.mood
            }
        }
    }
    
    var moodEmoji: String {
        if mood < -30 {
            return "😔"
        } else if mood < -10 {
            return "😐"
        } else if mood < 10 {
            return "😊"
        } else if mood < 30 {
            return "😄"
        } else {
            return "🤩"
        }
    }
    
    var moodLabel: String {
        if mood < -30 {
            return "Low"
        } else if mood < -10 {
            return "Meh"
        } else if mood < 10 {
            return "Okay"
        } else if mood < 30 {
            return "Good"
        } else {
            return "Great"
        }
    }
    
    var moodColor: Color {
        if mood < -20 {
            return Color(red: 0.4, green: 0.6, blue: 0.9)
        } else if mood < 0 {
            return Color(red: 0.5, green: 0.7, blue: 0.85)
        } else if mood < 20 {
            return Color(red: 0.5, green: 0.8, blue: 0.6)
        } else {
            return Color(red: 0.7, green: 0.5, blue: 0.9)
        }
    }
    
    private func saveSignal() {
        let signal = Signal(
            author: myName,
            mood: mood,
            isShared: true
        )
        
        modelContext.insert(signal)
        
        // ✅ SYNC TO FIREBASE
        firebaseManager.syncSignal(signal)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}

struct CustomMoodSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(height: 12)
                
                // Progress bar
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.6))
                    .frame(width: progressWidth(geometry: geometry), height: 12)
                    .offset(x: value >= 0 ? geometry.size.width / 2 : progressWidth(geometry: geometry) + geometry.size.width / 2)
                
                // Center marker
                Rectangle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 3, height: 16)
                    .offset(x: geometry.size.width / 2 - 1.5)
                
                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
                    .offset(x: thumbPosition(geometry: geometry) - 16)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let width = geometry.size.width
                        let x = gesture.location.x

                        let percent = ((x / width) - CGFloat(0.5)) * CGFloat(2)

                        let scaled = percent * (range.upperBound - range.lowerBound) / CGFloat(2)
                        value = max(range.lowerBound, min(range.upperBound, scaled))

                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
            )

        }
        .frame(height: 32)
    }
    
    private func progressWidth(geometry: GeometryProxy) -> CGFloat {
        let halfWidth = geometry.size.width / 2
        let percent = abs(value) / (range.upperBound - range.lowerBound) * 2
        return halfWidth * percent
    }
    
    private func thumbPosition(geometry: GeometryProxy) -> CGFloat {
        let halfWidth = geometry.size.width / 2
        let percent = value / (range.upperBound - range.lowerBound) * 2
        return halfWidth + (percent * halfWidth)
    }
}
