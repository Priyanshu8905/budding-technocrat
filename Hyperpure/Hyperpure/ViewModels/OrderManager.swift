// OrderManager.swift
// ViewModel managing order status, countdowns, and historical orders database tracking.

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class OrderManager {
    public static let shared = OrderManager()
    
    public private(set) var orders: [Order] = []
    public var pendingOrder: Order? = nil
    
    public var countdownSeconds: Int = 0
    public var showConfirmedToast: Bool = false
    public var showCancelledToast: Bool = false
    
    private var countdownTimer: Timer?
    
    private init() {
        fetchOrders()
    }
    
    public func fetchOrders() {
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.placedAt, order: .reverse)])
        orders = (try? Database.shared.context.fetch(descriptor)) ?? []
    }
    
    public func placeOrder(
        items: [CartItem],
        subtotal: Int,
        deliveryFee: Int,
        tax: Int,
        grandTotal: Int,
        deliverySlot: String
    ) {
        let context = Database.shared.context
        
        let orderItems = items.map { item in
            CartLineItem(product: item.product, quantity: item.quantity)
        }
        
        for item in orderItems {
            context.insert(item)
        }
        
        let order = Order(
            items: orderItems,
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            tax: tax,
            grandTotal: grandTotal,
            deliverySlot: deliverySlot
        )
        
        context.insert(order)
        try? context.save()
        fetchOrders()
        
        pendingOrder = order
        countdownSeconds = 60
        
        startCountdown()
        HapticService.shared.playSyncDoubleTap()
    }
    
    public func cancelOrder() {
        guard let order = pendingOrder, order.isModifiable else { return }
        
        order.status = .cancelled
        try? Database.shared.context.save()
        fetchOrders()
        
        let cartVM = CartViewModel.shared
        for item in order.items {
            if let prod = item.product {
                let existingQty = cartVM.quantity(for: prod)
                cartVM.updateQuantity(for: prod, quantity: existingQty + item.quantity)
            }
        }
        
        stopCountdown()
        pendingOrder = nil
        
        showCancelledToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCancelledToast = false
        }
    }
    
    public func addItemToPendingOrder(product: Product, quantity: Int = 1) {
        guard let order = pendingOrder, order.isModifiable else { return }
        let context = Database.shared.context
        
        if let idx = order.lineItems.firstIndex(where: { $0.product?.id == product.id }) {
            order.lineItems[idx].quantity += quantity
        } else {
            let newItem = CartLineItem(product: product, quantity: quantity)
            context.insert(newItem)
            order.lineItems.append(newItem)
        }
        
        let sub = order.lineItems.reduce(0) { $0 + $1.subtotal }
        order.subtotal = sub
        order.deliveryFee = sub > 500 ? 0 : 49
        order.tax = Int(round(Double(sub) * 0.05))
        order.grandTotal = sub + order.deliveryFee + order.tax
        
        try? context.save()
        fetchOrders()
    }
    
    public func confirmOrderEarly() {
        guard let order = pendingOrder, order.status == .pendingConfirmation else { return }
        
        order.status = .confirmed
        try? Database.shared.context.save()
        fetchOrders()
        
        stopCountdown()
        pendingOrder = nil
        
        showConfirmedToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showConfirmedToast = false
        }
    }
    
    private func startCountdown() {
        stopCountdown()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                if self.countdownSeconds > 0 {
                    self.countdownSeconds -= 1
                } else {
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
        guard let order = pendingOrder, order.status == .pendingConfirmation else {
            stopCountdown()
            return
        }
        
        order.status = .confirmed
        try? Database.shared.context.save()
        fetchOrders()
        
        stopCountdown()
        pendingOrder = nil
        
        showConfirmedToast = true
        HapticService.shared.playSyncDoubleTap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showConfirmedToast = false
        }
    }
}
