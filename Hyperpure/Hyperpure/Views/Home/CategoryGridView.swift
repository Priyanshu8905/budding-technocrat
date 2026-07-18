import SwiftUI

struct CategoryGridView: View {
    let categories: [Category]
    var onSelectCategory: ((String) -> Void)?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shop by category")
                .font(.title2.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(categories) { category in
                    Button {
                        onSelectCategory?(category.id)
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: Theme.radiusLg)
                                    .fill(Theme.cardTileBg)
                                    .frame(height: 76)
                                
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
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CategoryGridView(categories: MockCategories.categories)
}
