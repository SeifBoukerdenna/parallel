import SwiftUI
import AVFoundation

struct MomentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let moment: Moment
    let accentColor: Color
    
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var playbackTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background gradient based on moment type
            backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        audioPlayer?.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    // Shared/Private badge
                    HStack(spacing: 6) {
                        Image(systemName: moment.isShared ? "heart.fill" : "lock.fill")
                            .font(.system(size: 12))
                        Text(moment.isShared ? "Shared" : "Private")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Content based on type
                switch moment.kind {
                case .text:
                    textDetailView
                case .photo:
                    photoDetailView
                case .voice:
                    voiceDetailView
                }
                
                Spacer()
                
                // Footer info
                VStack(spacing: 8) {
                    Text(moment.author)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(moment.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    var backgroundGradient: some View {
        Group {
            switch moment.kind {
            case .text:
                LinearGradient(
                    colors: [
                        Color(red: 0.3, green: 0.4, blue: 0.7),
                        Color(red: 0.4, green: 0.5, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .photo:
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.3, blue: 0.4),
                        Color(red: 0.3, green: 0.4, blue: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .voice:
                LinearGradient(
                    colors: [
                        Color(red: 0.5, green: 0.3, blue: 0.7),
                        Color(red: 0.6, green: 0.4, blue: 0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    var textDetailView: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            ScrollView {
                Text(moment.text ?? "")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 32)
            }
        }
    }
    
    var photoDetailView: some View {
        VStack {
            if let photoPath = moment.photoPath {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let photoURL = documentsPath.appendingPathComponent(photoPath)
                if let imageData = try? Data(contentsOf: photoURL),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    var voiceDetailView: some View {
        VStack(spacing: 32) {
            // Animated waveform
            HStack(spacing: 6) {
                ForEach(0..<20) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.7))
                        .frame(width: 6, height: isPlaying ? CGFloat.random(in: 40...120) : CGFloat.random(in: 40...80))
                        .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true).delay(Double(i) * 0.05), value: isPlaying)
                }
            }
            .padding(.horizontal, 20)
            
            // Playback controls
            VStack(spacing: 20) {
                // Time display
                HStack {
                    Text(formatTime(currentTime))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(formatTime(duration))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .monospacedDigit()
                }
                .padding(.horizontal, 40)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: duration > 0 ? geometry.size.width * (currentTime / duration) : 0, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
                
                // Play/Pause button
                Button {
                    togglePlayback()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                            .offset(x: isPlaying ? 0 : 3)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
            }
        }
        .onAppear {
            loadAudioDuration()
        }
        .onDisappear {
            playbackTimer?.invalidate()
        }
    }
    
    private func togglePlayback() {
        guard let audioPath = moment.audioPath else { return }
        
        if isPlaying {
            audioPlayer?.pause()
            playbackTimer?.invalidate()
            isPlaying = false
        } else {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent(audioPath)
            
            do {
                if audioPlayer == nil {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                    duration = audioPlayer?.duration ?? 0
                }
                
                audioPlayer?.play()
                isPlaying = true
                
                // Update current time
                playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    currentTime = audioPlayer?.currentTime ?? 0
                    
                    if currentTime >= duration {
                        isPlaying = false
                        playbackTimer?.invalidate()
                        currentTime = 0
                        audioPlayer?.currentTime = 0
                    }
                }
                
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
    
    private func loadAudioDuration() {
        guard let audioPath = moment.audioPath else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(audioPath)
        
        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            duration = player.duration
        } catch {
            print("Failed to load audio duration: \(error)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
