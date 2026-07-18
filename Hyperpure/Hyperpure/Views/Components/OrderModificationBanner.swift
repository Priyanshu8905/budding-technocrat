import SwiftUI

struct OrderModificationBanner: View {
    @Bindable private var orderManager = OrderManager.shared
    @Bindable private var appState = AppState.shared
    @State private var showCancelAlert = false
    var onOpenCart: (() -> Void)?
    
    private var progress: Double {
        Double(orderManager.countdownSeconds) / 60.0
    }
    
    var body: some View {
        if let order = orderManager.pendingOrder, order.status == .pendingConfirmation {
            VStack(spacing: 0) {
                // Progress bar at top
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.primary, Theme.offer],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 3)
                        .animation(.linear(duration: 1), value: progress)
                }
                .frame(height: 3)
                
                HStack(spacing: 14) {
                    // Countdown Timer Circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                            .frame(width: 46, height: 46)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Theme.primary,
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 46, height: 46)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        
                        VStack(spacing: 0) {
                            Text("\(orderManager.countdownSeconds)")
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundColor(Theme.primary)
                            Text("sec")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    
                    // Order Info
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Order Placed!")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("\(order.totalItemCount) items · ₹\(order.grandTotal)")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("You can modify or cancel")
                            .font(.system(size: 10).weight(.medium))
                            .foregroundColor(Theme.textMuted)
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 6) {
                        Button {
                            appState.selectedTab = 0
                            onOpenCart?()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 10))
                                Text("Add Items")
                                    .font(.system(size: 11).weight(.bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.primary)
                            .clipShape(Capsule())
                        }
                        
                        Button {
                            showCancelAlert = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Cancel")
                                    .font(.system(size: 11).weight(.bold))
                            }
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.primaryBg)
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: -4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.primary.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .alert("Cancel Order?", isPresented: $showCancelAlert) {
                Button("Keep Order", role: .cancel) { }
                Button("Cancel Order", role: .destructive) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        orderManager.cancelOrder()
                    }
                }
            } message: {
                Text("Your order items will be returned to your cart.")
            }
        }
    }
}

// MARK: - Order Status Toast
struct OrderStatusToast: View {
    @Bindable private var orderManager = OrderManager.shared
    
    var body: some View {
        VStack {
            if orderManager.showConfirmedToast {
                toastView(
                    icon: "checkmark.circle.fill",
                    message: "Order Confirmed! 🎉",
                    color: Theme.success
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .sensoryFeedback(.success, trigger: orderManager.showConfirmedToast)
            }
            
            if orderManager.showCancelledToast {
                toastView(
                    icon: "xmark.circle.fill",
                    message: "Order Cancelled — Items restored to cart",
                    color: Theme.primary
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .sensoryFeedback(.warning, trigger: orderManager.showCancelledToast)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: orderManager.showConfirmedToast)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: orderManager.showCancelledToast)
    }
    
    private func toastView(icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

#Preview {
    VStack {
        Spacer()
        OrderModificationBanner()
    }
}
