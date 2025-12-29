import SwiftData
import Foundation

@Model
final class Signal {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var author: String = ""
    var energy: Double = 50.0
    var mood: Double = 0.0
    var closeness: Double = 50.0
    var isShared: Bool = true
    
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
