import SwiftUI
import SwiftData
import AVFoundation

struct CharacterProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]
    @Query(sort: \Signal.createdAt, order: .reverse) private var signals: [Signal]
    
    let characterName: String
    let isMe: Bool
    let myName: String
    let herName: String
    let myCharacterImage: String?
    let herCharacterImage: String?
    let userSettings: UserSettings?
    let modelContext: ModelContext
    
    @State private var selectedMoment: Moment?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var currentPoseIndex = 0
    @State private var showNicknameEditor = false
    @State private var editingNickname = ""
    
    var characterMoments: [Moment] {
        moments.filter { $0.author == characterName }
    }
    
    var filteredCharacterMoments: [Moment] {
        if searchText.isEmpty {
            return characterMoments
        } else {
            return characterMoments.filter { moment in
                let titleMatch = moment.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let textMatch = moment.text?.localizedCaseInsensitiveContains(searchText) ?? false
                return titleMatch || textMatch
            }
        }
    }
    
    var characterSignals: [Signal] {
        signals.filter { $0.author == characterName }
    }
    
    var latestSignal: Signal? {
        characterSignals.first
    }
    
    var backgroundColor: Color {
        isMe ? Color(red: 0.96, green: 0.97, blue: 0.98) : Color(red: 0.98, green: 0.96, blue: 0.97)
    }
    
    var accentColor: Color {
        isMe ? Color(red: 0.3, green: 0.5, blue: 0.9) : Color(red: 0.9, green: 0.4, blue: 0.5)
    }
    
    var availablePoses: [String] {
        let poses = CharacterPoses.poses(for: characterName)
        return poses.isEmpty ? [] : poses
    }
    
    var currentPoseImage: String? {
        if availablePoses.isEmpty {
            return isMe ? myCharacterImage : herCharacterImage
        }
        return availablePoses[currentPoseIndex % availablePoses.count]
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                    
                    if characterMoments.count > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                isSearching.toggle()
                                if !isSearching {
                                    searchText = ""
                                }
                            }
                        } label: {
                            Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                if isSearching {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.4))
                            
                            TextField("Search moments...", text: $searchText)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.7))
                        )
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 12) {
                            VStack(spacing: 4) {
                                Text(characterName.uppercased())
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                if !isMe {
                                    if let nickname = userSettings?.nickname, !nickname.isEmpty {
                                        Button {
                                            editingNickname = nickname
                                            showNicknameEditor = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Text(nickname)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.black.opacity(0.35))
                                                    .italic()
                                                
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.black.opacity(0.25))
                                            }
                                        }
                                    } else {
                                        Button {
                                            editingNickname = ""
                                            showNicknameEditor = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 12))
                                                Text("Add nickname for \(characterName)")
                                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                            }
                                            .foregroundColor(.black.opacity(0.3))
                                        }
                                    }
                                } else {
                                    if let nickname = userSettings?.nickname, !nickname.isEmpty {
                                        Text(nickname)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.black.opacity(0.35))
                                            .italic()
                                    }
                                }
                            }
                            
                            if isMe {
                                CharacterView(
                                    imageName: currentPoseImage,
                                    skinColor: Color(red: 0.95, green: 0.8, blue: 0.7),
                                    hairColor: Color(red: 0.4, green: 0.25, blue: 0.15),
                                    shirtColor: Color(red: 0.2, green: 0.4, blue: 0.8),
                                    breathingOffset: 0,
                                    scale: 0.8
                                )
                            } else {
                                CharacterView(
                                    imageName: currentPoseImage,
                                    skinColor: Color(red: 0.98, green: 0.85, blue: 0.75),
                                    hairColor: Color(red: 0.95, green: 0.8, blue: 0.3),
                                    shirtColor: Color(red: 0.9, green: 0.2, blue: 0.3),
                                    breathingOffset: 0,
                                    scale: 0.8
                                )
                            }
                            
                            if !availablePoses.isEmpty && availablePoses.count > 1 {
                                HStack(spacing: 12) {
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            currentPoseIndex = (currentPoseIndex - 1 + availablePoses.count) % availablePoses.count
                                            updatePersistentPoseIndex()
                                        }
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    } label: {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.6))
                                            .frame(width: 36, height: 36)
                                            .background(
                                                Circle()
                                                    .fill(.white.opacity(0.7))
                                            )
                                    }
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            currentPoseIndex = Int.random(in: 0..<availablePoses.count)
                                            updatePersistentPoseIndex()
                                        }
                                        let impact = UIImpactFeedbackGenerator(style: .medium)
                                        impact.impactOccurred()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "shuffle")
                                                .font(.system(size: 13))
                                            Text("Random Pose")
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        }
                                        .foregroundColor(.black.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.7))
                                        )
                                    }
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            currentPoseIndex = (currentPoseIndex + 1) % availablePoses.count
                                            updatePersistentPoseIndex()
                                        }
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    } label: {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black.opacity(0.6))
                                            .frame(width: 36, height: 36)
                                            .background(
                                                Circle()
                                                    .fill(.white.opacity(0.7))
                                            )
                                    }
                                }
                                .padding(.top, 8)
                                
                                HStack(spacing: 6) {
                                    ForEach(0..<availablePoses.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentPoseIndex ? accentColor : Color.black.opacity(0.2))
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        
                        if let signal = latestSignal {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Latest Signal")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.black.opacity(0.4))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: signal.isShared ? "heart.fill" : "lock.fill")
                                            .font(.system(size: 9))
                                        Text(signal.isShared ? "Shared" : "Private")
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                    }
                                    .foregroundColor(.black.opacity(0.5))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.5))
                                    )
                                }
                                .padding(.horizontal, 24)
                                
                                SentimentBubble(
                                    sentiment: signal.sentimentEnum
                                )
                                .padding(.horizontal, 24)
                                
                                Text(signal.createdAt, style: .relative)
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.black.opacity(0.3))
                            }
                            .padding(.bottom, 12)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Moments (\(characterMoments.count))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                
                                if isSearching && !searchText.isEmpty {
                                    Text("• \(filteredCharacterMoments.count) found")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.black.opacity(0.4))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            if filteredCharacterMoments.isEmpty {
                                VStack(spacing: 12) {
                                    if searchText.isEmpty {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 32))
                                            .foregroundColor(.black.opacity(0.2))
                                        
                                        Text("No moments yet")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.black.opacity(0.3))
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 32))
                                            .foregroundColor(.black.opacity(0.2))
                                        
                                        Text("No moments found")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(.black.opacity(0.3))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredCharacterMoments) { moment in
                                        CharacterMomentCard(
                                            moment: moment,
                                            accentColor: accentColor
                                        )
                                        .onTapGesture {
                                            selectedMoment = moment
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedMoment) { moment in
            MomentDetailView(moment: moment, accentColor: accentColor)
        }
        .sheet(isPresented: $showNicknameEditor) {
            NicknameEditorView(
                characterName: characterName,
                currentNickname: editingNickname,
                onSave: { newNickname in
                    updateNickname(newNickname)
                }
            )
            .presentationDetents([.height(280)])
        }
        .onAppear {
            currentPoseIndex = userSettings?.currentPoseIndex ?? 0
        }
    }
    
    private func updatePersistentPoseIndex() {
        userSettings?.updatePose(to: currentPoseIndex)
        
        if let settings = userSettings {
            firebaseManager.syncUserSettings(settings)
        }
    }
    
    private func updateNickname(_ newNickname: String) {
        let trimmed = newNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        userSettings?.updateNickname(to: trimmed.isEmpty ? nil : trimmed)
        
        if let settings = userSettings {
            firebaseManager.syncUserSettings(settings)
        }
    }
}

