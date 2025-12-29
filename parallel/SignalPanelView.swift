import SwiftUI
import SwiftData

struct SignalPanelView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let myName: String
    
    @State private var energy: Double = 50
    @State private var mood: Double = 0
    @State private var closeness: Double = 50
    
    var body: some View {
        ZStack {
            // Soft background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Handle bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                Text("How are you feeling?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 4)
                
                VStack(spacing: 24) {
                    // Energy slider
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                Text("Energy")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            Spacer()
                            Text("\(Int(energy))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color.orange)
                        }
                        
                        CustomSlider(value: $energy, range: 0...100, color: .orange)
                    }
                    
                    // Mood slider
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(moodColor.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                Text("Mood")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            Spacer()
                            Text(moodLabel)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(moodColor)
                        }
                        
                        CustomSlider(value: $mood, range: -50...50, color: moodColor)
                    }
                    
                    // Closeness slider
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.pink.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                Text("Closeness")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                            Spacer()
                            Text("\(Int(closeness))")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color.pink)
                        }
                        
                        CustomSlider(value: $closeness, range: 0...100, color: .pink)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Action buttons - Share or Keep Private
                VStack(spacing: 12) {
                    Button {
                        saveSignal(isShared: true)
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
                                            Color(red: 0.95, green: 0.4, blue: 0.5),
                                            Color(red: 0.9, green: 0.3, blue: 0.45)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.pink.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
                    Button {
                        saveSignal(isShared: false)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                            Text("Keep mine")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.7))
                        )
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    var moodLabel: String {
        if mood < -30 {
            return "😔 Low"
        } else if mood < -10 {
            return "😐 Meh"
        } else if mood < 10 {
            return "😊 Okay"
        } else if mood < 30 {
            return "😄 Good"
        } else {
            return "🤩 Great"
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
    
    private func saveSignal(isShared: Bool) {
        let signal = Signal(
            author: myName,
            energy: energy,
            mood: mood,
            closeness: closeness,
            isShared: isShared
        )
        
        modelContext.insert(signal)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(height: 8)
                
                // Active track
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.6))
                    .frame(width: progressWidth(geometry: geometry), height: 8)
                
                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: progressWidth(geometry: geometry) - 12)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let percent = min(max(0, gesture.location.x / geometry.size.width), 1)
                        value = range.lowerBound + (range.upperBound - range.lowerBound) * percent
                        
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }
            )
        }
        .frame(height: 24)
    }
    
    private func progressWidth(geometry: GeometryProxy) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * percent
    }
}
