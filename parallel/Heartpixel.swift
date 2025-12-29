import SwiftUI

struct HeartPixel: View {
    let pixelSize: CGFloat = 6
    
    var body: some View {
        VStack(spacing: 0) {
            // Row 1
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.pink)
                pixel(.pink)
                pixel(.clear)
                pixel(.pink)
                pixel(.pink)
                pixel(.clear)
            }
            
            // Row 2
            HStack(spacing: 0) {
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
            }
            
            // Row 3
            HStack(spacing: 0) {
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
            }
            
            // Row 4
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.clear)
            }
            
            // Row 5
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(.pink)
                pixel(.pink)
                pixel(.pink)
                pixel(.clear)
                pixel(.clear)
            }
            
            // Row 6
            HStack(spacing: 0) {
                pixel(.clear)
                pixel(.clear)
                pixel(.clear)
                pixel(.pink)
                pixel(.clear)
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
