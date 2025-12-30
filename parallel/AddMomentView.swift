import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct AddMomentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let myName: String
    
    @State private var selectedType: MomentKind = MomentKind.text
    @State private var momentTitle = ""
    @State private var momentText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showCamera = false
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    @State private var hasRecording = false
    @State private var audioPath: String?
    
    let maxTitleChars = 40
    let maxChars = 280
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.95, green: 0.96, blue: 0.99),
                    Color(red: 0.96, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.6))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black.opacity(0.5))
                            }
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16))
                            .foregroundColor(.pink.opacity(0.6))
                        
                        Text("New Moment")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 11))
                                    .foregroundColor(.black.opacity(0.35))
                                
                                Text("Title (optional)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Spacer()
                                
                                Text("\(momentTitle.count)/\(maxTitleChars)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(momentTitle.count > maxTitleChars ? .red : .black.opacity(0.3))
                            }
                            .padding(.horizontal, 4)
                            
                            TextField("Give it a name...", text: $momentTitle)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.8))
                                .accentColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "square.grid.3x1.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.black.opacity(0.35))
                                
                                Text("Type")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 10) {
                                ElegantTypeButton(
                                    icon: "text.alignleft",
                                    label: "Text",
                                    color: Color(red: 0.3, green: 0.5, blue: 0.9),
                                    isSelected: selectedType == MomentKind.text
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedType = MomentKind.text
                                    }
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                                
                                ElegantTypeButton(
                                    icon: "photo",
                                    label: "Photo",
                                    color: Color(red: 0.5, green: 0.7, blue: 0.9),
                                    isSelected: selectedType == MomentKind.photo
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedType = MomentKind.photo
                                    }
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                                
                                ElegantTypeButton(
                                    icon: "waveform",
                                    label: "Voice",
                                    color: Color(red: 0.6, green: 0.4, blue: 0.9),
                                    isSelected: selectedType == MomentKind.voice
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedType = MomentKind.voice
                                    }
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Group {
                            switch selectedType {
                            case .text:
                                textInputView
                            case .photo:
                                photoInputView
                            case .voice:
                                voiceInputView
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .padding(.horizontal, 20)
                        
                        Color.clear.frame(height: 100)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Button {
                    saveMoment()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                        
                        Text("Share with us")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
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
                            .shadow(color: Color.pink.opacity(canSave ? 0.25 : 0.1), radius: 16, x: 0, y: 8)
                    )
                }
                .disabled(!canSave)
                .opacity(canSave ? 1.0 : 0.5)
                .scaleEffect(canSave ? 1.0 : 0.98)
                .animation(.spring(response: 0.3), value: canSave)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $photoData)
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }
    
    var textInputView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundColor(.black.opacity(0.35))
                
                Text("Your thoughts")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.4))
                
                Spacer()
                
                Text("\(momentText.count)/\(maxChars)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(momentText.count > maxChars ? .red : .black.opacity(0.3))
            }
            .padding(.horizontal, 4)
            
            ZStack(alignment: .topLeading) {
                if momentText.isEmpty {
                    Text("What's on your mind?")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.black.opacity(0.3))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                TextEditor(text: $momentText)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(height: 200)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .accentColor(Color(red: 0.9, green: 0.4, blue: 0.5))
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.02), radius: 6, x: 0, y: 3)
            )
        }
    }
    
    var photoInputView: some View {
        VStack(spacing: 16) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                VStack(spacing: 12) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.08), radius: 16, x: 0, y: 8)
                    
                    HStack(spacing: 10) {
                        ElegantIconButton(icon: "camera.fill", label: "Camera") {
                            showCamera = true
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 14))
                                Text("Gallery")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                            )
                        }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 52))
                        .foregroundColor(.black.opacity(0.15))
                    
                    Text("Add a photo")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                    
                    HStack(spacing: 12) {
                        ElegantIconButton(icon: "camera.fill", label: "Camera") {
                            showCamera = true
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 14))
                                Text("Gallery")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.5, green: 0.7, blue: 0.9),
                                                Color(red: 0.4, green: 0.6, blue: 0.85)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                                )
                                .foregroundColor(.black.opacity(0.1))
                        )
                )
            }
        }
    }
    
    var voiceInputView: some View {
        VStack(spacing: 24) {
            if hasRecording {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.15))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 42))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    }
                    
                    VStack(spacing: 6) {
                        Text(formatTime(recordingTime))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                            .monospacedDigit()
                        
                        Text("Recording saved")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    
                    Button {
                        deleteRecording()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Re-record")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.red.opacity(0.6))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.8))
                        )
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.05))
                )
            } else if isRecording {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 3)
                                    .scaleEffect(1.5)
                                    .opacity(0.8)
                            )
                    }
                    
                    VStack(spacing: 6) {
                        Text(formatTime(recordingTime))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                            .monospacedDigit()
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text("Recording...")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    
                    Button {
                        stopRecording()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.red)
                                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(0.05))
                )
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5))
                    
                    VStack(spacing: 6) {
                        Text("Record a voice note")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                        
                        Text("Up to 20 seconds")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                    }
                    
                    Button {
                        startRecording()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mic.fill")
                            Text("Start Recording")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
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
                                .shadow(color: Color.purple.opacity(0.25), radius: 10, x: 0, y: 5)
                        )
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.5))
                )
            }
        }
    }
    
    var canSave: Bool {
        let titleValid = momentTitle.count <= maxTitleChars
        
        switch selectedType {
        case .text:
            return !momentText.isEmpty && momentText.count <= maxChars && titleValid
        case .photo:
            return photoData != nil && titleValid
        case .voice:
            return hasRecording && titleValid
        }
    }
    
    private func saveMoment() {
        let isShared = true
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var savedPhotoPath: String?
        var savedAudioPath: String?
        
        if selectedType == MomentKind.photo, let photoData {
            let photoFileName = "\(UUID().uuidString).jpg"
            let photoURL = documentsPath.appendingPathComponent(photoFileName)
            try? photoData.write(to: photoURL)
            savedPhotoPath = photoFileName
        }
        
        if selectedType == MomentKind.voice {
            savedAudioPath = audioPath
        }
        
        let moment = Moment(
            author: myName,
            kind: selectedType,
            title: momentTitle.isEmpty ? nil : momentTitle,
            text: selectedType == MomentKind.text ? momentText : nil,
            audioPath: savedAudioPath,
            photoPath: savedPhotoPath,
            isShared: isShared
        )
        
        modelContext.insert(moment)
        
        // ✅ SYNC TO FIREBASE
        Task {
            await firebaseManager.syncMoment(moment)
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFileName = "\(UUID().uuidString).m4a"
            let audioURL = documentsPath.appendingPathComponent(audioFileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            
            audioPath = audioFileName
            isRecording = true
            recordingTime = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                recordingTime += 0.1
                
                if recordingTime >= 20 {
                    stopRecording()
                }
            }
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        hasRecording = true
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func deleteRecording() {
        if let audioPath {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent(audioPath)
            try? FileManager.default.removeItem(at: audioURL)
        }
        
        hasRecording = false
        recordingTime = 0
        self.audioPath = nil
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

struct ElegantTypeButton: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.15) : .white.opacity(0.6))
                        .frame(width: 54, height: 54)
                        .shadow(color: isSelected ? color.opacity(0.2) : .black.opacity(0.02), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? color : .black.opacity(0.4))
                }
                
                Text(label)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? color : .black.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ElegantIconButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.4, green: 0.6, blue: 0.9),
                                Color(red: 0.3, green: 0.5, blue: 0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.blue.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
    }
}
