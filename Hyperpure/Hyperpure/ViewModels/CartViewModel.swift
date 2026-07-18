// CartViewModel.swift
// ViewModel managing the state and operations of the shopping cart.

import Foundation
import Observation

@MainActor
@Observable
final class CartViewModel {
    static let shared = CartViewModel()
    
    private(set) var items: [CartItem] = []
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Int {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var totalMrp: Int {
        items.reduce(0) { $0 + $1.totalMrp }
    }
    
    var totalSavings: Int {
        totalMrp - subtotal
    }
    
    var deliveryFee: Int {
        subtotal > 500 || items.isEmpty ? 0 : 49
    }
    
    var tax: Int {
        Int(round(Double(subtotal) * 0.05))
    }
    
    var grandTotal: Int {
        items.isEmpty ? 0 : (subtotal + deliveryFee + tax)
    }
    
    func quantity(for product: Product) -> Int {
        items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }
    
    func add(product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func remove(product: Product) {
        items.removeAll(where: { $0.product.id == product.id })
    }
    
    func updateQuantity(for product: Product, quantity: Int) {
        if quantity <= 0 {
            remove(product: product)
        } else if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity = quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }
    
    func clear() {
        items.removeAll()
    }
}
