import SwiftUI

struct FeaturedProductsView: View {
    let products: [Product]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Best Sellers")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("View All")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.primary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(products) { product in
                        ProductCardView(product: product)
                            .frame(width: 170)
                    }
                }
            }
        }
    }
}
