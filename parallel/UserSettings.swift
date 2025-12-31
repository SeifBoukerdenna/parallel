import SwiftData
import Foundation

@Model
final class UserSettings {
    var id: UUID = UUID()
    var userName: String = ""
    var nickname: String? = nil
    var currentPoseIndex: Int = 0
    var pronounSubject: String = "they" // they/she/he
    var pronounObject: String = "them" // them/her/him
    var pronounPossessive: String = "their" // their/her/his
    var pronounContraction: String = "they're" // they're/she's/he's
    var updatedAt: Date = Date()
    
    init(userName: String, nickname: String? = nil, currentPoseIndex: Int = 0) {
        self.id = UUID()
        self.userName = userName
        self.nickname = nickname
        self.currentPoseIndex = currentPoseIndex
        self.updatedAt = Date()
        
        // Default pronouns based on name
        if userName.lowercased().contains("malik") {
            self.pronounSubject = "he"
            self.pronounObject = "him"
            self.pronounPossessive = "his"
            self.pronounContraction = "he's"
        } else if userName.lowercased().contains("maya") {
            self.pronounSubject = "she"
            self.pronounObject = "her"
            self.pronounPossessive = "her"
            self.pronounContraction = "she's"
        } else {
            self.pronounSubject = "they"
            self.pronounObject = "them"
            self.pronounPossessive = "their"
            self.pronounContraction = "they're"
        }
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
