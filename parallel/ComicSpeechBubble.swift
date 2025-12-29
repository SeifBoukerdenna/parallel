import SwiftUI

struct ComicSpeechBubble: View {
    let message: String
    let isMyMessage: Bool
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var bubbleColor: Color {
        isMyMessage ? Color(red: 0.95, green: 0.98, blue: 1.0) : Color(red: 1.0, green: 0.95, blue: 0.97)
    }
    
    var borderColor: Color {
        isMyMessage ? Color(red: 0.3, green: 0.5, blue: 0.9) : Color(red: 0.9, green: 0.4, blue: 0.5)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Speech bubble with pixel art border
            HStack(spacing: 0) {
                Text(message)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(
                ZStack {
                    // Main bubble
                    RoundedRectangle(cornerRadius: 16)
                        .fill(bubbleColor)
                    
                    // Pixel art style border
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(borderColor, lineWidth: 3)
                    
                    // Inner white highlight (comic book style)
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white, lineWidth: 1)
                        .padding(2)
                }
            )
            .shadow(color: borderColor.opacity(0.3), radius: 12, x: 0, y: 6)
            
            // Pixel art tail
            PixelTail(color: bubbleColor, borderColor: borderColor, pointsLeft: !isMyMessage)
                .frame(width: 24, height: 16)
                .offset(x: isMyMessage ? 20 : -20, y: -2)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Bounce animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                scale = 0.8
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onDismiss()
            }
        }
    }
}

struct PixelTail: View {
    let color: Color
    let borderColor: Color
    let pointsLeft: Bool
    
    let pixelSize: CGFloat = 4
    
    var body: some View {
        ZStack {
            // Fill
            if pointsLeft {
                // Points to the left
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        pixel(color)
                        pixel(color)
                        pixel(color)
                        pixel(color)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(color)
                        pixel(color)
                        pixel(color)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(color)
                        pixel(color)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(color)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                }
            } else {
                // Points to the right
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(color)
                        pixel(color)
                        pixel(color)
                        pixel(color)
                    }
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(color)
                        pixel(color)
                        pixel(color)
                    }
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(color)
                        pixel(color)
                    }
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(color)
                    }
                }
            }
            
            // Border overlay
            if pointsLeft {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        pixel(borderColor)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(borderColor)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(borderColor)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                    }
                    HStack(spacing: 0) {
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(borderColor)
                    }
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(borderColor)
                    }
                    HStack(spacing: 0) {
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(.clear)
                        pixel(borderColor)
                    }
                    HStack(spacing: 0) {
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                        pixel(borderColor)
                    }
                }
            }
        }
    }
    
    func pixel(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: pixelSize, height: pixelSize)
    }
}
