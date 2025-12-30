import SwiftUI
import SwiftData
import AVFoundation

struct MomentTimelineView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Moment.createdAt, order: .reverse) private var moments: [Moment]
    
    let myName: String
    let herName: String
    
    @State private var selectedMoment: Moment?
    @State private var searchText = ""
    @State private var isSearching = false
    
    var sharedMoments: [Moment] {
        moments.filter { $0.isShared }
    }
    
    var filteredMoments: [Moment] {
        if searchText.isEmpty {
            return sharedMoments
        } else {
            return sharedMoments.filter { moment in
                let titleMatch = moment.title?.localizedCaseInsensitiveContains(searchText) ?? false
                let textMatch = moment.text?.localizedCaseInsensitiveContains(searchText) ?? false
                return titleMatch || textMatch
            }
        }
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
                    
                    if !isSearching {
                        Text("Our Moments")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isSearching.toggle()
                            if !isSearching {
                                searchText = ""
                            }
                        }
                    } label: {
                        Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.black.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                if isSearching {
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 14))
                                .foregroundColor(.black.opacity(0.4))
                            
                            TextField("Search moments...", text: $searchText)
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.7))
                        )
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if filteredMoments.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        if searchText.isEmpty {
                            HeartPixel()
                                .scaleEffect(1.5)
                                .opacity(0.3)
                            
                            Text("No shared moments yet")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Text("Create moments and share them together")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.black.opacity(0.3))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        } else {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.black.opacity(0.2))
                            
                            Text("No moments found")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Text("Try a different search")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.black.opacity(0.3))
                        }
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredMoments) { moment in
                                MomentCard(
                                    moment: moment,
                                    isMyMoment: moment.author == myName,
                                    myName: myName,
                                    herName: herName,
                                    searchText: searchText
                                )
                                .onTapGesture {
                                    selectedMoment = moment
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedMoment) { moment in
            MomentDetailView(
                moment: moment,
                accentColor: moment.author == myName ? Color(red: 0.3, green: 0.5, blue: 0.9) : Color(red: 0.9, green: 0.4, blue: 0.5)
            )
        }
    }
}

struct MomentCard: View {
    let moment: Moment
    let isMyMoment: Bool
    let myName: String
    let herName: String
    let searchText: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(isMyMoment ? Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.7) : Color(red: 0.9, green: 0.4, blue: 0.5).opacity(0.7))
                .frame(width: 10, height: 10)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Text(moment.author)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Image(systemName: moment.kind == .photo ? "photo.fill" : moment.kind == .voice ? "mic.fill" : "text.alignleft")
                            .font(.system(size: 10))
                            .foregroundColor(.black.opacity(0.3))
                    }
                    
                    Spacer()
                    
                    Text(moment.createdAt, style: .relative)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.black.opacity(0.35))
                }
                
                if let title = moment.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                }
                
                switch moment.kind {
                case .text:
                    if let text = moment.text {
                        Text(text)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.black.opacity(0.65))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                case .photo:
                    if let photoPath = moment.photoPath {
                        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let photoURL = documentsPath.appendingPathComponent(photoPath)
                        if let imageData = try? Data(contentsOf: photoURL),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                case .voice:
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.15))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "waveform")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                        }
                        
                        HStack(spacing: 4) {
                            ForEach(0..<12) { i in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.4))
                                    .frame(width: 3, height: CGFloat.random(in: 8...24))
                            }
                        }
                        
                        Spacer()
                        
                        Text("Tap to view")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.08))
                    )
                }
                
                if moment.kind != .voice {
                    HStack {
                        Spacer()
                        Text("Tap to view")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                    }
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
    }
}
