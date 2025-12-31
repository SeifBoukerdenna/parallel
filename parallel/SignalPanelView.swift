import SwiftUI
import SwiftData

struct SignalPanelView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query(sort: \Signal.createdAt, order: .reverse) private var allSignals: [Signal]
    
    let myName: String
    
    @State private var selectedSentiment: Sentiment = .okay
    @State private var searchText = ""
    
    let sentimentCategories: [(String, [Sentiment])] = [
        ("Positive", [.ecstatic, .excited, .happy, .grateful, .peaceful, .content, .hopeful, .playful, .romantic, .horny, .energized]),
        ("Neutral", [.okay, .tired, .bored, .restless, .contemplative, .missing]),
        ("Struggling", [.stressed, .overwhelmed, .anxious, .frustrated, .annoyed, .upset, .sad, .angry, .hurt, .lonely])
    ]
    
    var filteredSentiments: [Sentiment] {
        if searchText.isEmpty {
            return Sentiment.allCases
        } else {
            return Sentiment.allCases.filter {
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var myLatestSignal: Signal? {
        allSignals.first(where: { $0.author == myName })
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.15))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                HStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Spacer()
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.3))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Search bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.4))
                    
                    TextField("Search feelings...", text: $searchText)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.6))
                )
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Selected sentiment display
                VStack(spacing: 12) {
                    Text(selectedSentiment.emoji)
                        .font(.system(size: 72))
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.3), value: selectedSentiment)
                    
                    Text(selectedSentiment.rawValue)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(
                            red: selectedSentiment.color.red,
                            green: selectedSentiment.color.green,
                            blue: selectedSentiment.color.blue
                        ))
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Sentiment grid
                ScrollView {
                    if searchText.isEmpty {
                        VStack(spacing: 24) {
                            ForEach(sentimentCategories, id: \.0) { category, sentiments in
                                VStack(spacing: 12) {
                                    HStack {
                                        Text(category)
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.black.opacity(0.4))
                                            .textCase(.uppercase)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 24)
                                    
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 10) {
                                        ForEach(sentiments, id: \.self) { sentiment in
                                            SentimentButton(
                                                sentiment: sentiment,
                                                isSelected: selectedSentiment == sentiment
                                            ) {
                                                withAnimation(.spring(response: 0.3)) {
                                                    selectedSentiment = sentiment
                                                }
                                                let impact = UIImpactFeedbackGenerator(style: .light)
                                                impact.impactOccurred()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(filteredSentiments, id: \.self) { sentiment in
                                SentimentButton(
                                    sentiment: sentiment,
                                    isSelected: selectedSentiment == sentiment
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedSentiment = sentiment
                                    }
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }
            }
            
            VStack {
                Spacer()
                
                Button {
                    saveSignal()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text("Share with us")
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(
                                            red: selectedSentiment.color.red,
                                            green: selectedSentiment.color.green,
                                            blue: selectedSentiment.color.blue
                                        ),
                                        Color(
                                            red: selectedSentiment.color.red * 0.9,
                                            green: selectedSentiment.color.green * 0.9,
                                            blue: selectedSentiment.color.blue * 0.9
                                        )
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(
                        color: Color(
                            red: selectedSentiment.color.red,
                            green: selectedSentiment.color.green,
                            blue: selectedSentiment.color.blue
                        ).opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            if let latest = myLatestSignal {
                selectedSentiment = latest.sentimentEnum
            }
        }
    }
    
    private func saveSignal() {
        let signal = Signal(
            author: myName,
            sentiment: selectedSentiment,
            isShared: true
        )
        
        modelContext.insert(signal)
        
        firebaseManager.syncSignal(signal)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}

struct SentimentButton: View {
    let sentiment: Sentiment
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(sentiment.emoji)
                    .font(.system(size: 32))
                
                Text(sentiment.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(
                        red: sentiment.color.red,
                        green: sentiment.color.green,
                        blue: sentiment.color.blue
                    ) : .black.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(
                        red: sentiment.color.red,
                        green: sentiment.color.green,
                        blue: sentiment.color.blue
                    ).opacity(0.15) : .white.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isSelected ? Color(
                                    red: sentiment.color.red,
                                    green: sentiment.color.green,
                                    blue: sentiment.color.blue
                                ) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}
