import SwiftUI

struct OnboardingView: View {
    @Binding var selectedName: String?
    
    let myName = "Malik"
    let herName = "Maya"
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.96, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Heart pixel art
                HeartPixel()
                    .scaleEffect(2.0)
                
                VStack(spacing: 12) {
                    Text("Welcome to Parallel")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("Two lives. Sometimes touching.")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black.opacity(0.4))
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Who are you?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                    
                    VStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedName = myName
                            }
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        } label: {
                            Text(myName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.3, green: 0.5, blue: 0.9),
                                                    Color(red: 0.2, green: 0.4, blue: 0.85)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedName = herName
                            }
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                        } label: {
                            Text(herName)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.9, green: 0.4, blue: 0.5),
                                                    Color(red: 0.9, green: 0.3, blue: 0.45)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .shadow(color: Color.pink.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Text("This choice determines whose phone this is")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.black.opacity(0.3))
                    .padding(.bottom, 40)
            }
        }
    }
}
