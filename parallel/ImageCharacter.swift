import SwiftUI

struct ImageCharacter: View {
    let imageName: String
    let breathingOffset: CGFloat
    let scale: CGFloat
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(height: 240 * scale) // Adjustable scale
            .offset(y: breathingOffset + 20)
    }
}

// Fallback to pixel character if image doesn't exist
struct CharacterView: View {
    let imageName: String?
    let skinColor: Color
    let hairColor: Color
    let shirtColor: Color
    let breathingOffset: CGFloat
    let scale: CGFloat
    
    var body: some View {
        if let imageName = imageName {
            ImageCharacter(imageName: imageName, breathingOffset: breathingOffset, scale: scale)
        } else {
            PixelCharacter(
                skinColor: skinColor,
                hairColor: hairColor,
                shirtColor: shirtColor,
                breathingOffset: breathingOffset
            )
            .scaleEffect(scale)
        }
    }
}

// Character poses configuration
struct CharacterPoses {
    static let alexPoses: [String] = ["malik_8bit", "malik_moody", "malik_happy"] // Add more as needed
    static let mayaPoses: [String] = ["maya_8bit", "maya_love", "maya_moody"] // Add more poses
    
    static func poses(for name: String) -> [String] {
        if name.lowercased().contains("malik") {
            return alexPoses
        } else if name.lowercased().contains("maya") || name.lowercased().contains("sarah") {
            return mayaPoses
        }
        return []
    }
}
