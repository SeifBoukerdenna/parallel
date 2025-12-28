import SwiftUI

// Pixel heart
struct HeartPixel: View {
    let pixelSize: CGFloat = 6
    
    var body: some View {
        VStack(spacing: 0) {
            // Top row
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.red)
                pixel(.red)
                pixel(.clear)
                pixel(.red)
                pixel(.red)
                pixel(.clear)
            }
            // Second row
            HStack(spacing: 0) {
                pixel(.red)
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(.red)
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(.red)
            }
            // Third row
            HStack(spacing: 0) {
                pixel(.red)
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(.red)
            }
            // Fourth row
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.red)
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(.red)
                pixel(.clear)
            }
            // Fifth row
            HStack(spacing: 0) {
                ForEach(0..<2) { _ in pixel(.clear) }
                pixel(.red)
                pixel(Color(red: 1, green: 0.4, blue: 0.4))
                pixel(.red)
                ForEach(0..<2) { _ in pixel(.clear) }
            }
            // Bottom
            HStack(spacing: 0) {
                ForEach(0..<3) { _ in pixel(.clear) }
                pixel(.red)
                ForEach(0..<3) { _ in pixel(.clear) }
            }
        }
    }
    
    func pixel(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: pixelSize, height: pixelSize)
    }
}

