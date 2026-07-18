// ProductCardView.swift
// Component presenting individual product details with add-to-cart controls.

import SwiftUI

struct ProductCardView: View {
    let product: Product
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: Theme.radiusMd)
                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    .frame(height: 120)
                
                Text(categoryEmoji(for: product.category))
                    .font(.system(size: 50))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if product.discountPercent > 0 {
                    Text("\(product.discountPercent)% OFF")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(6)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
                
                Text(product.weight)
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
                
                HStack(alignment: .firstTextBaseline) {
                    Text(product.formattedPrice)
                        .font(.callout.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if product.mrp > product.price {
                        Text(product.formattedMRP)
                            .font(.caption)
                            .strikethrough()
                            .foregroundColor(Theme.textMuted)
                    }
                    
                    Spacer()
                    
                    let qty = cartViewModel.quantity(for: product)
                    if qty > 0 {
                        HStack(spacing: 8) {
                            Button {
                                cartViewModel.updateQuantity(for: product, quantity: qty - 1)
                            } label: {
                                Image(systemName: "minus")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(Theme.primary)
                                    .frame(width: 24, height: 24)
                                    .background(Theme.primaryBg)
                                    .clipShape(Circle())
                            }
                            
                            Text("\(qty)")
                                .font(.caption.weight(.bold))
                            
                            Button {
                                cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                            } label: {
                                Image(systemName: "plus")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Theme.primary)
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        Button {
                            cartViewModel.add(product: product)
                        } label: {
                            Text("ADD")
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Theme.primary)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .padding(6)
        .hyperpureCardStyle()
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

#Preview {
    ProductCardView(product: MockProducts.products[0])
        .environment(CartViewModel.shared)
}
