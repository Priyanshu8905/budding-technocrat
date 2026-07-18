// HomeView.swift
// Main dashboard for searching products and presenting the floating tracking card & detail modal.

import SwiftUI
import MapKit

struct HomeView: View {
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var checkoutManager = CheckoutManager.shared

    var onNavigateToCategory: ((String) -> Void)?
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    var onOpenAccount: (() -> Void)?

    @State private var isCategoriesSheetPresented = false
    @State private var isTrackingSheetPresented = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Search bar trigger
                            Button {
                                isCategoriesSheetPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Theme.textSecondary)
                                    Text("Search wholesale ingredients, eggs, poultry...")
                                        .foregroundColor(Theme.textMuted)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(uiColor: .systemBackground))
                                .cornerRadius(Theme.radiusMd)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.top, 10)

                            // Weather Alert Callout
                            WeatherInsightsCalloutView()

                            // Popular Products Grid
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Popular Sourcing Stocks")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(MockProducts.products.filter(\.isPopular)) { product in
                                            PopularProductCard(product: product)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            // Sourcing categories banner
                            Button {
                                isCategoriesSheetPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "shippingbox.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Browse Wholesale Catalog")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                        Text("Bulk flour, raw meats, packaging materials & more")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Theme.primary)
                                .cornerRadius(Theme.radiusMd)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 120)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    
                    // Floating Mini-Tracker Pill (shows during all non-idle delivery steps)
                    if checkoutManager.state != .idle {
                        Button {
                            isTrackingSheetPresented = true
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primary.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: trackingIcon)
                                        .foregroundColor(Theme.primary)
                                        .font(.headline)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(trackingTitle)
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                    Text(trackingSubtitle)
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textMuted)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onOpenAccount?()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Theme.textPrimary)                       
                    }
                }
            }
            .sheet(isPresented: $isCategoriesSheetPresented) {
                CategoriesSheetView { categoryId in
                    onNavigateToCategory?(categoryId)
                }
                .presentationDetents([.fraction(0.65), .large])
            }
            .sheet(isPresented: $isTrackingSheetPresented) {
                DeliveryTrackingDetailSheet()
            }
        }
    }
    
    private var trackingIcon: String {
        switch checkoutManager.state {
        case .gracePeriodActive: return "clock.fill"
        case .orderLocked:       return "lock.fill"
        case .dispatched:        return "shippingbox.fill"
        case .arrived:           return "house.fill"
        case .completed:         return "checkmark.seal.fill"
        default:                 return "box.truck.fill"
        }
    }
    
    private var trackingTitle: String {
        switch checkoutManager.state {
        case .gracePeriodActive(let secs): return "Grace Window: \(secs)s remaining"
        case .orderLocked:       return "Order Locked & Preparing"
        case .dispatched:        return "Out for Delivery"
        case .arrived:           return "Courier Arrived (Order Reached)"
        case .completed:         return "Order Completed 🎉"
        default:                 return "Delivery Active"
        }
    }
    
    private var trackingSubtitle: String {
        switch checkoutManager.state {
        case .gracePeriodActive: return "You can still add items or cancel order."
        case .orderLocked:       return "Consignment being loaded at warehouse."
        case .dispatched:        return "Courier is en route to your kitchen."
        case .arrived:           return "Courier reached Connaught Place dock."
        case .completed:         return "Consignment delivered. Tap to view receipt."
        default:                 return "Tap to view live map tracking details."
        }
    }
}

