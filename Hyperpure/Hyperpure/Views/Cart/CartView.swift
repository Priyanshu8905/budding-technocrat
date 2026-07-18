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
                // Content Area
                if cartViewModel.items.isEmpty {
                    // Empty Cart State
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView {
                            Label("Your cart is empty!", systemImage: "cart.fill")
                        } description: {
                            Text("Add products from the catalogue to get started.")
                        } actions: {
                            Button("Start Shopping") {
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "cart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Theme.textMuted)
                            Text("Your cart is empty!")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(Theme.textMuted)
                            Spacer()
                            Button("Start Shopping") {
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                        .background(Color(uiColor: .systemGroupedBackground))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("☔ Monsoon Sourcing Alert")
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(Theme.textPrimary)
                                        Text("Increase order volumes by 20% to safeguard against transit delays.")
                                            .font(.caption)
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    Spacer()
                                    Button {
                                        for item in cartViewModel.items {
                                            let bufferQty = Int(ceil(Double(item.quantity) * 1.2))
                                            cartViewModel.updateQuantity(for: item.product, quantity: bufferQty)
                                        }
                                    } label: {
                                        Text("Apply Buffer")
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Theme.primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(12)
                            .background(Theme.primary.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Theme.primary.opacity(0.15), lineWidth: 1)
                            )
                            
                            VStack(spacing: 12) {
                                ForEach(cartViewModel.items) { item in
                                    HStack(spacing: 12) {
                                        Text(categoryEmoji(for: item.product.category))
                                            .font(.system(size: 32))
                                            .frame(width: 50, height: 50)
                                            .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        
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
                                                    .frame(width: 26, height: 26)
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
                                                    .frame(width: 26, height: 26)
                                                    .background(Theme.primary)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .sensoryFeedback(.selection, trigger: item.quantity)
                                    }
                                    .padding(12)
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                            }
                            
                            // Delivery Slot Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Select Delivery Slot")
                                    .font(.headline.weight(.bold))
                                
                                ForEach(slots.indices, id: \.self) { idx in
                                    Button {
                                        selectedDeliverySlot = idx
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedDeliverySlot == idx ? "checkmark.circle.fill" : "circle")
                                                .font(.title3)
                                                .foregroundColor(selectedDeliverySlot == idx ? Theme.primary : Theme.textMuted)
                                            Text(slots[idx])
                                                .font(.subheadline)
                                                .foregroundColor(Theme.textPrimary)
                                            Spacer()
                                        }
                                        .padding(14)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                }
                            }
                            
                            // Order Summary
                            VStack(spacing: 10) {
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
                            .padding(16)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            
                            NavigationLink(destination: CheckoutView()) {
                                Text("Proceed to Checkout")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Theme.primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                        .padding(16)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
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
