import SwiftUI
import SwiftData

struct BucketListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BucketItem.createdAt, order: .reverse) private var bucketItems: [BucketItem]
    
    let myName: String
    let herName: String
    
    @State private var showAddItem = false
    @State private var filterCompleted = false
    @State private var selectedCategory: BucketCategory? = nil
    
    var filteredItems: [BucketItem] {
        bucketItems.filter { item in
            let completedFilter = filterCompleted ? item.isCompleted : !item.isCompleted
            let categoryFilter = selectedCategory == nil || item.category == selectedCategory
            return completedFilter && categoryFilter
        }
    }
    
    var completedCount: Int {
        bucketItems.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.98, green: 0.95, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                VStack(spacing: 12) {
                    // Handle bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "bucket")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0.9, green: 0.5, blue: 0.4))
                                
                                Text("Our Bucket List")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            
                            Text("\(bucketItems.count) dreams • \(completedCount) completed")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.black.opacity(0.2))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)
                
                // Filter tabs
                HStack(spacing: 8) {
                    FilterTab(
                        title: "To Do",
                        isSelected: !filterCompleted,
                        count: bucketItems.filter { !$0.isCompleted }.count
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            filterCompleted = false
                        }
                    }
                    
                    FilterTab(
                        title: "Done",
                        isSelected: filterCompleted,
                        count: completedCount
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            filterCompleted = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryPill(
                            category: nil,
                            isSelected: selectedCategory == nil
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedCategory = nil
                            }
                        }
                        
                        ForEach(BucketCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)
                
                // Items list
                if filteredItems.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: filterCompleted ? "checkmark.circle" : "bucket")
                            .font(.system(size: 60))
                            .foregroundColor(.black.opacity(0.15))
                        
                        Text(filterCompleted ? "No completed dreams yet" : "Start your bucket list!")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.black.opacity(0.4))
                        
                        Text(filterCompleted ? "Complete some items to see them here" : "Add your first dream together")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black.opacity(0.3))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredItems) { item in
                                BucketItemCard(
                                    item: item,
                                    myName: myName,
                                    herName: herName,
                                    onToggle: {
                                        toggleItem(item)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                Spacer()
            }
            
            // Add button
            VStack {
                Spacer()
                
                Button {
                    showAddItem = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        Text("Add Dream")
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
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddBucketItemView(myName: myName)
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
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                
                Text("\(count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? .white.opacity(0.3) : .black.opacity(0.1))
                    )
            }
            .foregroundColor(isSelected ? .white : .black.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.black.opacity(0.7) : .white.opacity(0.5))
            )
        }
    }
}

struct CategoryPill: View {
    let category: BucketCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category?.icon ?? "square.grid.2x2")
                    .font(.system(size: 12))
                
                Text(category?.rawValue ?? "All")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .black.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.black.opacity(0.7) : .white.opacity(0.6))
            )
        }
    }
}

struct BucketItemCard: View {
    let item: BucketItem
    let myName: String
    let herName: String
    let onToggle: () -> Void
    
    var categoryColor: Color {
        Color(red: item.category.color.red,
              green: item.category.color.green,
              blue: item.category.color.blue)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? categoryColor : .white)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .strokeBorder(categoryColor, lineWidth: 2)
                        )
                    
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 11))
                        .foregroundColor(categoryColor)
                    
                    Text(item.category.rawValue)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(categoryColor)
                    
                    Spacer()
                    
                    if item.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text(item.completedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                .font(.system(size: 10, design: .rounded))
                        }
                        .foregroundColor(.black.opacity(0.3))
                    }
                }
                
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(item.isCompleted ? 0.4 : 0.8))
                    .strikethrough(item.isCompleted)
                
                if let description = item.description_bucket, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.black.opacity(item.isCompleted ? 0.3 : 0.5))
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.system(size: 9))
                    Text("Added by \(item.addedBy)")
                        .font(.system(size: 11, design: .rounded))
                    
                    if item.priority == 3 {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.orange)
                    }
                }
                .foregroundColor(.black.opacity(0.3))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(item.isCompleted ? 0.4 : 0.7))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}
