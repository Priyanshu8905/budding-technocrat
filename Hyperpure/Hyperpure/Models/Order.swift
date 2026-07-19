// Order.swift
// SwiftData model representing a finalized procurement order.

import Foundation
import SwiftData

public enum OrderStatus: String, Codable, CaseIterable {
    case placed = "Placed"
    case dispatched = "Dispatched"
    case nearStore = "Near Store"
    case delivered = "Delivered"
    case pendingConfirmation = "Pending Confirmation"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}

@Model
public final class Order: Identifiable {
    @Attribute(.unique) public var id: String
    @Relationship(deleteRule: .cascade) public var lineItems: [CartLineItem]
    public var subtotal: Int
    public var deliveryFee: Int
    public var tax: Int
    public var grandTotal: Int
    public var deliverySlot: String
    public var placedAt: Date
    public var statusRaw: String
    
    public var status: OrderStatus {
        get { OrderStatus(rawValue: statusRaw) ?? .pendingConfirmation }
        set { statusRaw = newValue.rawValue }
    }
    
    public var items: [CartLineItem] { lineItems }
    
    public var isModifiable: Bool {
        status == .pendingConfirmation && remainingSeconds > 0
    }
    
    public var remainingSeconds: Int {
        let elapsed = Date().timeIntervalSince(placedAt)
        return max(0, 60 - Int(elapsed))
    }
    
    public var totalItemCount: Int {
        lineItems.reduce(0) { $0 + $1.quantity }
    }
    
    public init(
        id: String = UUID().uuidString,
        items: [CartLineItem],
        subtotal: Int,
        deliveryFee: Int,
        tax: Int,
        grandTotal: Int,
        deliverySlot: String,
        placedAt: Date = Date(),
        status: OrderStatus = .pendingConfirmation
    ) {
        self.id = id
        self.lineItems = items
        self.subtotal = subtotal
        self.deliveryFee = deliveryFee
        self.tax = tax
        self.grandTotal = grandTotal
        self.deliverySlot = deliverySlot
        self.placedAt = placedAt
        self.statusRaw = status.rawValue
    }
}
