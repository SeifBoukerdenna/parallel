import SwiftUI
import FirebaseCore
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UserNotifications
import SwiftData

class FirebaseManager: NSObject, ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var fcmToken: String?
    @Published var isAuthenticated = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var currentUserName: String?
    private var modelContext: ModelContext?
    
    private var momentsListener: ListenerRegistration?
    private var signalsListener: ListenerRegistration?
    private var pingsListener: ListenerRegistration?
    private var bucketListener: ListenerRegistration?
    private var settingsListener: ListenerRegistration?
    
    override private init() {
        super.init()
    }
    
    func setup() {
        print("🔥 Setting up FirebaseManager")
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
        
        Messaging.messaging().delegate = self
        
        print("✅ FirebaseManager setup complete")
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("✅ ModelContext set in FirebaseManager")
    }
    
    func authenticateUser(userName: String) async throws {
        self.currentUserName = userName
        
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("✅ Authenticated as: \(result.user.uid)")
            
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = userName
            try await changeRequest.commitChanges()
            
            retryTokenRegistration()
            isAuthenticated = true
            await requestNotificationPermission()
            
            print("✅ User authenticated: \(userName)")
        } catch {
            print("❌ Authentication error: \(error)")
            throw error
        }
    }
    
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            
            if granted {
                print("✅ Notification permission granted")
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Notification permission denied")
            }
        } catch {
            print("❌ Error requesting notification permission: \(error)")
        }
    }
    
    func registerFCMToken(_ token: String) {
        guard let userName = currentUserName else {
            print("⚠️ No user name set, skipping token registration")
            return
        }
        
        self.fcmToken = token
        print("📱 FCM Token: \(token)")
        
        let tokenData: [String: Any] = [
            "userName": userName,
            "token": token,
            "updatedAt": FieldValue.serverTimestamp(),
            "platform": "ios"
        ]
        
        db.collection("fcmTokens").document(userName).setData(tokenData, merge: true) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error)")
            } else {
                print("✅ FCM token saved to Firestore")
            }
        }
    }
    
    // MARK: - Upload to Storage
    
    func uploadPhoto(localPath: String) async throws -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = documentsPath.appendingPathComponent(localPath)
        
        guard let data = try? Data(contentsOf: localURL) else {
            throw NSError(domain: "FirebaseManager", code: -1)
        }
        
        let storageRef = storage.reference().child("photos/\(localPath)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        print("📤 Uploading photo: \(localPath)")
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        print("✅ Photo uploaded: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }
    
    func uploadAudio(localPath: String) async throws -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = documentsPath.appendingPathComponent(localPath)
        
        guard let data = try? Data(contentsOf: localURL) else {
            throw NSError(domain: "FirebaseManager", code: -1)
        }
        
        let storageRef = storage.reference().child("audio/\(localPath)")
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        print("📤 Uploading audio: \(localPath)")
        
        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        
        print("✅ Audio uploaded: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }
    
    // MARK: - Download from Storage
    
    func downloadFile(storageURL: String, localFilename: String) async throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localURL = documentsPath.appendingPathComponent(localFilename)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            print("✅ File already exists: \(localFilename)")
            return
        }
        
        print("📥 Downloading: \(storageURL)")
        
        let storageRef = storage.reference(forURL: storageURL)
        _ = try await storageRef.writeAsync(toFile: localURL)
        
        print("✅ Downloaded: \(localFilename)")
    }
    
    // MARK: - Sync TO Cloud
    
    func syncMoment(_ moment: Moment) async {
        var photoStorageURL: String? = nil
        var audioStorageURL: String? = nil
        
        if let photoPath = moment.photoPath {
            photoStorageURL = try? await uploadPhoto(localPath: photoPath)
        }
        
        if let audioPath = moment.audioPath {
            audioStorageURL = try? await uploadAudio(localPath: audioPath)
        }
        
        let momentData: [String: Any] = [
            "id": moment.id.uuidString,
            "createdAt": Timestamp(date: moment.createdAt),
            "author": moment.author,
            "kind": moment.kind.rawValue,
            "title": moment.title ?? "",
            "text": moment.text ?? "",
            "audioPath": moment.audioPath ?? "",
            "photoPath": moment.photoPath ?? "",
            "audioStorageURL": audioStorageURL ?? "",
            "photoStorageURL": photoStorageURL ?? "",
            "isShared": moment.isShared
        ]
        
        db.collection("moments").document(moment.id.uuidString).setData(momentData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing moment: \(error)")
            } else {
                print("✅ Moment synced to Firestore")
            }
        }
    }
    
    func syncSignal(_ signal: Signal) {
        let signalData: [String: Any] = [
            "id": signal.id.uuidString,
            "createdAt": Timestamp(date: signal.createdAt),
            "author": signal.author,
            "energy": signal.energy,
            "mood": signal.mood,
            "closeness": signal.closeness,
            "isShared": signal.isShared
        ]
        
        db.collection("signals").document(signal.id.uuidString).setData(signalData, merge: true) { error in
            if let error = error {
                print("❌ Error syncing signal: \(error)")
            } else {
                print("✅ Signal synced")
            }
        }
    }
    
    func syncPing(_ ping: Ping) {
        let pingData: [String: Any] = [
            "id": ping.id.uuidString,
            "createdAt": Timestamp(date: ping.createdAt),
            "author": ping.author,
            "message": ping.message,
            "isRead": ping.isRead
        ]
        
        db.collection("pings").document(ping.id.uuidString).setData(pingData, merge: true)
    }
    
    func syncBucketItem(_ item: BucketItem) {
        let itemData: [String: Any] = [
            "id": item.id.uuidString,
            "createdAt": Timestamp(date: item.createdAt),
            "title": item.title,
            "description": item.description_bucket ?? "",
            "isCompleted": item.isCompleted,
            "completedAt": item.completedAt.map { Timestamp(date: $0) } ?? NSNull(),
            "addedBy": item.addedBy,
            "category": item.category.rawValue,
            "priority": item.priority
        ]
        
        db.collection("bucketItems").document(item.id.uuidString).setData(itemData, merge: true)
    }
    
    func syncUserSettings(_ settings: UserSettings) {
        let settingsData: [String: Any] = [
            "id": settings.id.uuidString,
            "userName": settings.userName,
            "nickname": settings.nickname ?? "",
            "currentPoseIndex": settings.currentPoseIndex,
            "updatedAt": Timestamp(date: settings.updatedAt)
        ]
        
        db.collection("userSettings").document(settings.userName).setData(settingsData, merge: true)
    }
    
    // MARK: - Fetch FROM Cloud
    
    private func fetchAndSyncMoments() {
        guard let context = modelContext else { return }
        
        db.collection("moments").getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                guard let idString = data["id"] as? String, let id = UUID(uuidString: idString) else { continue }
                
                let descriptor = FetchDescriptor<Moment>(predicate: #Predicate { $0.id == id })
                let existing = try? context.fetch(descriptor)
                if existing?.isEmpty == false { continue }
                
                let photoPath = (data["photoPath"] as? String)?.isEmpty == false ? data["photoPath"] as? String : nil
                let audioPath = (data["audioPath"] as? String)?.isEmpty == false ? data["audioPath"] as? String : nil
                
                // Download files
                if let photoURL = data["photoStorageURL"] as? String, !photoURL.isEmpty, let filename = photoPath {
                    Task { try? await self?.downloadFile(storageURL: photoURL, localFilename: filename) }
                }
                
                if let audioURL = data["audioStorageURL"] as? String, !audioURL.isEmpty, let filename = audioPath {
                    Task { try? await self?.downloadFile(storageURL: audioURL, localFilename: filename) }
                }
                
                let moment = Moment(
                    author: data["author"] as? String ?? "",
                    kind: MomentKind(rawValue: data["kind"] as? String ?? "text") ?? .text,
                    title: (data["title"] as? String)?.isEmpty == false ? data["title"] as? String : nil,
                    text: (data["text"] as? String)?.isEmpty == false ? data["text"] as? String : nil,
                    audioPath: audioPath,
                    photoPath: photoPath,
                    isShared: data["isShared"] as? Bool ?? false
                )
                moment.id = id
                if let timestamp = data["createdAt"] as? Timestamp {
                    moment.createdAt = timestamp.dateValue()
                }
                
                context.insert(moment)
                print("✅ Synced moment: \(moment.id)")
            }
            
            try? context.save()
        }
    }
    
    private func fetchAndSyncSignals() {
        guard let context = modelContext else { return }
        
        db.collection("signals").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                guard let idString = data["id"] as? String, let id = UUID(uuidString: idString) else { continue }
                
                let descriptor = FetchDescriptor<Signal>(predicate: #Predicate { $0.id == id })
                let existing = try? context.fetch(descriptor)
                if existing?.isEmpty == false { continue }
                
                let signal = Signal(
                    author: data["author"] as? String ?? "",
                    energy: data["energy"] as? Double ?? 50,
                    mood: data["mood"] as? Double ?? 0,
                    closeness: data["closeness"] as? Double ?? 50,
                    isShared: data["isShared"] as? Bool ?? false
                )
                signal.id = id
                if let timestamp = data["createdAt"] as? Timestamp {
                    signal.createdAt = timestamp.dateValue()
                }
                
                context.insert(signal)
            }
            
            try? context.save()
        }
    }
    
    private func fetchAndSyncPings() {
        guard let context = modelContext else { return }
        
        db.collection("pings").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                guard let idString = data["id"] as? String, let id = UUID(uuidString: idString) else { continue }
                
                let descriptor = FetchDescriptor<Ping>(predicate: #Predicate { $0.id == id })
                let existing = try? context.fetch(descriptor)
                if existing?.isEmpty == false { continue }
                
                let ping = Ping(
                    author: data["author"] as? String ?? "",
                    message: data["message"] as? String ?? ""
                )
                ping.id = id
                ping.isRead = data["isRead"] as? Bool ?? false
                if let timestamp = data["createdAt"] as? Timestamp {
                    ping.createdAt = timestamp.dateValue()
                }
                
                context.insert(ping)
            }
            
            try? context.save()
        }
    }
    
    private func fetchAndSyncBucketItems() {
        guard let context = modelContext else { return }
        
        db.collection("bucketItems").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                guard let idString = data["id"] as? String, let id = UUID(uuidString: idString) else { continue }
                
                let descriptor = FetchDescriptor<BucketItem>(predicate: #Predicate { $0.id == id })
                let existing = try? context.fetch(descriptor)
                if existing?.isEmpty == false { continue }
                
                let item = BucketItem(
                    title: data["title"] as? String ?? "",
                    description: (data["description"] as? String)?.isEmpty == false ? data["description"] as? String : nil,
                    addedBy: data["addedBy"] as? String ?? "",
                    category: BucketCategory(rawValue: data["category"] as? String ?? "other") ?? .other,
                    priority: data["priority"] as? Int ?? 2
                )
                item.id = id
                item.isCompleted = data["isCompleted"] as? Bool ?? false
                if let timestamp = data["createdAt"] as? Timestamp {
                    item.createdAt = timestamp.dateValue()
                }
                if let completedTimestamp = data["completedAt"] as? Timestamp {
                    item.completedAt = completedTimestamp.dateValue()
                }
                
                context.insert(item)
            }
            
            try? context.save()
        }
    }
    
    private func fetchAndSyncUserSettings() {
        guard let context = modelContext else { return }
        
        db.collection("userSettings").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            for doc in documents {
                let data = doc.data()
                let userName = data["userName"] as? String ?? ""
                
                let descriptor = FetchDescriptor<UserSettings>(predicate: #Predicate { $0.userName == userName })
                
                let existing = try? context.fetch(descriptor)
                if let existingSettings = existing?.first {
                    existingSettings.nickname = (data["nickname"] as? String)?.isEmpty == false ? data["nickname"] as? String : nil
                    existingSettings.currentPoseIndex = data["currentPoseIndex"] as? Int ?? 0
                    if let timestamp = data["updatedAt"] as? Timestamp {
                        existingSettings.updatedAt = timestamp.dateValue()
                    }
                } else {
                    let settings = UserSettings(
                        userName: userName,
                        nickname: (data["nickname"] as? String)?.isEmpty == false ? data["nickname"] as? String : nil,
                        currentPoseIndex: data["currentPoseIndex"] as? Int ?? 0
                    )
                    if let idString = data["id"] as? String, let id = UUID(uuidString: idString) {
                        settings.id = id
                    }
                    if let timestamp = data["updatedAt"] as? Timestamp {
                        settings.updatedAt = timestamp.dateValue()
                    }
                    context.insert(settings)
                }
            }
            
            try? context.save()
        }
    }
    
    // MARK: - Listeners
    
    func startListening(onUpdate: @escaping () -> Void) {
        guard isAuthenticated else { return }
        
        print("📥 Fetching initial data...")
        fetchAndSyncMoments()
        fetchAndSyncSignals()
        fetchAndSyncPings()
        fetchAndSyncBucketItems()
        fetchAndSyncUserSettings()
        
        momentsListener = db.collection("moments").addSnapshotListener { [weak self] snapshot, error in
            snapshot?.documentChanges.forEach { change in
                if change.type == .added || change.type == .modified {
                    self?.fetchAndSyncMoments()
                    onUpdate()
                }
            }
        }
        
        signalsListener = db.collection("signals").addSnapshotListener { [weak self] snapshot, error in
            snapshot?.documentChanges.forEach { _ in
                self?.fetchAndSyncSignals()
                onUpdate()
            }
        }
        
        pingsListener = db.collection("pings").addSnapshotListener { [weak self] snapshot, error in
            snapshot?.documentChanges.forEach { _ in
                self?.fetchAndSyncPings()
                onUpdate()
            }
        }
        
        bucketListener = db.collection("bucketItems").addSnapshotListener { [weak self] snapshot, error in
            snapshot?.documentChanges.forEach { _ in
                self?.fetchAndSyncBucketItems()
                onUpdate()
            }
        }
        
        settingsListener = db.collection("userSettings").addSnapshotListener { [weak self] snapshot, error in
            snapshot?.documentChanges.forEach { _ in
                self?.fetchAndSyncUserSettings()
                onUpdate()
            }
        }
        
        print("✅ Listeners started")
    }
    
    func stopListening() {
        momentsListener?.remove()
        signalsListener?.remove()
        pingsListener?.remove()
        bucketListener?.remove()
        settingsListener?.remove()
    }
    
    private func retryTokenRegistration() {
        guard let token = fcmToken, let userName = currentUserName else { return }
        DispatchQueue.main.async { self.registerFCMToken(token) }
    }
}

extension FirebaseManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        print("📱 FCM Token: \(token)")
        print("🔑 ===================================")
        print("🔑 COPY THIS FOR TESTING:")
        print("🔑 \(token)")
        print("🔑 ===================================")
        
        registerFCMToken(token)
    }
}
