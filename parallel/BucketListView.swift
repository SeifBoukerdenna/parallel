import SwiftUI
import SwiftData

struct BucketListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Query(sort: \BucketItem.createdAt, order: .reverse) private var bucketItems: [BucketItem]
    
    let myName: String
    let herName: String
    
    @State private var showAddItem = false
    
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
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                    
                    HStack(spacing: 12) {
                        PixelBucket()
                            .scaleEffect(0.7)
                        
                        Text("Bucket List")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.black.opacity(0.6))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                
                if bucketItems.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        PixelBucket()
                            .scaleEffect(1.2)
                            .opacity(0.2)
                        
                        Text("Start dreaming")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.35))
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(bucketItems) { item in
                                SimpleBucketCard(
                                    item: item,
                                    onToggle: {
                                        toggleItem(item)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Button {
                    showAddItem = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("Add Dream")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.5, blue: 0.4),
                                        Color(red: 0.9, green: 0.4, blue: 0.5)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color.pink.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showAddItem) {
            SimplifiedAddBucketItemView(myName: myName)
        }
    }
    
    private func toggleItem(_ item: BucketItem) {
        withAnimation(.spring(response: 0.3)) {
            if item.isCompleted {
                item.uncomplete()
            } else {
                item.complete()
            }
        }
        
        // ✅ SYNC TO FIREBASE
        firebaseManager.syncBucketItem(item)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct SimpleBucketCard: View {
    let item: BucketItem
    let onToggle: () -> Void
    
    var categoryColor: Color {
        Color(red: item.category.color.red,
              green: item.category.color.green,
              blue: item.category.color.blue)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? categoryColor.opacity(0.3) : .white)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .strokeBorder(categoryColor.opacity(0.4), lineWidth: 2)
                        )
                    
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(categoryColor)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(item.isCompleted ? 0.35 : 0.7))
                    .strikethrough(item.isCompleted)
                
                if let description = item.description_bucket, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black.opacity(item.isCompleted ? 0.25 : 0.45))
                        .lineLimit(2)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 9))
                    Text(item.category.rawValue)
                        .font(.system(size: 11, design: .rounded))
                    
                    Text("•")
                    
                    Text(item.addedBy)
                        .font(.system(size: 11, design: .rounded))
                    
                    if item.isCompleted, let completedAt = item.completedAt {
                        Text("•")
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9))
                            Text(completedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 11, design: .rounded))
                        }
                    }
                }
                .foregroundColor(.black.opacity(0.3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(item.isCompleted ? 0.3 : 0.6))
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}

struct SimplifiedAddBucketItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    let myName: String
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: BucketCategory = BucketCategory.relationship
    
    let maxTitleChars = 60
    let maxDescChars = 200
    
    var canSave: Bool {
        !title.isEmpty && title.count <= maxTitleChars && description.count <= maxDescChars
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
                    
                    Text("Add Dream")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            HStack {
                                Text("What's the dream?")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            TextField("Visit Paris together...", text: $title)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.black.opacity(0.7))
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white.opacity(0.7))
                                )
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Details (optional)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("See the Eiffel Tower at sunset...")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.black.opacity(0.3))
                                        .padding(.horizontal, 18)
                                        .padding(.top, 18)
                                }
                                
                                TextEditor(text: $description)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(.black.opacity(0.7))
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(height: 100)
                                    .padding(10)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.7))
                            )
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Category")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.5))
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(BucketCategory.allCases, id: \.self) { category in
                                        SimpleCategoryButton(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                Button {
                    saveBucketItem()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Add to List")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.9, green: 0.5, blue: 0.4),
                                        Color(red: 0.9, green: 0.4, blue: 0.5)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color.pink.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .disabled(!canSave)
                .opacity(canSave ? 1.0 : 0.4)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    private func saveBucketItem() {
        let item = BucketItem(
            title: title,
            description: description.isEmpty ? nil : description,
            addedBy: myName,
            category: selectedCategory,
            priority: 2
        )
        
        modelContext.insert(item)
        
        // ✅ SYNC TO FIREBASE
        firebaseManager.syncBucketItem(item)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}

struct SimpleCategoryButton: View {
    let category: BucketCategory
    let isSelected: Bool
    let action: () -> Void
    
    var categoryColor: Color {
        Color(red: category.color.red,
              green: category.color.green,
              blue: category.color.blue)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .black.opacity(0.5))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? categoryColor : .white.opacity(0.6))
            )
        }
    }
}
