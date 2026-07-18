import SwiftUI

struct OrdersView: View {
    @State private var selectedFilter = 0
    @Bindable private var orderManager = OrderManager.shared
    var onStartShopping: (() -> Void)?
    
    private var activeOrders: [Order] {
        orderManager.orders.filter { $0.status == .pendingConfirmation }
    }
    
    private var pastOrders: [Order] {
        orderManager.orders.filter { $0.status != .pendingConfirmation }
    }
    
    private var displayedOrders: [Order] {
        selectedFilter == 0 ? activeOrders : pastOrders
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Native Segmented Control
                Picker("Orders Filter", selection: $selectedFilter) {
                    Text("Active Orders").tag(0)
                    Text("Past Orders").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                if displayedOrders.isEmpty {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView {
                            Label(
                                selectedFilter == 0 ? "No Active Orders" : "No Past Orders",
                                systemImage: "bag.fill"
                            )
                        } description: {
                            Text(selectedFilter == 0
                                 ? "Place an order and it will appear here."
                                 : "Your past and cancelled order invoices will appear here.")
                        } actions: {
                            Button("Browse Catalogue") {
                                onStartShopping?()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                        }
                    } else {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Theme.primary)
                            
                            Text(selectedFilter == 0 ? "No Active Orders" : "No Past Orders")
                                .font(.title2.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Button("Browse Catalogue") {
                                onStartShopping?()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.primary)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(displayedOrders) { order in
                                OrderCardView(order: order)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Order Card View
struct OrderCardView: View {
    let order: Order
    
    private var statusColor: Color {
        switch order.status {
        case .pendingConfirmation: return Theme.offer
        case .confirmed: return Theme.success
        case .cancelled: return Theme.primary
        }
    }
    
    private var statusIcon: String {
        switch order.status {
        case .pendingConfirmation: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Order ID + Status Badge
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Order #\(String(order.id.prefix(8)).uppercased())")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text(order.placedAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                    + Text(" ago")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 10))
                    Text(order.status.rawValue)
                        .font(.system(size: 11).weight(.bold))
                }
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.12))
                .clipShape(Capsule())
            }
            
            Divider()
            
            // Items summary
            VStack(spacing: 6) {
                ForEach(order.items.prefix(3)) { item in
                    HStack {
                        Text(categoryEmoji(for: item.product.category))
                            .font(.system(size: 16))
                        
                        Text(item.product.name)
                            .font(.caption)
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("×\(item.quantity)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text(item.product.formattedPrice)
                            .font(.caption.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                
                if order.items.count > 3 {
                    Text("+\(order.items.count - 3) more items")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(Theme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
            
            // Footer: Delivery Slot + Total Amount
            HStack {
                Text(order.deliverySlot)
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
                
                Spacer()
                
                Text("₹\(order.grandTotal)")
                    .font(.subheadline.weight(.black))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(14)
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
    OrdersView()
}
