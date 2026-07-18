import Foundation

enum OrderStatus: String, Codable {
    case pendingConfirmation = "Pending Confirmation"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}

struct Order: Identifiable, Codable {
    let id: String
    var items: [CartItem]
    let subtotal: Int
    let deliveryFee: Int
    let tax: Int
    let grandTotal: Int
    let deliverySlot: String
    let placedAt: Date
    var status: OrderStatus
    
    /// Whether the order is still within the 1-minute modification window
    var isModifiable: Bool {
        status == .pendingConfirmation && remainingSeconds > 0
    }
    
    /// Seconds remaining in the modification window (60s from placement)
    var remainingSeconds: Int {
        let elapsed = Date().timeIntervalSince(placedAt)
        return max(0, 60 - Int(elapsed))
    }
    
    /// Total item count across all cart items
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    init(
        id: String = UUID().uuidString,
        items: [CartItem],
        subtotal: Int,
        deliveryFee: Int,
        tax: Int,
        grandTotal: Int,
        deliverySlot: String,
        placedAt: Date = Date(),
        status: OrderStatus = .pendingConfirmation
    ) {
        self.id = id
        self.items = items
        self.subtotal = subtotal
        self.deliveryFee = deliveryFee
        self.tax = tax
        self.grandTotal = grandTotal
        self.deliverySlot = deliverySlot
        self.placedAt = placedAt
        self.status = status
    }
}
