import SwiftUI
import SwiftData

struct AddBucketItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let myName: String
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: BucketCategory = .relationship
    @State private var priority: Int = 2
    
    let maxTitleChars = 60
    let maxDescChars = 200
    
    var canSave: Bool {
        !title.isEmpty && title.count <= maxTitleChars && description.count <= maxDescChars
    }
    
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
            
            VStack(spacing: 0) {
                // Header
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
                    VStack(spacing: 24) {
                        // Title field
                        VStack(spacing: 8) {
                            HStack {
                                Text("What's the dream?")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                Spacer()
                                Text("\(title.count)/\(maxTitleChars)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(title.count > maxTitleChars ? .red : .black.opacity(0.3))
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
                        
                        // Description field
                        VStack(spacing: 8) {
                            HStack {
                                Text("Details (optional)")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                Spacer()
                                Text("\(description.count)/\(maxDescChars)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(description.count > maxDescChars ? .red : .black.opacity(0.3))
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("See the Eiffel Tower at sunset...")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.black.opacity(0.25))
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
                        
                        // Category selection
                        VStack(spacing: 12) {
                            HStack {
                                Text("Category")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                Spacer()
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(BucketCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCategory = category
                                        }
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }
                                }
                            }
                        }
                        
                        // Priority selection
                        VStack(spacing: 12) {
                            HStack {
                                Text("Priority")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.black.opacity(0.6))
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                PriorityButton(
                                    label: "Someday",
                                    icon: "circle",
                                    priority: 1,
                                    isSelected: priority == 1
                                ) {
                                    priority = 1
                                }
                                
                                PriorityButton(
                                    label: "Important",
                                    icon: "circle.fill",
                                    priority: 2,
                                    isSelected: priority == 2
                                ) {
                                    priority = 2
                                }
                                
                                PriorityButton(
                                    label: "Must Do!",
                                    icon: "star.fill",
                                    priority: 3,
                                    isSelected: priority == 3
                                ) {
                                    priority = 3
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // Save button
            VStack {
                Spacer()
                
                Button {
                    saveBucketItem()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Add to Bucket List")
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
                .padding(.horizontal, 20)
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
            priority: priority
        )
        
        modelContext.insert(item)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
    }
}

struct CategoryButton: View {
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
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? categoryColor : .white)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .strokeBorder(categoryColor, lineWidth: 2)
                        )
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .white : categoryColor)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? categoryColor : .black.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? categoryColor.opacity(0.1) : .white.opacity(0.5))
            )
        }
    }
}

struct PriorityButton: View {
    let label: String
    let icon: String
    let priority: Int
    let isSelected: Bool
    let action: () -> Void
    
    var color: Color {
        switch priority {
        case 1: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case 2: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case 3: return Color(red: 0.9, green: 0.6, blue: 0.3)
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? color : .black.opacity(0.3))
                
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? color : .black.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.15) : .white.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? color : .clear, lineWidth: 2)
                    )
            )
        }
    }
}
