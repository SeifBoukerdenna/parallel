import SwiftUI
import SwiftData

struct SignalTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Signal.createdAt, order: .reverse) private var signals: [Signal]
    
    let myName: String
    let herName: String
    
    @State private var selectedFilter: SignalFilter = .all
    
    enum SignalFilter: String, CaseIterable {
        case all = "All"
        case mine = "Mine"
        case theirs = "Theirs"
    }
    
    var filteredSignals: [Signal] {
        switch selectedFilter {
        case .all:
            return signals
        case .mine:
            return signals.filter { $0.author == myName }
        case .theirs:
            return signals.filter { $0.author == herName }
        }
    }
    
    var groupedSignals: [(String, [Signal])] {
        let grouped = Dictionary(grouping: filteredSignals) { signal in
            Calendar.current.startOfDay(for: signal.createdAt)
        }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { (dateString(from: $0.key), $0.value.sorted { $0.createdAt > $1.createdAt }) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.99),
                    Color(red: 0.96, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Signal Timeline")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    ForEach(SignalFilter.allCases, id: \.self) { filter in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedFilter = filter
                            }
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        } label: {
                            Text(filter.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedFilter == filter ? .white : .black.opacity(0.5))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == filter ? Color.black.opacity(0.7) : .white.opacity(0.5))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                if filteredSignals.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 64))
                            .foregroundColor(.black.opacity(0.2))
                        
                        Text("No signals yet")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.4))
                        
                        Text("Share how you're feeling")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(groupedSignals, id: \.0) { date, signalsForDate in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(date)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.black.opacity(0.4))
                                        .textCase(.uppercase)
                                        .padding(.horizontal, 24)
                                    
                                    ForEach(signalsForDate) { signal in
                                        SignalCard(
                                            signal: signal,
                                            isMySignal: signal.author == myName,
                                            myName: myName,
                                            herName: herName
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    private func dateString(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

struct SignalCard: View {
    let signal: Signal
    let isMySignal: Bool
    let myName: String
    let herName: String
    
    var accentColor: Color {
        isMySignal ? Color(red: 0.3, green: 0.5, blue: 0.9) : Color(red: 0.9, green: 0.4, blue: 0.5)
    }
    
    var moodEmoji: String {
        if signal.mood > 30 {
            return "🤩"
        } else if signal.mood > 10 {
            return "😄"
        } else if signal.mood > -10 {
            return "😊"
        } else if signal.mood > -30 {
            return "😐"
        } else {
            return "😔"
        }
    }
    
    var moodColor: Color {
        if signal.mood < -20 {
            return Color(red: 0.4, green: 0.6, blue: 0.9)
        } else if signal.mood < 0 {
            return Color(red: 0.5, green: 0.7, blue: 0.85)
        } else if signal.mood < 20 {
            return Color(red: 0.5, green: 0.8, blue: 0.6)
        } else {
            return Color(red: 0.7, green: 0.5, blue: 0.9)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 2)
            }
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(signal.author)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Text(signal.createdAt, style: .time)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.black.opacity(0.35))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(moodEmoji)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(moodLabel)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(moodColor)
                            
                            Text("\(Int(signal.mood))")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(moodColor.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(moodColor.opacity(0.12))
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.7))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 20)
    }
    
    var moodLabel: String {
        if signal.mood < -30 {
            return "Low"
        } else if signal.mood < -10 {
            return "Meh"
        } else if signal.mood < 10 {
            return "Okay"
        } else if signal.mood < 30 {
            return "Good"
        } else {
            return "Great"
        }
    }
}