struct DeliveryTrackingDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checkoutManager = CheckoutManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Map Panel
                    SourcingMapView()
                        .frame(height: 250)
                        .cornerRadius(18)
                        .padding(.horizontal)
                    
                    // Consumer Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DELIVERY RECIPIENT")
                            .font(.caption.bold())
                            .foregroundColor(Theme.textMuted)
                        
                        Divider()
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title)
                                .foregroundColor(Theme.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Kitchen Outpost NCR-08")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text("Connaught Place Block-B, New Delhi")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                Text("Contact: +91 98765 43210")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Rider Activities & Estimated Time (Dynamically mapped to courier progress)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LOGISTICS MILESTONES")
                            .font(.caption.bold())
                            .foregroundColor(Theme.textMuted)
                        
                        Divider()
                        
                        VStack(spacing: 16) {
                            milestoneRow(
                                title: "Order Placed & Confirmed",
                                desc: "Wholesale consignment verified by sourcing gateway",
                                time: "03:00 mins ago",
                                isDone: true
                            )
                            
                            milestoneRow(
                                title: "Courier Assigned at Warehouse",
                                desc: "Loading wheat flour and staples at CP hub",
                                time: "1:30 mins ago",
                                isDone: checkoutManager.courierProgress >= 0.25
                            )
                            
                            milestoneRow(
                                title: "Consignment Dispatched",
                                desc: "En route via CP Outer Ring Rd.",
                                time: "Just now",
                                isDone: checkoutManager.courierProgress >= 0.55
                            )
                            
                            milestoneRow(
                                title: "Order Reached",
                                desc: "Courier arrived at Connaught Place restaurant dock",
                                time: "Just now",
                                isDone: checkoutManager.courierProgress >= 0.85
                            )

                            milestoneRow(
                                title: "Order Completed",
                                desc: "Delivered successfully and added to history",
                                time: "Just now",
                                isDone: checkoutManager.courierProgress >= 1.0
                            )
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // E-Receipt Panel
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("E-RECEIPT")
                                .font(.caption.bold())
                                .foregroundColor(Theme.textMuted)
                            Spacer()
                            // Clear history button if completed
                            if checkoutManager.state == .completed {
                                Button("Archive Tracking") {
                                    checkoutManager.state = .idle
                                    dismiss()
                                }
                                .font(.caption.bold())
                                .foregroundColor(Theme.primary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Consignment ID: \(checkoutManager.orderID)")
                                .font(.caption.monospaced())
                                .foregroundColor(Theme.textMuted)
                            Spacer()
                            Text("Paid via \(checkoutManager.paymentType.displayLabel)")
                                .font(.caption2.bold())
                                .foregroundColor(checkoutManager.paymentType == .cardPayment ? .green : Theme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background((checkoutManager.paymentType == .cardPayment ? Color.green : Theme.primary).opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Divider()
                        
                        if checkoutManager.purchasedItems.isEmpty {
                            Text("No items recorded.")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                        } else {
                            ForEach(checkoutManager.purchasedItems) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.product.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(Theme.textPrimary)
                                        Text("Qty: \(item.quantity) units x ₹\(Int(round(item.product.price)))")
                                            .font(.caption)
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    Spacer()
                                    Text("₹\(item.subtotal)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        
                        Divider()
                        
                        SummaryRow(title: "Subtotal", value: "₹\(checkoutManager.subtotal)")
                        SummaryRow(title: "Delivery Fee", value: checkoutManager.deliveryFee == 0 ? "FREE" : "₹\(checkoutManager.deliveryFee)")
                        SummaryRow(title: "GST (5%)", value: "₹\(checkoutManager.tax)")
                        
                        Divider()
                        
                        HStack {
                            Text("Total Amount Paid")
                                .font(.subheadline.bold())
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Text("₹\(checkoutManager.grandTotal)")
                                .font(.title3.bold())
                                .foregroundColor(Theme.primary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Live Delivery Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func milestoneRow(title: String, desc: String, time: String, isDone: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Circle()
                    .fill(isDone ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(isDone ? Color.green : Color.gray.opacity(0.15))
                    .frame(width: 2, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(isDone ? Theme.textPrimary : Theme.textMuted)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Text(time)
                    .font(.system(size: 9))
                    .foregroundColor(Theme.textMuted)
            }
            Spacer()
        }
    }
}

// MARK: - Weather Insights Callout View

struct WeatherInsightsCalloutView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "cloud.rain.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Siri Weather Adjustments Active")
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("Monsoon Mode")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            Text("Severe monsoon rain is increasing transit times by 45 mins. Procurement limits are automatically increased by 15% to build safety buffer.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(2)
        }
        .padding()
        .background(Color.blue.opacity(0.04))
        .cornerRadius(Theme.radiusMd)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(Color.blue.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Popular Product Card

struct PopularProductCard: View {
    let product: Product
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.name)
                .font(.subheadline.bold())
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
            
            Text(product.weight)
                .font(.caption2)
                .foregroundColor(Theme.textMuted)
            
            HStack {
                Text(product.formattedPrice)
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button {
                    let qty = cartViewModel.quantity(for: product)
                    cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .padding()
        .frame(width: 150)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(Theme.radiusMd)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMd)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
    }
}
