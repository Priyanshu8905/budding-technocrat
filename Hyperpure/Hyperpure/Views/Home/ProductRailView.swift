import SwiftUI

struct ProductRailView: View {
    let categoryName: String
    let categorySubtitle: String
    let products: [Product]
    var onSeeAll: (() -> Void)?
    var onSelectProduct: ((Product) -> Void)?
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tappable Native Section Header with Functional Chevron
            Button {
                onSeeAll?()
            } label: {
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(categoryName)
                                .font(.title3.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            Image(systemName: "chevron.right")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(categorySubtitle)
                            .font(.caption)
                            .foregroundColor(Theme.textMuted)
                    }
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: true)
            .padding(.horizontal, 16)
            
            // Horizontal Glass Product Rail
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(products) { product in
                        ProductCardRailItem(product: product) {
                            onSelectProduct?(product)
                        }
                        .frame(width: 168)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

struct ProductCardRailItem: View {
    let product: Product
    var onSelect: (() -> Void)?
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Clean Glass Image Container (Zero overlap with ADD button)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.85))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.regularMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.9), Color.gray.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 0) {
                    HStack {
                        if let customBadge = product.customBadge {
                            Text(customBadge)
                                .font(.system(size: 7.5).weight(.bold))
                                .foregroundColor(Color(red: 90/255, green: 70/255, blue: 180/255))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3.5)
                                .background(Color(red: 238/255, green: 236/255, blue: 254/255).opacity(0.9))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color(red: 90/255, green: 70/255, blue: 180/255).opacity(0.2), lineWidth: 0.5)
                                )
                        } else if let recentCount = product.recentBuyersCount {
                            Text("\(recentCount)+ RECENT BUYERS")
                                .font(.system(size: 7.5).weight(.bold))
                                .foregroundColor(Color(red: 90/255, green: 70/255, blue: 180/255))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3.5)
                                .background(Color(red: 238/255, green: 236/255, blue: 254/255).opacity(0.9))
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if product.isAd == true {
                            Text("Ad")
                                .font(.system(size: 8).weight(.bold))
                                .foregroundColor(Theme.textMuted)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        }
                    }
                    .padding(6)
                    
                    Spacer(minLength: 0)
                    
                    Text(MockCategories.categories.first(where: { $0.id == product.category })?.icon ?? "📦")
                        .font(.system(size: 54))
                    
                    Spacer(minLength: 0)
                }
            }
            .frame(height: 125)
            
            // Weight / Pack Info
            HStack(spacing: 4) {
                Text(product.weight)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2.5)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                
                if let pack = product.packInfo {
                    Text(pack)
                        .font(.system(size: 9).weight(.bold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2.5)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
            .frame(height: 20, alignment: .leading)
            
            // Title
            Text(product.name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 36, alignment: .topLeading)
            
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
            .frame(height: 14, alignment: .leading)
            
            // Price & ADD Button Row
            HStack(alignment: .bottom) {
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
                    
                    if let bestRate = product.bestRateText {
                        Text(bestRate)
                            .font(.system(size: 9.5).weight(.semibold))
                            .foregroundColor(Theme.bestRateBlue)
                    }
                }
                .frame(height: 50, alignment: .bottomLeading)
                
                Spacer()
                
                // ADD / Stepper Button
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
                        .sensoryFeedback(.impact(weight: .light), trigger: qty)
                        
                        Text("\(qty)")
                            .font(.caption.weight(.bold))
                        
                        Button {
                            cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                        } label: {
                            Image(systemName: "plus")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(Theme.primary)
                        }
                        .sensoryFeedback(.impact(weight: .light), trigger: qty)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.regularMaterial)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1.5)
                } else {
                    Button {
                        cartViewModel.add(product: product)
                    } label: {
                        HStack(spacing: 3) {
                            Text("ADD")
                                .font(.caption2.weight(.black))
                            Image(systemName: "plus")
                                .font(.system(size: 9).weight(.black))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .background(Color.white.opacity(0.95))
                        .foregroundColor(Theme.primary)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Theme.primary.opacity(0.4), lineWidth: 1.2)
                        )
                        .shadow(color: Theme.primary.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    .sensoryFeedback(.impact(weight: .medium), trigger: qty)
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
