import SwiftUI

struct PixelBucket: View {
    let pixelSize: CGFloat = 6
    
    var bucketColor: Color {
        Color(red: 0.9, green: 0.5, blue: 0.4)
    }
    
    var handleColor: Color {
        Color(red: 0.7, green: 0.4, blue: 0.3)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Row 1 - Handle left curve
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
                pixel(.clear)
            }
            
            // Row 2 - Handle arc
            HStack(spacing: 0) {
                pixel(handleColor)
                pixel(.clear)
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
                pixel(.clear)
                pixel(handleColor)
            }
            
            // Row 3 - Handle connection to rim
            HStack(spacing: 0) {
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
                pixel(handleColor)
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
            }
            
            // Row 4 - Bucket top rim
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
            }
            
            // Row 5 - Bucket upper body with highlight
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(.white)
                pixel(.white)
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.8))
                pixel(.white)
                pixel(.white)
                pixel(bucketColor)
            }
            
            // Row 6 - Bucket middle
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(.white)
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.8))
                pixel(.white)
                pixel(bucketColor)
            }
            
            // Row 7 - Bucket lower body narrowing
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(.white)
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.7))
                pixel(.white)
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 8 - Bucket lower narrowing
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.9))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.9))
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 9 - Bucket bottom rim
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(.clear)
                pixel(.clear)
            }
        }
    }
    
    func pixel(_ color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: pixelSize, height: pixelSize)
    }
}
