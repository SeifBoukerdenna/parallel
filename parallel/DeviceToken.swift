import SwiftData
import Foundation

@Model
final class DeviceToken {
    var id: UUID = UUID()
    var userName: String = ""
    var token: String = ""
    var updatedAt: Date = Date()
    
    init(userName: String, token: String) {
        self.id = UUID()
        self.userName = userName
        self.token = token
        self.updatedAt = Date()
    }
    
    func updateToken(_ newToken: String) {
        self.token = newToken
        self.updatedAt = Date()
    }
}
