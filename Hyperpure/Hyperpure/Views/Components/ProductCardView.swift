// ProductCardView.swift
// Component presenting individual product details with add-to-cart controls.

import SwiftUI

struct ProductCardView: View {
    let product: Product
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                        .frame(height: 120)
                    
                    Text(categoryEmoji(for: product.category))
                        .font(.system(size: 50))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    if product.discountPercent > 0 {
                        Text("\(product.discountPercent)% OFF")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.primary)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding(6)
                    }
                }
                
                Button {
                    MyListViewModel.shared.toggleFavorite(product)
                } label: {
                    Image(systemName: MyListViewModel.shared.isFavorite(product) ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MyListViewModel.shared.isFavorite(product) ? .red : .gray.opacity(0.7))
                        .padding(6)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding(6)
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(2)
                
                Text(product.weight)
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 3) {
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
                    }
                    
                    Spacer(minLength: 4)
                    
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
                        .padding(.vertical, 5)
                        .background(.regularMaterial)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                        )
                        .fixedSize()
                        .sensoryFeedback(.selection, trigger: qty)
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.95))
                            .foregroundColor(Theme.primary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Theme.primary.opacity(0.4), lineWidth: 1.2)
                            )
                            .shadow(color: Theme.primary.opacity(0.12), radius: 3, x: 0, y: 1.5)
                        }
                        .fixedSize()
                        .sensoryFeedback(.impact(weight: .light), trigger: qty)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .padding(6)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

#Preview {
    ProductCardView(product: MockProducts.products[0])
        .environment(CartViewModel.shared)
}
