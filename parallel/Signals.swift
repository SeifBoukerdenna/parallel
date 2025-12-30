import SwiftData
import Foundation

@Model
final class Signal {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var author: String = ""
    var mood: Double = 0.0 // -50 to +50 scale
    var isShared: Bool = true
    
    init(author: String, mood: Double, isShared: Bool = true) {
        self.id = UUID()
        self.createdAt = Date()
        self.author = author
        self.mood = mood
        self.isShared = isShared
    }
}