struct NicknameEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let characterName: String
    let currentNickname: String
    let onSave: (String) -> Void
    
    @State private var nickname: String
    
    init(characterName: String, currentNickname: String, onSave: @escaping (String) -> Void) {
        self.characterName = characterName
        self.currentNickname = currentNickname
        self.onSave = onSave
        _nickname = State(initialValue: currentNickname)
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
            
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                Text("Nickname for \(characterName)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                
                TextField("Baby, Love, etc...", text: $nickname)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.7))
                    )
                    .padding(.horizontal, 24)
                
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.6))
                            )
                    }
                    
                    Button {
                        onSave(nickname)
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.9, green: 0.5, blue: 0.4))
                            )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct SentimentBubble: View {
    let sentiment: Sentiment
    
    var sentimentColor: Color {
        Color(red: sentiment.color.red,
              green: sentiment.color.green,
              blue: sentiment.color.blue)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(sentiment.emoji)
                .font(.system(size: 32))
            
            Text(sentiment.rawValue)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(sentimentColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(sentimentColor.opacity(0.1))
        )
    }
}

struct CharacterMomentCard: View {
    let moment: Moment
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accentColor.opacity(0.6))
                        .frame(width: 6, height: 6)
                    
                    Text(moment.isShared ? "Shared" : "Private")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.5))
                    
                    Image(systemName: moment.kind == .photo ? "photo.fill" : moment.kind == .voice ? "mic.fill" : "text.alignleft")
                        .font(.system(size: 9))
                        .foregroundColor(.black.opacity(0.3))
                }
                
                Spacer()
                
                Text(moment.createdAt, style: .relative)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.black.opacity(0.35))
            }
            
            if let title = moment.title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.7))
            }
            
            switch moment.kind {
            case .text:
                if let text = moment.text {
                    Text(text)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black.opacity(0.65))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
            case .photo:
                if let photoPath = moment.photoPath {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let photoURL = documentsPath.appendingPathComponent(photoPath)
                    if let imageData = try? Data(contentsOf: photoURL),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
            case .voice:
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "waveform")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                    }
                    
                    HStack(spacing: 3) {
                        ForEach(0..<10) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.4))
                                .frame(width: 2.5, height: CGFloat.random(in: 6...20))
                        }
                    }
                    
                    Spacer()
                    
                    Text("Tap to play")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.08))
                )
            }
            
            HStack {
                Spacer()
                Text("Tap to view")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.6))
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}
