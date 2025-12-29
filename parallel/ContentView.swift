import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]
    @Query(sort: \Signal.createdAt, order: .reverse) private var signals: [Signal]
    @Query private var userSettings: [UserSettings]
    
    // Store which user this phone belongs to
    @AppStorage("currentUserName") private var currentUserName: String?
    
    @State private var breathingOffset: CGFloat = 0
    @State private var showAddMoment = false
    @State private var showSignalPanel = false
    @State private var showBucketList = false
    @State private var showTimeline = false
    @State private var showChevronHint = true
    @State private var showBucketHint = true
    @State private var selectedCharacter: String?
    @State private var isPlayingPreview = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var buttonPressed = false
    
    // The two names in the relationship
    let malikName = "Malik"
    let mayaName = "Maya"
    
    // CUSTOM CHARACTER IMAGES
    let malikCharacterImage: String? = "malik_8bit"
    let mayaCharacterImage: String? = "maya_8bit"
    
    // Which name is "me" and which is "them"
    var myName: String {
        currentUserName ?? malikName
    }
    
    var herName: String {
        if myName == malikName {
            return mayaName
        } else {
            return malikName
        }
    }
    
    // Get character images based on who I am
    var myCharacterImage: String? {
        myName == malikName ? malikCharacterImage : mayaCharacterImage
    }
    
    var herCharacterImage: String? {
        herName == malikName ? malikCharacterImage : mayaCharacterImage
    }
    
    // Get user settings from database (synced via CloudKit)
    var mySettings: UserSettings? {
        userSettings.first(where: { $0.userName == myName })
    }
    
    var herSettings: UserSettings? {
        userSettings.first(where: { $0.userName == herName })
    }
    
    var myLatestSignal: Signal? {
        signals.first(where: { $0.author == myName && isToday($0.createdAt) })
    }
    
    var herLatestSignal: Signal? {
        signals.first(where: { $0.author == herName && isToday($0.createdAt) })
    }
    
    var averageCloseness: Double {
        let myCloseness = myLatestSignal?.closeness ?? 50
        let herCloseness = herLatestSignal?.closeness ?? 50
        return (myCloseness + herCloseness) / 2
    }
    
    var latestSharedMoment: Moment? {
        moments.first(where: { $0.isShared })
    }
    
    var myHasActivity: Bool {
        moments.contains(where: { $0.author == myName && isToday($0.createdAt) }) ||
        myLatestSignal != nil
    }
    
    var herHasActivity: Bool {
        moments.contains(where: { $0.author == herName && isToday($0.createdAt) }) ||
        herLatestSignal != nil
    }
    
    // Get available poses
    var myAvailablePoses: [String] {
        let poses = CharacterPoses.poses(for: myName)
        return poses.isEmpty ? [] : poses
    }
    
    var herAvailablePoses: [String] {
        let poses = CharacterPoses.poses(for: herName)
        return poses.isEmpty ? [] : poses
    }
    
    // Get current pose images based on synced settings
    var currentMyPoseImage: String? {
        if myAvailablePoses.isEmpty {
            return myCharacterImage
        }
        let index = mySettings?.currentPoseIndex ?? 0
        return myAvailablePoses[index % myAvailablePoses.count]
    }
    
    var currentHerPoseImage: String? {
        if herAvailablePoses.isEmpty {
            return herCharacterImage
        }
        let index = herSettings?.currentPoseIndex ?? 0
        return herAvailablePoses[index % herAvailablePoses.count]
    }
    
    var body: some View {
        Group {
            if currentUserName == nil {
                // Show onboarding if user hasn't selected their name
                OnboardingView(selectedName: $currentUserName)
            } else {
                // Show main app
                mainAppView
            }
        }
    }
    
    var mainAppView: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                HStack(spacing: 0) {
                    Color(red: 0.96, green: 0.97, blue: 0.98)
                    Color(red: 0.98, green: 0.96, blue: 0.97)
                }
                .ignoresSafeArea()
                
                // Center line
                Rectangle()
                    .fill(.black.opacity(0.08))
                    .frame(width: 1.5)
                
                // Main content
                VStack {
                    // Pixel bucket at top with hint
                    VStack(spacing: 8) {
                        if showBucketHint {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.2))
                                .transition(.opacity)
                        }
                        
                        Button {
                            showBucketList = true
                            showBucketHint = false
                        } label: {
                            PixelBucket()
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // Heart with closeness indicator
                    VStack(spacing: 8) {
                        HeartPixel()
                            .scaleEffect(heartScale)
                            .opacity(heartOpacity)
                            .shadow(color: .pink.opacity(heartGlow), radius: 20)
                            .offset(y: breathingOffset * 2)
                        
                        // Swipe hint
                        if showChevronHint {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.2))
                                .transition(.opacity)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Characters with names and nicknames
                    HStack(spacing: 0) {
                        VStack {
                            VStack(spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(myName.uppercased())
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.black.opacity(0.5))
                                    
                                    Circle()
                                        .fill(myHasActivity ? Color.blue.opacity(0.6) : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                                
                                // Nickname below name
                                if let nickname = mySettings?.nickname, !nickname.isEmpty {
                                    Text(nickname)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.35))
                                        .italic()
                                }
                            }
                            
                            CharacterView(
                                imageName: currentMyPoseImage,
                                skinColor: Color(red: 0.95, green: 0.8, blue: 0.7),
                                hairColor: Color(red: 0.4, green: 0.25, blue: 0.15),
                                shirtColor: Color(red: 0.2, green: 0.4, blue: 0.8),
                                breathingOffset: breathingOffset,
                                scale: 1.0
                            )
                            .padding(.top, 16)
                            .onTapGesture {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                selectedCharacter = myName
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            VStack(spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(herName.uppercased())
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.black.opacity(0.5))
                                    
                                    Circle()
                                        .fill(herHasActivity ? Color.pink.opacity(0.6) : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                                
                                // Nickname below name
                                if let nickname = herSettings?.nickname, !nickname.isEmpty {
                                    Text(nickname)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.35))
                                        .italic()
                                }
                            }
                            
                            CharacterView(
                                imageName: currentHerPoseImage,
                                skinColor: Color(red: 0.98, green: 0.85, blue: 0.75),
                                hairColor: Color(red: 0.95, green: 0.8, blue: 0.3),
                                shirtColor: Color(red: 0.9, green: 0.2, blue: 0.3),
                                breathingOffset: breathingOffset,
                                scale: 1.0
                            )
                            .padding(.top, 16)
                            .onTapGesture {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                selectedCharacter = herName
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    // Latest shared moment preview
                    if let moment = latestSharedMoment {
                        momentPreviewView(moment: moment)
                            .onTapGesture {
                                showTimeline = true
                            }
                    }
                    
                    Spacer()
                    
                    // Micro-copy
                    Text("Two lives. Sometimes touching.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.black.opacity(0.25))
                        .padding(.bottom, 12)
                    
                    // Simplified pixel art button
                    PixelButton()
                        .scaleEffect(buttonPressed ? 0.9 : 1.0)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                buttonPressed = true
                            }
                            
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    buttonPressed = false
                                }
                                showAddMoment = true
                            }
                        }
                    .padding(.bottom, 40)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        // Swipe up for signals
                        if value.translation.height < -50 {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            showSignalPanel = true
                            showChevronHint = false
                        }
                        // Swipe down for bucket list
                        else if value.translation.height > 50 {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            showBucketList = true
                            showBucketHint = false
                        }
                    }
            )
        }
        .sheet(isPresented: $showAddMoment) {
            AddMomentView(myName: myName)
        }
        .sheet(isPresented: $showSignalPanel) {
            SignalPanelView(myName: myName)
                .presentationDetents([.height(480)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showBucketList) {
            BucketListView(myName: myName, herName: herName)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTimeline) {
            MomentTimelineView(myName: myName, herName: herName)
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterProfileView(
                characterName: character,
                isMe: character == myName,
                myName: myName,
                herName: herName,
                myCharacterImage: myCharacterImage,
                herCharacterImage: herCharacterImage,
                userSettings: character == myName ? mySettings : herSettings,
                modelContext: modelContext
            )
        }
        .onAppear {
            // Initialize user settings if they don't exist
            initializeUserSettings()
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                breathingOffset = -5
            }
            
            // Chevron hint animation (swipe up)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                showChevronHint = true
            }
            
            // Bucket hint animation (swipe down)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(1.5)) {
                showBucketHint = true
            }
            
            Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    showChevronHint.toggle()
                }
            }
            
            Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 1).delay(1)) {
                    showBucketHint.toggle()
                }
            }
        }
    }
    
    private func initializeUserSettings() {
        // Create user settings for both users if they don't exist
        if userSettings.first(where: { $0.userName == malikName }) == nil {
            let settings = UserSettings(userName: malikName)
            modelContext.insert(settings)
        }
        
        if userSettings.first(where: { $0.userName == mayaName }) == nil {
            let settings = UserSettings(userName: mayaName)
            modelContext.insert(settings)
        }
    }
    
    @ViewBuilder
    private func momentPreviewView(moment: Moment) -> some View {
        VStack(spacing: 8) {
            switch moment.kind {
            case .text:
                if let title = moment.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.5))
                }
                
                Text(moment.text ?? "")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("— \(moment.author)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
                
            case .photo:
                if let photoPath = moment.photoPath {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let photoURL = documentsPath.appendingPathComponent(photoPath)
                    if let imageData = try? Data(contentsOf: photoURL),
                       let uiImage = UIImage(data: imageData) {
                        VStack(spacing: 6) {
                            if let title = moment.title, !title.isEmpty {
                                Text(title)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 9))
                                Text("— \(moment.author)")
                            }
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                        }
                    }
                }
                
            case .voice:
                VStack(spacing: 6) {
                    if let title = moment.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                    }
                    
                    Button {
                        togglePreviewPlayback(moment: moment)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isPlayingPreview ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                            
                            HStack(spacing: 2) {
                                ForEach(0..<8) { _ in
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.5))
                                        .frame(width: 2.5, height: CGFloat.random(in: 6...16))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.1))
                        )
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.system(size: 9))
                        Text("— \(moment.author)")
                    }
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
                }
            }
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.4))
        )
        .padding(.horizontal, 24)
    }
    
    private func togglePreviewPlayback(moment: Moment) {
        guard let audioPath = moment.audioPath else { return }
        
        if isPlayingPreview {
            audioPlayer?.stop()
            isPlayingPreview = false
        } else {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioURL = documentsPath.appendingPathComponent(audioPath)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.play()
                isPlayingPreview = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                    isPlayingPreview = false
                }
            } catch {
                print("Failed to play audio: \(error)")
            }
        }
    }
    
    var heartScale: CGFloat {
        let bothHaveSignals = myLatestSignal != nil && herLatestSignal != nil
        if bothHaveSignals {
            return 1.0 + (averageCloseness / 500)
        }
        return 0.85
    }
    
    var heartOpacity: Double {
        let bothHaveSignals = myLatestSignal != nil && herLatestSignal != nil
        return bothHaveSignals ? 1.0 : 0.5
    }
    
    var heartGlow: Double {
        let bothHaveSignals = myLatestSignal != nil && herLatestSignal != nil
        return bothHaveSignals ? (averageCloseness / 100) * 0.6 : 0.0
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}

extension String: Identifiable {
    public var id: String { self }
}
