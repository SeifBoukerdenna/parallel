import SwiftUI

struct PixelButton: View {
    let pixelSize: CGFloat = 6
    
    var body: some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(softPink)
                pixel(softPink)
                pixel(softPink)
                pixel(.clear)
                pixel(.clear)
            }
            
            // Row 2
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(softPink)
                pixel(softPink)
                pixel(.white)
                pixel(softPink)
                pixel(softPink)
                pixel(.clear)
            }
            
            // Row 3
            HStack(spacing: 0) {
                pixel(softPink)
                pixel(softPink)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(softPink)
                pixel(softPink)
            }
            
            // Row 4
            HStack(spacing: 0) {
                pixel(softPink)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(softPink)
            }
            
            // Row 5
            HStack(spacing: 0) {
                pixel(softPink)
                pixel(softPink)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(softPink)
                pixel(softPink)
            }
            
            // Row 6
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(softPink)
                pixel(softPink)
                pixel(.white)
                pixel(softPink)
                pixel(softPink)
                pixel(.clear)
            }
            
            // Row 7
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(softPink)
                pixel(softPink)
                pixel(softPink)
                pixel(.clear)
                pixel(.clear)
            }
        }
    }
    
    var softPink: Color {
        Color(red: 0.95, green: 0.6, blue: 0.65)
    }
    
    func pixel(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: pixelSize, height: pixelSize)
    }
}
