import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var isWholesaleSelected = true
    @State private var selectedDeliverySlot = 0
    
    private let slots = [
        "Today, 06:00 AM - 10:00 AM",
        "Today, 10:00 AM - 02:00 PM",
        "Tomorrow, 06:00 AM - 10:00 AM",
        "Tomorrow, 10:00 AM - 02:00 PM"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Segmented Toggle & Outlet Info (Screenshot 1)
                VStack(spacing: 12) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Guest Outlet")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Delhi, India, Delhi -")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    // Wholesale / Express Pill Segmented Control
                    HStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Button {
                                isWholesaleSelected = true
                            } label: {
                                Text("Wholesale")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(isWholesaleSelected ? .white : Theme.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isWholesaleSelected ? Theme.navyDark : Color.clear)
                                    .clipShape(Capsule())
                            }
                            
                            Button {
                                isWholesaleSelected = false
                            } label: {
                                HStack(spacing: 4) {
                                    Text("⚡")
                                    Text("Express")
                                }
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(isWholesaleSelected ? Theme.textPrimary : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(isWholesaleSelected ? Color.clear : Theme.navyDark)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(3)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(Capsule())
                        
                        // Swap / Filter Icon Button (Screenshot 1)
                        Button {
                            // Swap action
                        } label: {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(Theme.textMuted)
                                .frame(width: 40, height: 40)
                                .background(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                
                Divider()
                
                // Content Area
                if cartViewModel.items.isEmpty {
                    // Empty Cart State (Screenshot 1)
                    VStack(spacing: 16) {
                        Spacer()
                        
                        // Cart with box illustration
                        ZStack {
                            Circle()
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                .frame(width: 160, height: 40)
                                .offset(y: 50)
                            
                            VStack(spacing: -10) {
                                Text("📦")
                                    .font(.system(size: 60))
                                Text("🛒")
                                    .font(.system(size: 90))
                            }
                        }
                        
                        Text("Your cart is empty!")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Theme.textMuted)
                            .padding(.top, 20)
                        
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Start Shopping")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                } else {
                    // Filled Cart State
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(spacing: 12) {
                                ForEach(cartViewModel.items) { item in
                                    HStack(spacing: 12) {
                                        Text(categoryEmoji(for: item.product.category))
                                            .font(.system(size: 32))
                                            .frame(width: 50, height: 50)
                                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.product.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(Theme.textPrimary)
                                            Text(item.product.weight)
                                                .font(.caption)
                                                .foregroundColor(Theme.textMuted)
                                            Text("\(item.product.formattedPrice) × \(item.quantity) = ₹\(item.subtotal)")
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(Theme.primary)
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            Button {
                                                cartViewModel.updateQuantity(for: item.product, quantity: item.quantity - 1)
                                            } label: {
                                                Image(systemName: "minus")
                                                    .font(.caption2.weight(.bold))
                                                    .foregroundColor(Theme.primary)
                                                    .frame(width: 24, height: 24)
                                                    .background(Theme.primaryBg)
                                                    .clipShape(Circle())
                                            }
                                            
                                            Text("\(item.quantity)")
                                                .font(.caption.weight(.bold))
                                            
                                            Button {
                                                cartViewModel.updateQuantity(for: item.product, quantity: item.quantity + 1)
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.caption2.weight(.bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 24, height: 24)
                                                    .background(Theme.primary)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .cardStyle()
                                }
                            }
                            
                            // Delivery Slot Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Delivery Slot")
                                    .font(.headline.weight(.bold))
                                
                                ForEach(slots.indices, id: \.self) { idx in
                                    Button {
                                        selectedDeliverySlot = idx
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedDeliverySlot == idx ? "largecircle.fill.circle" : "circle")
                                                .foregroundColor(selectedDeliverySlot == idx ? Theme.primary : Theme.textMuted)
                                            Text(slots[idx])
                                                .font(.subheadline)
                                                .foregroundColor(Theme.textPrimary)
                                            Spacer()
                                        }
                                        .padding(12)
                                        .cardStyle()
                                    }
                                }
                            }
                            
                            // Order Summary
                            VStack(spacing: 8) {
                                Text("Order Summary")
                                    .font(.headline.weight(.bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                SummaryRow(title: "Subtotal", value: "₹\(cartViewModel.subtotal)")
                                SummaryRow(title: "Delivery Fee", value: cartViewModel.deliveryFee == 0 ? "FREE" : "₹\(cartViewModel.deliveryFee)")
                                SummaryRow(title: "GST (5%)", value: "₹\(cartViewModel.tax)")
                                
                                if cartViewModel.totalSavings > 0 {
                                    SummaryRow(title: "Total Savings", value: "-₹\(cartViewModel.totalSavings)", valueColor: Theme.success)
                                }
                                
                                Divider()
                                
                                SummaryRow(title: "Total Amount", value: "₹\(cartViewModel.grandTotal)", isBold: true)
                            }
                            .padding(14)
                            .cardStyle()
                            
                            Button {
                                // Proceed to checkout
                            } label: {
                                Text("Proceed to Checkout")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Theme.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                            }
                        }
                        .padding(16)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    var valueColor: Color = Theme.textPrimary
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(isBold ? .subheadline.weight(.bold) : .subheadline)
                .foregroundColor(isBold ? Theme.textPrimary : Theme.textSecondary)
            Spacer()
            Text(value)
                .font(isBold ? .subheadline.weight(.bold) : .subheadline.weight(.semibold))
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    CartView()
        .environment(CartViewModel())
}
