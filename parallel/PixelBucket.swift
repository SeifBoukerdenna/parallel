import SwiftUI

struct PixelBucket: View {
    let pixelSize: CGFloat = 6
    
    var bucketColor: Color {
        Color(red: 0.9, green: 0.5, blue: 0.4)
    }
    
    var handleColor: Color {
        Color(red: 0.7, green: 0.4, blue: 0.3)
    }
    
    var rimColor: Color {
        Color(red: 0.75, green: 0.45, blue: 0.35)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Row 1 - Handle arc
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(handleColor)
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
                pixel(handleColor)
                pixel(.clear)
            }
            
            // Row 2 - Handle sides
            HStack(spacing: 0) {
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
            }
            
            // Row 3 - Rim top
            HStack(spacing: 0) {
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
            }
            
            // Row 4 - Rim bottom & upper body
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(.white.opacity(0.6))
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.8))
                pixel(.white.opacity(0.6))
                pixel(bucketColor)
                pixel(bucketColor)
            }
            
            // Row 5 - Upper body
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor)
                pixel(bucketColor)
            }
            
            // Row 6 - Mid body (slightly narrower)
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.6))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 7 - Lower body (narrower)
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor.opacity(0.7))
                pixel(bucketColor.opacity(0.8))
                pixel(bucketColor)
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 8 - Bottom narrowing
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
            
            // Row 9 - Base
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
                pixel(rimColor)
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
