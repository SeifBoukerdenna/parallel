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
                pixel(handleColor)
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(handleColor)
                pixel(handleColor)
                pixel(.clear)
            }
            
            // Row 2 - Handle top
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
            
            // Row 3 - Bucket top rim
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
            
            // Row 4 - Bucket upper body
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(bucketColor)
            }
            
            // Row 5 - Bucket middle
            HStack(spacing: 0) {
                pixel(bucketColor)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(bucketColor)
            }
            
            // Row 6 - Bucket lower middle
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 7 - Bucket lower body
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(bucketColor)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(.white)
                pixel(bucketColor)
                pixel(.clear)
            }
            
            // Row 8 - Bucket bottom
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
