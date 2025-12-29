import SwiftData
import Foundation

@Model
final class BucketItem {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var title: String = ""
    var description_bucket: String? = nil
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var addedBy: String = ""
    var category: BucketCategory = BucketCategory.relationship
    var priority: Int = 2
    
    init(title: String, description: String? = nil, addedBy: String, category: BucketCategory, priority: Int = 2) {
        self.id = UUID()
        self.createdAt = Date()
        self.title = title
        self.description_bucket = description
        self.isCompleted = false
        self.completedAt = nil
        self.addedBy = addedBy
        self.category = category
        self.priority = priority
    }
    
    func complete() {
        isCompleted = true
        completedAt = Date()
    }
    
    func uncomplete() {
        isCompleted = false
        completedAt = nil
    }
}

enum BucketCategory: String, Codable, CaseIterable {
    case travel = "Travel"
    case adventure = "Adventure"
    case food = "Food"
    case learning = "Learning"
    case creative = "Creative"
    case fitness = "Fitness"
    case relationship = "Together"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .travel: return "airplane"
        case .adventure: return "mountain.2"
        case .food: return "fork.knife"
        case .learning: return "book"
        case .creative: return "paintbrush"
        case .fitness: return "figure.run"
        case .relationship: return "heart.circle"
        case .other: return "star"
        }
    }
    
    var color: (red: Double, green: Double, blue: Double) {
        switch self {
        case .travel: return (0.3, 0.5, 0.9)
        case .adventure: return (0.9, 0.5, 0.3)
        case .food: return (0.9, 0.3, 0.5)
        case .learning: return (0.6, 0.4, 0.9)
        case .creative: return (0.9, 0.6, 0.3)
        case .fitness: return (0.3, 0.8, 0.5)
        case .relationship: return (0.95, 0.4, 0.5)
        case .other: return (0.5, 0.5, 0.5)
        }
    }
}
