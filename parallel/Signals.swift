import SwiftData
import Foundation

enum Sentiment: String, Codable, CaseIterable {
    // Positive
    case ecstatic = "Ecstatic"
    case excited = "Excited"
    case happy = "Happy"
    case grateful = "Grateful"
    case peaceful = "Peaceful"
    case content = "Content"
    case hopeful = "Hopeful"
    case playful = "Playful"
    case romantic = "Romantic"
    case horny = "Horny"
    case energized = "Energized"
    
    // Neutral/Mixed
    case okay = "Okay"
    case tired = "Tired"
    case bored = "Bored"
    case restless = "Restless"
    case contemplative = "Contemplative"
    case missing = "Missing You"
    
    // Negative
    case stressed = "Stressed"
    case overwhelmed = "Overwhelmed"
    case anxious = "Anxious"
    case frustrated = "Frustrated"
    case annoyed = "Annoyed"
    case upset = "Upset"
    case sad = "Sad"
    case angry = "Angry"
    case hurt = "Hurt"
    case lonely = "Lonely"
    
    var emoji: String {
        switch self {
        case .ecstatic: return "🤩"
        case .excited: return "😄"
        case .happy: return "😊"
        case .grateful: return "🙏"
        case .peaceful: return "😌"
        case .content: return "☺️"
        case .hopeful: return "✨"
        case .playful: return "😜"
        case .romantic: return "🥰"
        case .horny: return "😏"
        case .energized: return "⚡"
        case .okay: return "😐"
        case .tired: return "😴"
        case .bored: return "🥱"
        case .restless: return "😣"
        case .contemplative: return "🤔"
        case .missing: return "💭"
        case .stressed: return "😰"
        case .overwhelmed: return "😵"
        case .anxious: return "😟"
        case .frustrated: return "😤"
        case .annoyed: return "😒"
        case .upset: return "😔"
        case .sad: return "😢"
        case .angry: return "😡"
        case .hurt: return "💔"
        case .lonely: return "🥺"
        }
    }
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .ecstatic, .excited, .happy, .grateful:
            return (0.9, 0.6, 0.3)
        case .peaceful, .content, .hopeful:
            return (0.5, 0.8, 0.6)
        case .playful, .romantic, .horny:
            return (0.95, 0.4, 0.5)
        case .energized:
            return (0.9, 0.5, 0.3)
        case .okay, .bored, .contemplative:
            return (0.6, 0.6, 0.6)
        case .tired, .restless:
            return (0.5, 0.5, 0.7)
        case .missing:
            return (0.7, 0.5, 0.9)
        case .stressed, .overwhelmed, .anxious:
            return (0.4, 0.6, 0.9)
        case .frustrated, .annoyed, .angry:
            return (0.9, 0.3, 0.3)
        case .upset, .sad, .hurt, .lonely:
            return (0.4, 0.5, 0.8)
        }
    }
}

@Model
final class Signal {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var author: String = ""
    var sentiment: String = Sentiment.okay.rawValue
    var isShared: Bool = true
    
    init(author: String, sentiment: Sentiment, isShared: Bool = true) {
        self.id = UUID()
        self.createdAt = Date()
        self.author = author
        self.sentiment = sentiment.rawValue
        self.isShared = isShared
    }
    
    var sentimentEnum: Sentiment {
        Sentiment(rawValue: sentiment) ?? .okay
    }
}
