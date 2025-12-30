import SwiftUI
import SwiftData
import AVFoundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]
    @Query(sort: \Signal.createdAt, order: .reverse) private var signals: [Signal]
    @Query(sort: \Ping.createdAt, order: .reverse) private var pings: [Ping]
    @Query private var userSettings: [UserSettings]
    
    @AppStorage("currentUserName") private var currentUserName: String?
    
    @State private var showDebugView = false
    @State private var breathingOffset: CGFloat = 0
    @State private var showAddMoment = false
    @State private var showSignalPanel = false
    @State private var showBucketList = false
    @State private var showTimeline = false
    @State private var showSignalTimeline = false
    @State private var showChevronHint = true
    @State private var showBucketHint = true
    @State private var selectedCharacter: String?
    @State private var isPlayingPreview = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var buttonPressed = false
    @State private var showDeviceToken = false
    @State private var showAddPing = false
    
    let malikName = "Malik"
    let mayaName = "Maya"
    
    let malikCharacterImage: String? = "malik_8bit"
    let mayaCharacterImage: String? = "maya_8bit"
    
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
    
    var myCharacterImage: String? {
        myName == malikName ? malikCharacterImage : mayaCharacterImage
    }
    
    var herCharacterImage: String? {
        herName == malikName ? malikCharacterImage : mayaCharacterImage
    }
    
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
    
    var myAvailablePoses: [String] {
        let poses = CharacterPoses.poses(for: myName)
        return poses.isEmpty ? [] : poses
    }
    
    var herAvailablePoses: [String] {
        let poses = CharacterPoses.poses(for: herName)
        return poses.isEmpty ? [] : poses
    }
    
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
    
    var myLatestPing: Ping? {
        pings.first(where: { $0.author == myName && !$0.isRead })
    }
    
    var herLatestPing: Ping? {
        pings.first(where: { $0.author == herName && !$0.isRead })
    }
    
    var body: some View {
        Group {
            if currentUserName == nil {
                OnboardingView(selectedName: $currentUserName)
            } else if !firebaseManager.isAuthenticated {
                // ✅ LOADING VIEW - Wait for Firebase authentication
                loadingView
                    .task {
                        await authenticateWithFirebase()
                    }
            } else {
                mainAppView
            }
        }
        .onChange(of: firebaseManager.fcmToken) { oldValue, newValue in
            if let token = newValue {
                print("🔑 ===================================")
                print("🔑 FCM TOKEN FOR TESTING:")
                print("🔑 \(token)")
                print("🔑 ===================================")
            }
        }
    }
    
    // ✅ LOADING VIEW
    var loadingView: some View {
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
            
            VStack(spacing: 20) {
                HeartPixel()
                    .scaleEffect(1.5)
                
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(.top, 20)
                
                Text("Connecting...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
    }
    
    // ✅ FIREBASE AUTHENTICATION
    private func authenticateWithFirebase() async {
        guard let userName = currentUserName else { return }
        
        do {
            try await firebaseManager.authenticateUser(userName: userName)
            
            // Start listening for real-time updates
            firebaseManager.startListening {
                print("🔄 Data updated from Firestore")
            }
            
            print("✅ Firebase authentication complete for: \(userName)")
        } catch {
            print("❌ Firebase authentication failed: \(error)")
        }
    }
    
    var mainAppView: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    Color(red: 0.96, green: 0.97, blue: 0.98)
                    Color(red: 0.98, green: 0.96, blue: 0.97)
                }
                .ignoresSafeArea()
                
                Rectangle()
                    .fill(.black.opacity(0.08))
                    .frame(width: 1.5)
                
                VStack {
                    // Top bar
                    HStack {
                        Spacer()
                        
                        Button {
                            showTimeline = true
                        } label: {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.5))
                                )
                        }
                        
                        Button {
                            showSignalTimeline = true
                        } label: {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.5))
                                )
                        }
                        
                        Button {
                            showDeviceToken = true
                        } label: {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.5))
                                )
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                        
                        Button {
                            showDebugView = true
                        } label: {
                            Image(systemName: "ladybug")
                                .font(.system(size: 16))
                                .foregroundColor(.red.opacity(0.5))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(.white.opacity(0.5))
                                )
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                    
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
                    
                    VStack(spacing: 8) {
                        HeartPixel()
                            .scaleEffect(heartScale)
                            .opacity(heartOpacity)
                            .shadow(color: .pink.opacity(heartGlow), radius: 20)
                            .offset(y: breathingOffset * 2)
                        
                        if showChevronHint {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.2))
                                .transition(.opacity)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Characters with PERSISTENT speech bubbles
                    HStack(spacing: 0) {
                        // My character with bubble
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
                                
                                if let nickname = mySettings?.nickname, !nickname.isEmpty {
                                    Text(nickname)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.35))
                                        .italic()
                                }
                            }
                            
                            ZStack(alignment: .top) {
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
                                .onLongPressGesture(minimumDuration: 0.5) {
                                    let impact = UIImpactFeedbackGenerator(style: .medium)
                                    impact.impactOccurred()
                                    showAddPing = true
                                }
                                
                                if let ping = myLatestPing {
                                    ComicSpeechBubble(
                                        message: ping.message,
                                        isMyMessage: true
                                    ) {
                                        dismissPing(ping)
                                    }
                                    .padding(.bottom, 240)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Her character with bubble
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
                                
                                if let nickname = herSettings?.nickname, !nickname.isEmpty {
                                    Text(nickname)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.35))
                                        .italic()
                                }
                            }
                            
                            ZStack(alignment: .top) {
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
                                
                                if let ping = herLatestPing {
                                    ComicSpeechBubble(
                                        message: ping.message,
                                        isMyMessage: false
                                    ) {
                                        dismissPing(ping)
                                    }
                                    .padding(.bottom, 240)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    
                    if let moment = latestSharedMoment {
                        momentPreviewView(moment: moment)
                            .onTapGesture {
                                showTimeline = true
                            }
                    }
                    
                    Spacer()
                    
                    Text("Two lives. Sometimes touching.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.black.opacity(0.25))
                        .padding(.bottom, 12)
                    
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
                        if value.translation.height < -50 {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            showSignalPanel = true
                            showChevronHint = false
                        }
                        else if value.translation.height > 50 {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            showBucketList = true
                            showBucketHint = false
                        }
                    }
            )
        }
        .sheet(isPresented: $showDebugView) {
            DebugView()
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
        .sheet(isPresented: $showSignalTimeline) {
            SignalTimelineView(myName: myName, herName: herName)
        }
        .sheet(isPresented: $showAddPing) {
            AddPingView(myName: myName)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
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
            initializeUserSettings()
            
            firebaseManager.setModelContext(modelContext)
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                breathingOffset = -5
            }
            
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                showChevronHint = true
            }
            
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
        if userSettings.first(where: { $0.userName == malikName }) == nil {
            let settings = UserSettings(userName: malikName)
            modelContext.insert(settings)
        }
        
        if userSettings.first(where: { $0.userName == mayaName }) == nil {
            let settings = UserSettings(userName: mayaName)
            modelContext.insert(settings)
        }
    }
    
    private func dismissPing(_ ping: Ping) {
        withAnimation(.spring(response: 0.3)) {
            ping.markAsRead()
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
