import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct AddMomentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let myName: String
    
    @State private var selectedType: MomentKind = .text
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
                    
                    Text("New Moment")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                // Title field (always visible)
                VStack(spacing: 6) {
                    HStack {
                        Text("Title (optional)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                        Spacer()
                        Text("\(momentTitle.count)/\(maxTitleChars)")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(momentTitle.count > maxTitleChars ? Color(red: 0.9, green: 0.3, blue: 0.3) : .black.opacity(0.3))
                    }
                    
                    TextField("Add a short title...", text: $momentTitle)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.6))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Type selector
                HStack(spacing: 12) {
                    TypeButton(
                        icon: "text.alignleft",
                        label: "Text",
                        isSelected: selectedType == .text
                    ) {
                        selectedType = .text
                    }
                    
                    TypeButton(
                        icon: "photo",
                        label: "Photo",
                        isSelected: selectedType == .photo
                    ) {
                        selectedType = .photo
                    }
                    
                    TypeButton(
                        icon: "mic.fill",
                        label: "Voice",
                        isSelected: selectedType == .voice
                    ) {
                        selectedType = .voice
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Content area
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
                .padding(.top, 16)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        saveMoment(isShared: true)
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
                    .disabled(!canSave)
                    .opacity(canSave ? 1.0 : 0.4)
                    
                    Button {
                        saveMoment(isShared: false)
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
                    .disabled(!canSave)
                    .opacity(canSave ? 1.0 : 0.4)
                }
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
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("\(momentText.count)/\(maxChars)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(momentText.count > maxChars ? Color(red: 0.9, green: 0.3, blue: 0.3) : .black.opacity(0.3))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            ZStack(alignment: .topLeading) {
                if momentText.isEmpty {
                    Text("What's on your mind?")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.black.opacity(0.25))
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                }
                
                TextEditor(text: $momentText)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(height: 180)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
        }
    }
    
    var photoInputView: some View {
        VStack(spacing: 16) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                VStack(spacing: 12) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    
                    HStack(spacing: 12) {
                        Button {
                            showCamera = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "camera")
                                Text("Camera")
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.7))
                            )
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 6) {
                                Image(systemName: "photo")
                                Text("Gallery")
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.7))
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 64))
                        .foregroundColor(.black.opacity(0.2))
                    
                    HStack(spacing: 12) {
                        Button {
                            showCamera = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text("Camera")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
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
                            )
                            .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                Text("Gallery")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
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
                            )
                            .shadow(color: Color.blue.opacity(0.2), radius: 6, x: 0, y: 3)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                                .foregroundColor(.black.opacity(0.1))
                        )
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    var voiceInputView: some View {
        VStack(spacing: 24) {
            if hasRecording {
                VStack(spacing: 16) {
                    Image(systemName: "waveform")
                        .font(.system(size: 64))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    
                    Text(formatTime(recordingTime))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .monospacedDigit()
                    
                    Text("Recording saved")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                    
                    Button {
                        deleteRecording()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text("Delete & Re-record")
                        }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.red.opacity(0.7))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.7))
                        )
                    }
                }
            } else if isRecording {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 3)
                                    .scaleEffect(1.3)
                                    .opacity(0.8)
                            )
                    }
                    
                    Text(formatTime(recordingTime))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                        .monospacedDigit()
                    
                    Text("Recording...")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                    
                    Button {
                        stopRecording()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                            Text("Stop Recording")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 28)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red)
                        )
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.7))
                    
                    Text("Tap to record")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.5))
                    
                    Button {
                        startRecording()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                            Text("Start Recording")
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 28)
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
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.4))
        )
        .padding(.horizontal, 20)
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
    
    private func saveMoment(isShared: Bool) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var savedPhotoPath: String?
        var savedAudioPath: String?
        
        // Save photo if needed
        if selectedType == .photo, let photoData {
            let photoFileName = "\(UUID().uuidString).jpg"
            let photoURL = documentsPath.appendingPathComponent(photoFileName)
            try? photoData.write(to: photoURL)
            savedPhotoPath = photoFileName
        }
        
        // Audio path already set if voice
        if selectedType == .voice {
            savedAudioPath = audioPath
        }
        
        let moment = Moment(
            author: myName,
            kind: selectedType,
            title: momentTitle.isEmpty ? nil : momentTitle,
            text: selectedType == .text ? momentText : nil,
            audioPath: savedAudioPath,
            photoPath: savedPhotoPath,
            isShared: isShared
        )
        
        modelContext.insert(moment)
        
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
                
                // Max 20 seconds
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

struct TypeButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .black.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.black.opacity(0.75) : .white.opacity(0.5))
                    .shadow(color: .black.opacity(isSelected ? 0.1 : 0.03), radius: 6, x: 0, y: 3)
            )
        }
    }
}
