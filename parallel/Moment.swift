import SwiftData
import Foundation

@Model
final class Moment {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var author: String = ""
    var kind: MomentKind = MomentKind.text
    var title: String? = nil
    var text: String? = nil
    var audioPath: String? = nil
    var photoPath: String? = nil
    var isShared: Bool = false
    
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
