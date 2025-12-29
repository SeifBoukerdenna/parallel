import SwiftUI

struct PixelCharacter: View {
    let skinColor: Color
    let hairColor: Color
    let shirtColor: Color
    let breathingOffset: CGFloat
    
    let pixelSize: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 0) {
            // Hair
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<8) { _ in
                        pixel(hairColor)
                    }
                }
                HStack(spacing: 0) {
                    pixel(hairColor)
                    ForEach(0..<6) { _ in
                        pixel(.clear)
                    }
                    pixel(hairColor)
                }
            }
            
            // Face
            VStack(spacing: 0) {
                // Forehead
                HStack(spacing: 0) {
                    pixel(hairColor)
                    ForEach(0..<6) { _ in
                        pixel(skinColor)
                    }
                    pixel(hairColor)
                }
                
                // Eyes row
                HStack(spacing: 0) {
                    pixel(hairColor)
                    pixel(skinColor)
                    pixel(.black)
                    pixel(skinColor)
                    pixel(skinColor)
                    pixel(.black)
                    pixel(skinColor)
                    pixel(hairColor)
                }
                
                // Nose row
                HStack(spacing: 0) {
                    pixel(hairColor)
                    ForEach(0..<6) { _ in
                        pixel(skinColor)
                    }
                    pixel(hairColor)
                }
                
                // Mouth row
                HStack(spacing: 0) {
                    pixel(hairColor)
                    pixel(skinColor)
                    pixel(.black)
                    pixel(.black)
                    pixel(.black)
                    pixel(.black)
                    pixel(skinColor)
                    pixel(hairColor)
                }
            }
            
            // Body
            VStack(spacing: 0) {
                // Neck
                HStack(spacing: 0) {
                    ForEach(0..<2) { _ in
                        pixel(.clear)
                    }
                    ForEach(0..<4) { _ in
                        pixel(skinColor)
                    }
                    ForEach(0..<2) { _ in
                        pixel(.clear)
                    }
                }
                
                // Shoulders/Shirt
                ForEach(0..<4) { _ in
                    HStack(spacing: 0) {
                        pixel(.clear)
                        ForEach(0..<6) { _ in
                            pixel(shirtColor)
                        }
                        pixel(.clear)
                    }
                }
            }
        }
        .offset(y: breathingOffset)
    }
    
    func pixel(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: pixelSize, height: pixelSize)
    }
}
