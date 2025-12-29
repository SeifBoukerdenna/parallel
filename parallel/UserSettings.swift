import SwiftData
import Foundation

@Model
final class UserSettings {
    var id: UUID = UUID()
    var userName: String = ""
    var nickname: String? = nil
    var currentPoseIndex: Int = 0
    var updatedAt: Date = Date()
    
    init(userName: String, nickname: String? = nil, currentPoseIndex: Int = 0) {
        self.id = UUID()
        self.userName = userName
        self.nickname = nickname
        self.currentPoseIndex = currentPoseIndex
        self.updatedAt = Date()
    }
    
    func updatePose(to index: Int) {
        self.currentPoseIndex = index
        self.updatedAt = Date()
    }
    
    func updateNickname(to nickname: String?) {
        self.nickname = nickname
        self.updatedAt = Date()
    }
}
