import SwiftData
import Foundation

@Model
final class Ping {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var author: String = ""
    var message: String = ""
    var isRead: Bool = false
    
    init(author: String, message: String) {
        self.id = UUID()
        self.createdAt = Date()
        self.author = author
        self.message = message
        self.isRead = false
    }
    
    func markAsRead() {
        self.isRead = true
    }
}
