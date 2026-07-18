import Foundation
import Observation

@MainActor
@Observable
final class OrderManager {
    static let shared = OrderManager()
    
    var orders: [Order] = []
    var pendingOrder: Order? = nil
    
    /// Countdown seconds for the active pending order
    var countdownSeconds: Int = 0
    
    /// Whether to show the order confirmed toast
    var showConfirmedToast: Bool = false
    var showCancelledToast: Bool = false
    
    private var countdownTimer: Timer?
    
    private init() {}
    
    /// Place a new order from the current cart contents
    func placeOrder(
        items: [CartItem],
        subtotal: Int,
        deliveryFee: Int,
        tax: Int,
        grandTotal: Int,
        deliverySlot: String
    ) {
        let order = Order(
            items: items,
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            tax: tax,
            grandTotal: grandTotal,
            deliverySlot: deliverySlot
        )
        
        orders.append(order)
        pendingOrder = order
        countdownSeconds = 60
        
        startCountdown()
        HapticService.shared.playSyncDoubleTap()
    }
    
    /// Cancel the pending order within the modification window
    func cancelOrder() {
        guard var order = pendingOrder, order.isModifiable else { return }
        
        order.status = .cancelled
        updateOrderInList(order)
        
        // Restore items to cart
        let cartVM = CartViewModel.shared
        for item in order.items {
            let existingQty = cartVM.quantity(for: item.product)
            cartVM.updateQuantity(for: item.product, quantity: existingQty + item.quantity)
        }
        
        stopCountdown()
        pendingOrder = nil
        
        showCancelledToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCancelledToast = false
        }
    }
    
    /// Add a product to the pending order
    func addItemToPendingOrder(product: Product, quantity: Int = 1) {
        guard var order = pendingOrder, order.isModifiable else { return }
        
        if let idx = order.items.firstIndex(where: { $0.product.id == product.id }) {
            order.items[idx].quantity += quantity
        } else {
            order.items.append(CartItem(product: product, quantity: quantity))
        }
        
        // Recalculate totals would happen server-side; for demo we update locally
        pendingOrder = order
        updateOrderInList(order)
    }
    
    /// Manually confirm the order early (user taps "Confirm Now")
    func confirmOrderEarly() {
        guard var order = pendingOrder, order.status == .pendingConfirmation else { return }
        
        order.status = .confirmed
        updateOrderInList(order)
        
        stopCountdown()
        pendingOrder = nil
        
        showConfirmedToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showConfirmedToast = false
        }
    }
    
    // MARK: - Private
    
    private func startCountdown() {
        stopCountdown()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if self.countdownSeconds > 0 {
                    self.countdownSeconds -= 1
                } else {
                    // Timer expired — auto-confirm the order
                    self.autoConfirmOrder()
                }
            }
        }
    }
    
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    private func autoConfirmOrder() {
        guard var order = pendingOrder, order.status == .pendingConfirmation else {
            stopCountdown()
            return
        }
        
        order.status = .confirmed
        updateOrderInList(order)
        
        stopCountdown()
        pendingOrder = nil
        
        showConfirmedToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showConfirmedToast = false
        }
    }
    
    private func updateOrderInList(_ order: Order) {
        if let idx = orders.firstIndex(where: { $0.id == order.id }) {
            orders[idx] = order
        }
    }
}
