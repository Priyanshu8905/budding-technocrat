import SwiftUI

struct ProductRailView: View {
    let categoryName: String
    let categorySubtitle: String
    let products: [Product]
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.radiusSm)
                            .fill(Theme.cardTileBg)
                            .frame(width: 40, height: 40)
                        Text(categoryEmoji(for: products.first?.category ?? ""))
                            .font(.title2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(categoryName)
                            .font(.headline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        Text(categorySubtitle)
                            .font(.caption)
                            .foregroundColor(Theme.textMuted)
                    }
                }
                
                Spacer()
                
                Button {
                    // See all action
                } label: {
                    Text("See all")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Theme.textLinkPink)
                }
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(products) { product in
                        ProductCardRailItem(product: product)
                            .frame(width: 165)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

struct ProductCardRailItem: View {
    let product: Product
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Card Top Badges & Image Area
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: Theme.radiusMd)
                    .fill(Color.white)
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.radiusMd)
                            .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                    )
                
                VStack(spacing: 2) {
                    HStack {
                        if let customBadge = product.customBadge {
                            Text(customBadge)
                                .font(.system(size: 7).weight(.bold))
                                .foregroundColor(Color(red: 90/255, green: 70/255, blue: 180/255))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(red: 238/255, green: 236/255, blue: 254/255))
                                .clipShape(Capsule())
                        } else if let recentCount = product.recentBuyersCount {
                            Text("\(recentCount)+ RECENT BUYERS")
                                .font(.system(size: 7).weight(.bold))
                                .foregroundColor(Color(red: 90/255, green: 70/255, blue: 180/255))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(red: 238/255, green: 236/255, blue: 254/255))
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if product.isAd == true {
                            Text("Ad")
                                .font(.system(size: 8).weight(.bold))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    .padding(6)
                    
                    Text(MockCategories.categories.first(where: { $0.id == product.category })?.icon ?? "📦")
                        .font(.system(size: 55))
                        .padding(.top, 4)
                }
                
                // ADD Button Floating in bottom-right of image
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        let qty = cartViewModel.quantity(for: product)
                        if qty > 0 {
                            HStack(spacing: 6) {
                                Button {
                                    cartViewModel.updateQuantity(for: product, quantity: qty - 1)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(Theme.primary)
                                }
                                Text("\(qty)")
                                    .font(.caption.weight(.bold))
                                Button {
                                    cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                            .padding(6)
                        } else {
                            VStack(spacing: 1) {
                                Button {
                                    cartViewModel.add(product: product)
                                } label: {
                                    HStack(spacing: 2) {
                                        Text("ADD")
                                            .font(.caption2.weight(.bold))
                                        Image(systemName: "plus")
                                            .font(.system(size: 9).weight(.bold))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white)
                                    .foregroundColor(Theme.primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Theme.primary.opacity(0.4), lineWidth: 1)
                                    )
                                }
                                
                                if let minQty = product.minQtyText {
                                    Text(minQty)
                                        .font(.system(size: 7))
                                        .foregroundColor(Theme.textMuted)
                                }
                            }
                            .padding(6)
                        }
                    }
                }
            }
            
            // Weight / Pack Badge
            HStack(spacing: 4) {
                Text(product.weight)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                if let pack = product.packInfo {
                    Text(pack)
                        .font(.system(size: 9).weight(.bold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            // Title
            Text(product.name)
                .font(.caption.weight(.medium))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 32, alignment: .topLeading)
            
            // Rating
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color.green)
                Text(String(format: "%.1f", product.rating))
                    .font(.caption2.weight(.bold))
                if let reviews = product.reviewCount {
                    Text("(\(reviews))")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
            }
            
            // Price & Best Rate
            VStack(alignment: .leading, spacing: 2) {
                if product.discountPercent > 0 {
                    Text("\(product.discountPercent)% OFF MRP")
                        .font(.system(size: 9).weight(.bold))
                        .foregroundColor(Theme.bestRateBlue)
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.formattedPrice)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if product.mrp > product.price {
                        Text(product.formattedMRP)
                            .font(.caption2)
                            .strikethrough()
                            .foregroundColor(Theme.textMuted)
                    }
                }
                
                if let unitSub = product.unitSubtext {
                    Text(unitSub)
                        .font(.system(size: 9))
                        .foregroundColor(Theme.textMuted)
                }
                
                if let bestRate = product.bestRateText {
                    Text(bestRate)
                        .font(.system(size: 10).weight(.semibold))
                        .foregroundColor(Theme.bestRateBlue)
                }
            }
        }
    }
}

#Preview {
    ProductRailView(
        categoryName: "Chicken & Eggs",
        categorySubtitle: "sourced locally",
        products: MockProducts.products.filter { $0.category == "chicken-eggs" }
    )
    .environment(CartViewModel())
}
