import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var breathingOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Split background
                HStack(spacing: 0) {
                    Color(red: 0.6, green: 0.85, blue: 0.95) // Light blue
                    Color(red: 0.3, green: 0.5, blue: 0.8)   // Darker blue
                }
                .ignoresSafeArea()
                
                // Center chain/zipper
                VStack(spacing: 8) {
                    ForEach(0..<15) { i in
                        Rectangle()
                            .fill(.black.opacity(0.6))
                            .frame(width: 4, height: 12)
                    }
                }
                
                // Characters
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        Text("YOU")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                        
                        PixelCharacter(
                            skinColor: Color(red: 0.95, green: 0.8, blue: 0.7),
                            hairColor: Color(red: 0.4, green: 0.25, blue: 0.15),
                            shirtColor: Color(red: 0.2, green: 0.4, blue: 0.8),
                            breathingOffset: breathingOffset
                        )
                        .padding(.top, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Spacer()
                        Text("HER")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
                        
                        PixelCharacter(
                            skinColor: Color(red: 0.98, green: 0.85, blue: 0.75),
                            hairColor: Color(red: 0.95, green: 0.8, blue: 0.3),
                            shirtColor: Color(red: 0.9, green: 0.2, blue: 0.3),
                            breathingOffset: breathingOffset
                        )
                        .padding(.top, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Heart in center
                HeartPixel()
                    .offset(y: -geometry.size.height * 0.15 + breathingOffset * 2)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                breathingOffset = -5
            }
        }
    }
}



#Preview {
    ContentView()
}
