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
            // Row 1 - Handle left
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(handleColor)
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
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
            }
            
            // Row 3 - Bucket rim
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor)
            }
            
            // Row 4 - Upper body
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(.white.opacity(0.5))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.7))
                pixel(.white.opacity(0.5))
                pixel(bucketColor)
            }
            
            // Row 5 - Middle
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.5))
                pixel(bucketColor.opacity(0.5))
                pixel(bucketColor.opacity(0.5))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor)
            }
            
            // Row 6 - Lower narrowing
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 7 - Bottom rim
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
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
