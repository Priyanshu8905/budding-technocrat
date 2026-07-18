import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    var onOpenAllCategories: (() -> Void)?
    var onSelectCategory: ((String) -> Void)?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tappable Native Section Header with Functional Chevron
            Button {
                onOpenAllCategories?()
            } label: {
                HStack(spacing: 4) {
                    Text("Shop by category")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: true)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories) { category in
                    Button {
                        onSelectCategory?(category.id)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Theme.cardTileBg)
                                    .frame(height: 76)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                                    )
                                
                                Text(category.icon)
                                    .font(.system(size: 38))
                            }
                            
                            Text(category.shortName)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.textPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.85)
                                .frame(height: 32, alignment: .top)
                        }
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: true)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CategoryGridView(categories: MockCategories.categories)
}
