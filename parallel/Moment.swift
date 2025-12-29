import SwiftData
import Foundation

@Model
final class Moment {
    var id: UUID
    var createdAt: Date
    var author: String
    var kind: MomentKind
    var title: String?
    var text: String?
    var audioPath: String?
    var photoPath: String?
    var isShared: Bool
    
    init(author: String, kind: MomentKind, title: String? = nil, text: String? = nil, audioPath: String? = nil, photoPath: String? = nil, isShared: Bool) {
        self.id = UUID()
        self.createdAt = Date()
        self.author = author
        self.kind = kind
        self.title = title
        self.text = text
        self.audioPath = audioPath
        self.photoPath = photoPath
        self.isShared = isShared
    }
}

enum MomentKind: String, Codable {
    case text
    case voice
    case photo
}
