import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Large Image Card
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: Theme.radiusLg)
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                        .frame(height: 220)
                    
                    Text(categoryEmoji(for: product.category))
                        .font(.system(size: 90))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if product.discountPercent > 0 {
                        Text("\(product.discountPercent)% OFF")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Theme.offer)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(product.weight)
                        .font(.subheadline)
                        .foregroundColor(Theme.textMuted)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(product.formattedPrice)
                            .font(.title.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        if product.mrp > product.price {
                            Text(product.formattedMRP)
                                .font(.headline)
                                .strikethrough()
                                .foregroundColor(Theme.textMuted)
                            
                            Text("You save ₹\(product.mrp - product.price)")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.successLight)
                                .foregroundColor(Theme.success)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Add To Cart Action
                    let qty = cartViewModel.quantity(for: product)
                    HStack {
                        if qty > 0 {
                            HStack(spacing: 20) {
                                Button {
                                    cartViewModel.updateQuantity(for: product, quantity: qty - 1)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.headline.weight(.bold))
                                        .foregroundColor(Theme.primary)
                                        .frame(width: 40, height: 40)
                                        .background(Theme.primaryBg)
                                        .clipShape(Circle())
                                }
                                
                                Text("\(qty)")
                                    .font(.title3.weight(.bold))
                                
                                Button {
                                    cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.headline.weight(.bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Theme.primary)
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Button {
                                cartViewModel.add(product: product)
                            } label: {
                                HStack {
                                    Image(systemName: "cart.badge.plus")
                                    Text("Add to Cart")
                                }
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.primary)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Product Description")
                            .font(.headline.weight(.bold))
                            .padding(.top, 8)
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: MockProducts.products[0])
            .environment(CartViewModel())
    }
}
