import SwiftData
import Foundation

@Model
final class Signal {
    var id: UUID
    var createdAt: Date
    var author: String
    var energy: Double // 0-100
    var mood: Double // -50 to +50
    var closeness: Double // 0-100
    var isShared: Bool = true // Default to shared for backward compatibility
    
    init(author: String, energy: Double, mood: Double, closeness: Double, isShared: Bool = true) {
        self.id = UUID()
        self.createdAt = Date()
        self.author = author
        self.energy = energy
        self.mood = mood
        self.closeness = closeness
        self.isShared = isShared
    }
}
